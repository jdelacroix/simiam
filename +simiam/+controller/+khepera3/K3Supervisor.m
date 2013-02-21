classdef K3Supervisor < simiam.controller.Supervisor
%% SUPERVISOR switches between controllers and handles their inputs/outputs.
%
% Properties:
%   current_controller      - Currently selected controller
%   controllers             - List of available controllers
%   goal_points             - Set of goal points
%   goal_index              - Pointer to current goal point
%   v                       - Robot velocity
%
% Methods:
%   execute - Selects and executes the current controller.

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
    %% PROPERTIES
    
        prev_ticks          % Previous tick count on the left and right wheels
        v
        goal
        is_blending
        d_stop
        p
    end
    
    methods
    %% METHODS
        
        function obj = K3Supervisor()
        %% SUPERVISOR Constructor
            obj = obj@simiam.controller.Supervisor();
            
            % initialize the controllers
            obj.controllers{1} = simiam.controller.AvoidObstacles();
            obj.controllers{2} = simiam.controller.GoToGoal();
            obj.controllers{3} = simiam.controller.GoToAngle();
            obj.controllers{4} = simiam.controller.AOandGTG();
            
            % set the initial controller
            obj.current_controller = obj.controllers{4};
            
            obj.prev_ticks = struct('left', 0, 'right', 0);
            
            %% START CODE BLOCK %%
            obj.v = 0.1;
            obj.goal = [1;1];
            obj.is_blending = true;
            obj.d_stop = 0.02;
            %% END CODE BLOCK %%
            
            obj.p = simiam.util.Plotter();
            obj.current_controller.p = obj.p;
        end
        
        function execute(obj, dt)
        %% EXECUTE Selects and executes the current controller.
        %   execute(obj, robot) will select a controller from the list of
        %   available controllers and execute it.
        %
        %   See also controller/execute
        
            inputs = obj.controllers{4}.inputs; 
            inputs.v = obj.v;
            inputs.x_g = obj.goal(1);
            inputs.y_g = obj.goal(2);
        
            [x,y,theta] = obj.state_estimate.unpack();

            if(sqrt((inputs.x_g-x)^2+(inputs.y_g-y)^2)>obj.d_stop)
                    
                if(obj.is_blending)                 
                    outputs = obj.current_controller.execute(obj.robot, obj.state_estimate, inputs, dt);
                    fprintf('v: %0.3f\n', outputs.v);
                    [vel_r, vel_l] = obj.robot.dynamics.uni_to_diff(outputs.v, outputs.w);
                    obj.robot.set_wheel_speeds(vel_r, vel_l);
                else
                    %% START CODE BLOCK %%
                    if(any(obj.robot.get_ir_distances()<0.12))
                        obj.set_current_controller(1);
                    else
                        obj.set_current_controller(2);
                    end
                    
                    %% END CODE BLOCK %%
                    
                    outputs = obj.current_controller.execute(obj.robot, obj.state_estimate, inputs, dt);
            
                    [vel_r, vel_l] = obj.robot.dynamics.uni_to_diff(outputs.v, outputs.w);
                    obj.robot.set_wheel_speeds(vel_r, vel_l);
                end
            else
                obj.robot.set_wheel_speeds(0,0);
            end
            
            obj.update_odometry();
%             [x, y, theta] = obj.state_estimate.unpack();
%             fprintf('current_pose: (%0.3f,%0.3f,%0.3f)\n', x, y, theta);
        end
        
        function set_current_controller(obj, k)
            % save plots
            obj.current_controller = obj.controllers{k};
            obj.p.switch_2d_ref();
            obj.current_controller.p = obj.p;
        end
        
        function update_odometry(obj)
        %% UPDATE_ODOMETRY Approximates the location of the robot.
        %   obj = obj.update_odometry(robot) should be called from the
        %   execute function every iteration. The location of the robot is
        %   updated based on the difference to the previous wheel encoder
        %   ticks. This is only an approximation.
        %
        %   state_estimate is updated with the new location and the
        %   measured wheel encoder tick counts are stored in prev_ticks.
        
            % Get wheel encoder ticks from the robot
            right_ticks = obj.robot.encoders(1).ticks;
            left_ticks = obj.robot.encoders(2).ticks;
            
            % Recal the previous wheel encoder ticks
            prev_right_ticks = obj.prev_ticks.right;
            prev_left_ticks = obj.prev_ticks.left;
            
            % Previous estimate 
            [x, y, theta] = obj.state_estimate.unpack();
            
            % Compute odometry here
            R = obj.robot.wheel_radius;
            L = obj.robot.wheel_base_length;
            m_per_tick = (2*pi*R)/obj.robot.encoders(1).ticks_per_rev;
            
            d_right = (right_ticks-prev_right_ticks)*m_per_tick;
            d_left = (left_ticks-prev_left_ticks)*m_per_tick;
            d_center = (d_right + d_left)/2;
            
            x_dt = d_center*cos(theta);
            y_dt = d_center*sin(theta);
            theta_dt = (d_right - d_left)/L;
            
            theta_new = theta + theta_dt;
            x_new = x + x_dt;
            y_new = y + y_dt;                           
%             fprintf('Estimated pose (x,y,theta): (%0.3g,%0.3g,%0.3g)\n', x_new, y_new, theta_new);
            
            % Save the wheel encoder ticks for the next estimate
            obj.prev_ticks.right = right_ticks;
            obj.prev_ticks.left = left_ticks;
            
            % Update your estimate of (x,y,theta)
            obj.state_estimate.set_pose([x_new, y_new, theta_new]);
        end
    end
end
