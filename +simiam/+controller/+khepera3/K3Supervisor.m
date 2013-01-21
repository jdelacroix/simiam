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

    properties
    %% PROPERTIES
    
        prev_ticks          % Previous tick count on the left and right wheels
        goal
        reached_goal
    end
    
    methods
    %% METHODS
        
        function obj = K3Supervisor()
        %% SUPERVISOR Constructor
            obj = obj@simiam.controller.Supervisor();
            
            % initialize the controllers
            obj.controllers{1} = simiam.controller.AvoidObstacles();
            obj.controllers{2} = simiam.controller.GoToGoal();
            
            % set the initial controller
            obj.current_controller = obj.controllers{2};
            
            obj.prev_ticks = struct('left', 0, 'right', 0);
            
            obj.goal = [0;0];
            obj.reached_goal = false;
        end
        
        function execute(obj, dt)
        %% EXECUTE Selects and executes the current controller.
        %   execute(obj, robot) will select a controller from the list of
        %   available controllers and execute it.
        %
        %   See also controller/execute
        
            [x_i, y_i, theta_i] = obj.state_estimate.unpack();       
            x_g = obj.goal(1); y_g = obj.goal(2);
                        
            if sqrt((x_i-x_g)^2+(y_i-y_g)^2) > 0.02
                
                                
                inputs = obj.current_controller.inputs;
                inputs.x_g = x_g;
                inputs.y_g = y_g;
                inputs.v = 0.1;
                
                outputs = obj.current_controller.execute(obj.robot, obj.state_estimate, inputs, dt);
                
                [vel_r, vel_l] = obj.robot.dynamics.uni_to_diff(outputs.v, outputs.w);
                
                obj.robot.set_wheel_speeds(vel_r, vel_l);
            else
                obj.reached_goal = true;
                obj.robot.set_wheel_speeds(0,0);
            end
            
            obj.update_odometry();
%             [x, y, theta] = obj.state_estimate.unpack();
%             fprintf('current_pose: (%0.3f,%0.3f,%0.3f)\n', x, y, theta);
        end
        
        function set_current_controller(obj, k)
            obj.current_controller = obj.controllers{k};
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
            
            % Remember, if you want to save something for the next
            % iteration, add a variable to the 'properties' section at the
            % top (e.g., 'var'), and you can refer to it via 'obj.var' in
            % this function.
            
            prev_right_ticks = obj.prev_ticks.right;
            prev_left_ticks = obj.prev_ticks.left;
            
            obj.prev_ticks.right = right_ticks;
            obj.prev_ticks.left = left_ticks;
            
            % Previous estimate 
            [x, y, theta] = obj.state_estimate.unpack();
            
            % Compute odometry here
            
            m_per_tick = (2*pi*obj.robot.wheel_radius)/obj.robot.encoders(1).ticks_per_rev;
            
            theta_p = theta;
            x_p = x;
            y_p = y;
                           
%             fprintf('Estimated pose (x,y,theta): (%0.3g,%0.3g,%0.3g)\n', x_p, y_p, theta_p);
            
            % Update your estimate of (x,y,theta)
            obj.state_estimate.set_pose([x_p, y_p, theta_p]);
        end
    end
end
