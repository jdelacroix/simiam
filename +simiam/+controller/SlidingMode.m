classdef SlidingMode < simiam.controller.Controller

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        
        % memory banks
        
        % sensor geometry
        calibrated
        sensor_placement
        
        d_fw
        
        u_ao
        u_gtg
        u_fw
    end
    
    properties (Constant)
        inputs = struct('v', 0, 'direction', 'right', 'x_g', 0, 'y_g', 0);
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = SlidingMode()
            obj = obj@simiam.controller.Controller('sliding_mode');            
            obj.calibrated = false;
            
            obj.d_fw = 0.1;
            
            obj.u_ao = [0;0];
            obj.u_fw = [0;0];
            obj.u_gtg = [0;0];
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-9
            ir_distances = robot.get_ir_distances();
                        
            % Interpret the IR sensor measurements geometrically
            ir_distances_rf = obj.apply_sensor_geometry(ir_distances, state_estimate);            
            
            % Compute the heading vector

            % 0. Compute u_ao and u_gtg

            sensor_gains = [1 1 1 1 1 1 1 1 1];
            u_i = (ir_distances_rf-repmat([x;y],1,9))*diag(sensor_gains);
            obj.u_ao = sum(u_i,2);
            
            obj.u_gtg = [inputs.x_g-x; inputs.y_g-y];

            % 1. Select p_2 and p_1, then compute u_fw_t
            if(strcmp(inputs.direction,'right'))
                % Pick two of the right sensors based on ir_distances
                S = [1:4 ; ir_distances(8:-1:5)];
                [Y,i] = sort(S(2,:));
                S = S(1,i);
                
                Sp = 8:-1:5;
                
                S1 = Sp(S(1));
                S2 = Sp(S(2));
                
                if(S1 < S2)
                    p_1 = ir_distances_rf(:,S2);
                    p_2 = ir_distances_rf(:,S1);
                else
                    p_1 = ir_distances_rf(:,S1);
                    p_2 = ir_distances_rf(:,S2);
                end
            else
                % Pick two of the left sensors based on ir_distances
                S = [1:4 ; ir_distances(1:4)];
                [Y,i] = sort(S(2,:));
                S = S(1,i);

                if(S(1) > S(2))
                    p_1 = ir_distances_rf(:,S(2));
                    p_2 = ir_distances_rf(:,S(1));
                else
                    p_1 = ir_distances_rf(:,S(1));
                    p_2 = ir_distances_rf(:,S(2));
                end
            end
            
            u_fw_t = p_2-p_1;                        
            theta_fw = atan2(u_fw_t(2),u_fw_t(1));
            obj.u_fw = [x+cos(theta_fw); y+sin(theta_fw)];
            
            % velocity control
          
            outputs.v = 0;
            outputs.w = 0;
        end
        
        % Helper functions
        
        function ir_distances_rf = apply_sensor_geometry(obj, ir_distances, state_estimate)
                    
            % Apply the transformation to robot frame.
            
            ir_distances_sf = zeros(3,9);
            for i=1:9
                x_s = obj.sensor_placement(1,i);
                y_s = obj.sensor_placement(2,i);
                theta_s = obj.sensor_placement(3,i);
                
                R = obj.get_transformation_matrix(x_s,y_s,theta_s);
                ir_distances_sf(:,i) = R*[ir_distances(i); 0; 1];
            end
            
            % Apply the transformation to world frame.
            
            [x,y,theta] = state_estimate.unpack();
            
            R = obj.get_transformation_matrix(x,y,theta);
            ir_distances_rf = R*ir_distances_sf;
            
            ir_distances_rf = ir_distances_rf(1:2,:);
        end
        
        function set_sensor_geometry(obj, robot)
            obj.sensor_placement = zeros(3,9);
            for i=1:9
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