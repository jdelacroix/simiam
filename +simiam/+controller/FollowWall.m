classdef FollowWall < simiam.controller.Controller

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        
        % memory banks
        E_k
        e_k_1
        
        % gains
        Kp
        Ki
        Kd
        
        % plot support
        p
        
        % sensor geometry
        calibrated
        sensor_placement
        
        v_t
        v_p
        v_pt
        
    end
    
    properties (Constant)
        inputs = struct('v', 0, 'direction', 'right');
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = FollowWall()
            obj = obj@simiam.controller.Controller('follow_wall');            
            obj.calibrated = false;
            
            obj.Kp = 2;
            obj.Ki = 0;
            obj.Kd = 0;
            
            obj.E_k = 0;
            obj.e_k_1 = 0;
            
%             obj.p = simiam.util.Plotter();
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
                
                
                hold(robot.parent, 'on');
                obj.v_t = plot(robot.parent, [0;0],[0;0],'r-', 'LineWidth', 2);
                obj.v_p = plot(robot.parent, [0;0],[0;0],'b-', 'LineWidth', 2);
                set(obj.v_t, 'ZData', [2;2]);
                set(obj.v_p, 'ZData', [2;2]);
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-5
            ir_distances = robot.get_ir_distances();
                        
            % Interpret the IR sensor measurements geometrically
            ir_distances_wf = obj.apply_sensor_geometry(ir_distances, state_estimate);            
            
            % Compute the heading vector
            d_fw = inputs.d_fw;

            %% START CODE BLOCK %%
            
            % 1. Select p_2 and p_1, then compute u_fw_t
            if(strcmp(inputs.direction,'right'))
                % Pick two of the right sensors based on ir_distances
                p_1 = ir_distances_wf(:,1);
                p_2 = ir_distances_wf(:,1);
            else
                % Pick two of the left sensors based on ir_distances
                p_1 = ir_distances_wf(:,5);
                p_2 = ir_distances_wf(:,5);
            end
            
            u_fw_t = [0;0];

            % 2. Compute u_a, u_p, and u_fw_tp to compute u_fw_p
            
            u_fw_tp = [0;0];
            u_a = [0;0];
            u_p = [0;0];
            
            u_fw_p = [0;0];
            
            % 3. Combine u_fw_tp and u_fw_pp into u_fw;
            u_fw_pp = [0;0];
            u_fw = u_fw_tp;
            
            %% END CODE BLOCK %%
            
            % Compute the heading and error for the PID controller
            theta_fw = atan2(u_fw(2),u_fw(1));
            e_k = theta_fw-theta;
            e_k = atan2(sin(e_k),cos(e_k));
                                    
            e_P = e_k;
            e_I = obj.E_k + e_k*dt;
            e_D = (e_k-obj.e_k_1)/dt;
              
            % PID control on w
            v = inputs.v;
            w = obj.Kp*e_P + obj.Ki*e_I + obj.Kd*e_D;
            
            % Save errors for next time step
            obj.E_k = e_I;
            obj.e_k_1 = e_k;
            
            set(obj.v_t, 'XData', [u_fw_t(1)+p_1(1);p_1(1)]);
            set(obj.v_t, 'YData', [u_fw_t(2)+p_1(2);p_1(2)]);
            set(obj.v_p, 'XData', [u_fw_p(1)+x;x]);
            set(obj.v_p, 'YData', [u_fw_p(2)+y;y]);
                        
            % plot
%             obj.p.plot_2d_ref(dt, atan2(sin(theta),cos(theta)), theta_fw, 'c');
            
%             fprintf('(v,w) = (%0.4g,%0.4g)\n', v,w);            

            outputs.v = v;
            outputs.w = w;
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

