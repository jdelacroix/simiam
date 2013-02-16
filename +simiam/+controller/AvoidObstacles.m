classdef AvoidObstacles < simiam.controller.Controller

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
        u_arrow
        u_arrow_r
        s_net
        
        % sensor geometry
        calibrated
        sensor_placement
    end
    
    properties (Constant)
        inputs = struct('v', 0, 'gains', []);
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = AvoidObstacles()
            obj = obj@simiam.controller.Controller('avoid_obstacles');            
            obj.calibrated = false;
            
            %% START CODE BLOCK %%
            obj.Kp = 5;
            obj.Ki = 0.01;
            obj.Kd = 0.1;
            %% END CODE BLOCK %%
            
            obj.E_k = 0;
            obj.e_k_1 = 0;
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
                hold(robot.parent, 'on');
                obj.u_arrow_r = plot(robot.parent, [0 0], [0 0], 'b-x', 'LineWidth', 2);
                obj.u_arrow = plot(robot.parent, [0 0], [0 0], 'r--x', 'LineWidth', 2);
                obj.s_net = plot(robot.parent, zeros(1,9), zeros(1,9), 'kx', 'MarkerSize', 8);
                set(obj.u_arrow_r, 'ZData', ones(1,2));
                set(obj.u_arrow, 'ZData', ones(1,2));
                set(obj.s_net, 'ZData', ones(1,9));
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-9
            ir_distances = robot.get_ir_distances();
                        
            % Interpret the IR sensor measurements geometrically
            ir_distances_rf = obj.apply_sensor_geometry(ir_distances, state_estimate);
            
            %% START CODE BLOCK %%
            
            
            % 3. Compute the heading vector
            
            sensor_gains = inputs.sgains;
            sensor_gains
            u_i = (ir_distances_rf-repmat([x;y],1,9))*diag(sensor_gains);
            u = sum(u_i,2);
            
            % Compute the heading and error for the PID controller
            theta_o = atan2(u(2),u(1));
            e_k = theta_o-theta;
            
            %% END CODE BLOCK %%
            
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
                        
            % plot
            u_n = u/(4*norm(u));
            set(obj.u_arrow, 'XData', [x x+u_n(1)]);
            set(obj.u_arrow, 'YData', [y y+u_n(2)]);
            set(obj.u_arrow_r, 'XData', [x x+0.25*cos(theta)]);
            set(obj.u_arrow_r, 'YData', [y y+0.25*sin(theta)]);
            set(obj.s_net, 'XData', ir_distances_rf(1,:));
            set(obj.s_net, 'YData', ir_distances_rf(2,:));
            
%             fprintf('(v,w) = (%0.4g,%0.4g)\n', v,w);
            
            outputs.v = v;
            outputs.w = w;
        end
        
        % Helper functions
        
        function ir_distances_rf = apply_sensor_geometry(obj, ir_distances, state_estimate)
                    
            % 1. Apply the transformation to robot frame.
            
            ir_distances_sf = zeros(3,9);
            for i=1:9
                x_s = obj.sensor_placement(1,i);
                y_s = obj.sensor_placement(2,i);
                theta_s = obj.sensor_placement(3,i);
                
                %% START CODE BLOCK %%
                R = obj.get_transformation_matrix(x_s,y_s,theta_s);
                ir_distances_sf(:,i) = R*[ir_distances(i); 0; 1];
                %% END CODE BLOCK %%
            end
            
            % 2. Apply the transformation to world frame.
            
            [x,y,theta] = state_estimate.unpack();
            
            %% START CODE BLOCK %%
            R = obj.get_transformation_matrix(x,y,theta);
            ir_distances_rf = R*ir_distances_sf;
            %% END CODE BLOCK %%
            
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
            %% START CODE BLOCK %%
            R = [cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1];
            %% END CODE BLOCK %%
        end
        
    end
    
end