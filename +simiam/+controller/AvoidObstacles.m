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
        p
        
        % IR plot support
        u_arrow
        u_arrow_r
        s_net
        
        % sensor geometry
        calibrated
        sensor_placement
    end
    
    properties (Constant)
        inputs = struct('v', 0);
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = AvoidObstacles()
            obj = obj@simiam.controller.Controller('avoid_obstacles');            
            obj.calibrated = false;
            
            obj.Kp = 4;
            obj.Ki = 0.01;
            obj.Kd = 0.1;
            
            obj.E_k = 0;
            obj.e_k_1 = 0;
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Compute the placement of the sensors
            if(~obj.calibrated)
                obj.set_sensor_geometry(robot);
                
                % Temporoary plot support
                hold(robot.parent, 'on');
                obj.u_arrow_r = plot(robot.parent, [0 0], [0 0], 'b-x', 'LineWidth', 2);
                obj.u_arrow = plot(robot.parent, [0 0], [0 0], 'r--x', 'LineWidth', 2);
                obj.s_net = plot(robot.parent, zeros(1,5), zeros(1,5), 'kx', 'MarkerSize', 8);
                set(obj.u_arrow_r, 'ZData', ones(1,2));
                set(obj.u_arrow, 'ZData', ones(1,2));
                set(obj.s_net, 'ZData', ones(1,5));
            end
            
            % Unpack state estimate
            [x, y, theta] = state_estimate.unpack();
            
            % Poll the current IR sensor values 1-5
            ir_distances = robot.get_ir_distances();           
            
                        
            % Interpret the IR sensor measurements geometrically
            ir_distances_wf = obj.apply_sensor_geometry(ir_distances, state_estimate);            
            
            %% START CODE BLOCK %%
            
            % Compute the heading vector
            
            n_sensors = length(robot.ir_array);
            sensor_gains = [0 0 0 0 0];
            u_i = zeros(2,5);
            u_ao = sum(u_i,2);
            
            % Compute the heading and error for the PID controller
            theta_ao = 0;
            e_k = 0;
            e_k = atan2(sin(e_k),cos(e_k));
            
            %% END CODE BLOCK %%
                                    
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
            obj.p.plot_2d_ref(dt, atan2(sin(theta),cos(theta)), theta_ao, 'g');
            
%             fprintf('(v,w) = (%0.4g,%0.4g)\n', v,w);
            
            % Temporary plot support
            u_n = u_ao/(4*norm(u_ao));
            set(obj.u_arrow, 'XData', [x x+u_n(1)]);
            set(obj.u_arrow, 'YData', [y y+u_n(2)]);
            set(obj.u_arrow_r, 'XData', [x x+0.25*cos(theta)]);
            set(obj.u_arrow_r, 'YData', [y y+0.25*sin(theta)]);
            set(obj.s_net, 'XData', ir_distances_wf(1,:));
            set(obj.s_net, 'YData', ir_distances_wf(2,:));

            % velocity control
            outputs.v = v;
            outputs.w = w;
        end
        
        % Helper functions
        
        function ir_distances_wf = apply_sensor_geometry(obj, ir_distances, state_estimate)
            n_sensors = numel(ir_distances);
            
            %% START CODE BLOCK %%
            
            % Apply the transformation to robot frame.
            
            ir_distances_rf = zeros(3,n_sensors);
            for i=1:n_sensors
                x_s = obj.sensor_placement(1,i);
                y_s = obj.sensor_placement(2,i);
                theta_s = obj.sensor_placement(3,i);
                
                R = obj.get_transformation_matrix(0,0,0);
                ir_distances_rf(:,i) = zeros(3,1);
            end
            
            % Apply the transformation to world frame.
            
            [x,y,theta] = state_estimate.unpack();
            
            R = obj.get_transformation_matrix(0,0,0);
            ir_distances_wf = zeros(3,5);
            
            %% END CODE BLOCK %%
            
            ir_distances_wf = ir_distances_wf(1:2,:);
        end
        
        
        function R = get_transformation_matrix(obj, x, y, theta)
            %% START CODE BLOCK %%
            R = zeros(3,3);
            %% END CODE BLOCK %%
        end
        
        function set_sensor_geometry(obj, robot)
            n_sensors = length(robot.ir_array);
            obj.sensor_placement = zeros(3,n_sensors);
            for i=1:n_sensors
                [x, y, theta] = robot.ir_array(i).location.unpack();
                obj.sensor_placement(:,i) = [x; y; theta];
            end                        
            obj.calibrated = true;
        end
        
    end
    
end
