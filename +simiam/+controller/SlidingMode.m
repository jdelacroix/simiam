classdef SlidingMode < simiam.controller.Controller

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        
        % memory banks
        u_gtg
        u_ao
        u_fw
        
        % plot support
        p
        
        % sensor geometry
        calibrated
        sensor_placement        
    end
    
    properties (Constant)
        inputs = struct('v', 0, 'direction', 'right');
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = SlidingMode()
            obj = obj@simiam.controller.Controller('sliding_mode');            
            obj.calibrated = false;
            obj.p = [];
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-5
            ir_distances = robot.get_ir_distances();
                        
            % Interpret the IR sensor measurements geometrically
            ir_distances_wf = obj.apply_sensor_geometry(ir_distances, state_estimate);            
                        
            % 1. Compute u_gtg
            obj.u_gtg = [inputs.x_g-x; inputs.y_g-y];
            
            % 2. Compute u_ao
            sensor_gains = [1 1 0.5 1 1];
            u_i = (ir_distances_wf-repmat([x;y],1,5))*diag(sensor_gains);
            obj.u_ao = sum(u_i,2);
            
            % 3. Compute u_fw (as if it originated from the robot)

            if(strcmp(inputs.direction,'right'))
                % Pick two of the right sensors based on ir_distances
                S = [1:3 ; ir_distances(5:-1:3)'];
                [Y,i] = sort(S(2,:));
                S = S(1,i);
                
                Sp = 5:-1:3;
                
                S1 = Sp(S(1));
                S2 = Sp(S(2));
                
                if(S1 < S2)
                    p_1 = ir_distances_wf(:,S2);
                    p_2 = ir_distances_wf(:,S1);
                else
                    p_1 = ir_distances_wf(:,S1);
                    p_2 = ir_distances_wf(:,S2);
                end
                
            else
                % Pick two of the left sensors based on ir_distances
                S = [1:3 ; ir_distances(1:3)'];
                [Y,i] = sort(S(2,:));
                S = S(1,i);
                
                if(S(1) > S(2))
                    p_1 = ir_distances_wf(:,S(2));
                    p_2 = ir_distances_wf(:,S(1));
                else
                    p_1 = ir_distances_wf(:,S(1));
                    p_2 = ir_distances_wf(:,S(2));
                end
            end
            
            u_fw_t = p_2-p_1;                        
            theta_fw = atan2(u_fw_t(2),u_fw_t(1));
            obj.u_fw = [x+cos(theta_fw); y+sin(theta_fw)];
            
            outputs.v = 0;
            outputs.w = 0;
        end
        
        % Helper functions
        
        function ir_distances_wf = apply_sensor_geometry(obj, ir_distances, state_estimate)
                    
            % Apply the transformation to robot frame.
            
            ir_distances_rf = zeros(3,5);
            for i=1:5
                x_s = obj.sensor_placement(1,i);
                y_s = obj.sensor_placement(2,i);
                theta_s = obj.sensor_placement(3,i);
                
                R = obj.get_transformation_matrix(x_s,y_s,theta_s);
                ir_distances_rf(:,i) = R*[ir_distances(i); 0; 1];
            end
            
            % Apply the transformation to world frame.
            
            [x,y,theta] = state_estimate.unpack();
            
            R = obj.get_transformation_matrix(x,y,theta);
            ir_distances_wf = R*ir_distances_rf;
            
            ir_distances_wf = ir_distances_wf(1:2,:);
        end
        
        function set_sensor_geometry(obj, robot)
            obj.sensor_placement = zeros(3,5);
            for i=1:5
                [x, y, theta] = robot.ir_array(i).location.unpack();
                obj.sensor_placement(:,i) = [x; y; theta];
            end                        
            obj.calibrated = true;
        end
        
        function R = get_transformation_matrix(obj, x, y, theta)
            R = [cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1];
        end
        
    end
    
end

