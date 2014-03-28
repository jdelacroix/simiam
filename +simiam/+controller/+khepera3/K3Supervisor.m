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
    
        states
        eventsd
        
        current_state
    
    
        prev_ticks          % Previous tick count on the left and right wheels
        v
        goal

        goal_prev
        d_stop
        d_at_obs
        d_unsafe
        d_prog
        p

        
        direction
        
        v_gtg
        v_ao
        v_fw
        
%         is_init
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
            obj.controllers{5} = simiam.controller.Stop();
            obj.controllers{6} = simiam.controller.FollowWall();
            obj.controllers{7} = simiam.controller.SlidingMode();
            
            % set the initial controller
            obj.current_controller = obj.controllers{4};
            obj.current_state = 4;
            
            % generate the set of states
            for i = 1:length(obj.controllers)
                obj.states{i} = struct('state', obj.controllers{i}.type, ...
                                       'controller', obj.controllers{i});
            end
            
            % define the set of eventsd
            obj.eventsd{1} = struct('event', 'at_obstacle', ...
                                   'callback', @at_obstacle);
            
            obj.eventsd{2} = struct('event', 'at_goal', ...
                                   'callback', @at_goal);
            
            obj.eventsd{3} = struct('event', 'obstacle_cleared', ...
                                    'callback', @obstacle_cleared);
                                
            obj.eventsd{4} = struct('event', 'unsafe', ...
                                    'callback', @unsafe);
                                
            obj.eventsd{5} = struct('event', 'progress_made', ...
                                    'callback', @progress_made);
                                
            obj.eventsd{6} = struct('event', 'sliding_left', ...
                                    'callback', @sliding_left);
                               
            obj.eventsd{7} = struct('event', 'sliding_right', ...
                                    'callback', @sliding_right);
                               
            obj.prev_ticks = struct('left', 0, 'right', 0);
            
            obj.v               = 0.15;
            
            obj.goal            = [-1;1];
            obj.goal_prev       = obj.goal;
            obj.d_stop          = 0.05; 
            obj.d_at_obs        = 0.10;                
            obj.d_unsafe        = 0.03;
            
            obj.d_prog = 10;
            
            obj.p = simiam.util.Plotter();
            obj.current_controller.p = obj.p;
        end
        
        function execute(obj, dt)
        %% EXECUTE Selects and executes the current controller.
        %   execute(obj, robot) will select a controller from the list of
        %   available controllers and execute it.
        %
        %   See also controller/execute
                    
%             if(~obj.is_init)
%                 hold(obj.robot.parent, 'on');
%                 obj.v_gtg = plot(obj.robot.parent, [0 0], [0 0], 'b-');
%                 obj.v_ao = plot(obj.robot.parent, [0 0], [0 0], 'r-');
%                 obj.v_fw = plot(obj.robot.parent, [0 0], [0 0], 'g-');
%                 obj.is_init = true;
%             end
        
            inputs = obj.controllers{4}.inputs; 
            inputs.x_g = obj.goal(1);
            inputs.y_g = obj.goal(2);
            inputs.v = obj.v;

            
%             if(~all(obj.goal==obj.goal_prev))
% %                 [x,y,theta] = obj.state_estimate.unpack();
% %                 if(norm(obj.goal-[x;y])<norm(obj.goal_prev-[x;y]))
%                     obj.set_progress_point();
% %                 end
%                 obj.goal_prev = obj.goal;
%                 obj.switch_to_state('go_to_goal');
%             end
%             
            if (obj.check_event('at_goal'))
                obj.switch_to_state('stop');

%                 [x,y,theta] = obj.state_estimate.unpack();
%                 fprintf('stopped at (%0.3f,%0.3f)\n', x, y);
            else
                obj.switch_to_state('ao_and_gtg');
            end
%             elseif(obj.check_event('unsafe'))
%                 obj.switch_to_state('avoid_obstacles');                
%             else
%                 if (obj.is_in_state('go_to_goal'))
%                     if(obj.check_event('at_obstacle') && obj.check_event('sliding_left'))
%                         obj.direction = 'left';
% %                         fprintf('now following to the left\n');
%                         obj.switch_to_state('follow_wall');
%                         obj.set_progress_point();
%                     elseif(obj.check_event('at_obstacle') && obj.check_event('sliding_right'))
%                         obj.direction = 'right';
% %                         fprintf('now following to the right\n');
%                         obj.switch_to_state('follow_wall');
%                         obj.set_progress_point();
%                     end
%                 elseif (obj.is_in_state('follow_wall') && strcmp(obj.direction,'left'))
%                     if(obj.check_event('progress_made') && ~obj.check_event('sliding_left'))
%                         obj.switch_to_state('go_to_goal');
%                     end
%                 elseif (obj.is_in_state('follow_wall') && strcmp(obj.direction, 'right'))
%                     if(obj.check_event('progress_made') && ~obj.check_event('sliding_right'))
%                         obj.switch_to_state('go_to_goal');
%                     end
%                 elseif (obj.is_in_state('avoid_obstacles'))
%                     if(obj.check_event('obstacle_cleared'))
% %                         if(obj.check_event('sliding_left'))
% %                             obj.direction = 'left';
% %                             obj.switch_to_state('follow_wall');
% %                         elseif(obj.check_event('sliding_right'))
% %                             obj.direction = 'right';
% %                             obj.switch_to_state('follow_wall');
% %                         else
%                             obj.switch_to_state('go_to_goal');
% %                         end
%                     end
%                 end
%  
%             end
            
%             elseif(obj.check_event('unsafe'))
%                 obj.switch_to_state('avoid_obstacles');                
%             else
%                 if (obj.is_in_state('go_to_goal'))
%                     if(obj.check_event('at_obstacle') && obj.check_event('sliding_left'))
%                         obj.direction = 'left';
% %                         fprintf('now following to the left\n');
%                         obj.switch_to_state('follow_wall');
%                         obj.set_progress_point();
%                     elseif(obj.check_event('at_obstacle') && obj.check_event('sliding_right'))
%                         obj.direction = 'right';
% %                         fprintf('now following to the right\n');
%                         obj.switch_to_state('follow_wall');
%                         obj.set_progress_point();
%                     end
%                 elseif (obj.is_in_state('follow_wall') && strcmp(obj.direction,'left'))
%                     if(obj.check_event('progress_made') && ~obj.check_event('sliding_left'))
%                         obj.switch_to_state('go_to_goal');
%                     end
%                 elseif (obj.is_in_state('follow_wall') && strcmp(obj.direction, 'right'))
%                     if(obj.check_event('progress_made') && ~obj.check_event('sliding_right'))
%                         obj.switch_to_state('go_to_goal');
%                     end
%                 elseif (obj.is_in_state('avoid_obstacles'))
%                     if(obj.check_event('obstacle_cleared'))
% %                         if(obj.check_event('sliding_left'))
% %                             obj.direction = 'left';
% %                             obj.switch_to_state('follow_wall');
% %                         elseif(obj.check_event('sliding_right'))
% %                             obj.direction = 'right';
% %                             obj.switch_to_state('follow_wall');
% %                         else
%                             obj.switch_to_state('go_to_goal');
% %                         end
%                     end
%                 end
 
%             end
            
%             inputs.direction = obj.direction;
                                    
            outputs = obj.current_controller.execute(obj.robot, obj.state_estimate, inputs, dt);
                
            [vel_r, vel_l] = obj.robot.dynamics.uni_to_diff(outputs.v, outputs.w);
            obj.robot.set_wheel_speeds(vel_r, vel_l);
            
%             fprintf('(v,w) = (%0.3f,%0.3f)\n', outputs.v, outputs.w);
            
            obj.update_odometry();
%             [x, y, theta] = obj.state_estimate.unpack();
%             fprintf('current_pose: (%0.3f,%0.3f,%0.3f)\n', x, y, theta);
        end
        
        function set_progress_point(obj)
            [x, y, theta] = obj.state_estimate.unpack();
            obj.d_prog = norm([x-obj.goal(1);y-obj.goal(2)]);
        end
        
        %% Events %%
        
        function rc = sliding_left(obj, state, robot)
            inputs = obj.controllers{7}.inputs;
            inputs.x_g = obj.goal(1);
            inputs.y_g = obj.goal(2);
            inputs.direction = 'left';
            
            obj.controllers{7}.execute(obj.robot, obj.state_estimate, inputs, 0);
            
            u_gtg = obj.controllers{7}.u_gtg;
            u_ao = obj.controllers{7}.u_ao;
            u_fw = obj.controllers{7}.u_fw;
            
            %% START CODE BLOCK %%
            sigma = [u_gtg u_ao]\u_fw;
            %% END CODE BLOCK %%
            
            rc = false;
            if sigma(1) > 0 && sigma(2) > 0
%                 fprintf('now sliding left\n');
                rc = true;
            end
        end
        
        function rc = sliding_right(obj, state, robot)
            inputs = obj.controllers{7}.inputs;
            inputs.x_g = obj.goal(1);
            inputs.y_g = obj.goal(2);
            inputs.direction = 'right';
            
            obj.controllers{7}.execute(obj.robot, obj.state_estimate, inputs, 0);
            
            u_gtg = obj.controllers{7}.u_gtg;
            u_ao = obj.controllers{7}.u_ao;
            u_fw = obj.controllers{7}.u_fw;
            
            %% START CODE BLOCK
            sigma = [u_gtg u_ao]\u_fw;
            %% END CODE BLOCK
            
            rc = false;
            if sigma(1) > 0 && sigma(2) > 0
%                 fprintf('now sliding right\n');
                rc = true;
            end
        end   
        
        function rc = at_obstacle(obj, state, robot)
            ir_distances = obj.robot.get_ir_distances();
            rc = false;                                     % Assume initially that the robot is clear of obstacle
            
            % Loop through and test the sensors (only the front set)
            if any(ir_distances(2:7) < obj.d_at_obs)
                rc = true;
            end
        end
        
        function rc = unsafe(obj, state, robot)
            ir_distances = obj.robot.get_ir_distances();              
            rc = false;             % Assume initially that the robot is clear of obstacle
            
            % Loop through and test the sensors (only the front set)
            if any(ir_distances(2:7) < obj.d_unsafe)
                    rc = true;
            end
        end

        function rc = at_goal(obj, state, robot)
            [x,y,theta] = obj.state_estimate.unpack();
            rc = false;
            
            % Test distance from goal
            if norm([x - obj.goal(1); y - obj.goal(2)]) < obj.d_stop
                rc = true;
            end
        end

        function rc = obstacle_cleared(obj, state, robot)
            ir_distances = obj.robot.get_ir_distances();
            rc = false;              % Assume initially that the robot is clear of obstacle
            
            % Loop through and test the sensors (only front set)
            if all(ir_distances(2:7) > obj.d_at_obs)
                rc = true;
            end
        end
        
        function rc = progress_made(obj, state, robot)

            % Check for any progress
            [x, y, theta] = obj.state_estimate.unpack();
            epsilon = 0.1;
            
            %% START CODE BLOCK %%
            rc = false;
            if norm([x-obj.goal(1); y-obj.goal(2)]) < (obj.d_prog - epsilon)
                rc = true;          % progress has been made
            end
            %% END CODE BLOCK %%
            
        end
        
        
        %% State machine support functions
        
        function set_current_controller(obj, ctrl)
            % save plots
            obj.current_controller = ctrl;
            obj.p.switch_2d_ref();
            obj.current_controller.p = obj.p;
        end
        
        function rc = is_in_state(obj, name)
            rc = strcmp(name, obj.states{obj.current_state}.state);
        end
        
        function switch_to_state(obj, name)
            
            if(~obj.is_in_state(name))
                for i=1:numel(obj.states)
                    if(strcmp(obj.states{i}.state, name))
                        obj.set_current_controller(obj.states{i}.controller);
                        obj.current_state = i;
                        fprintf('switching to state %s\n', name);
                        return;
                    end
                end
            else
%                 fprintf('already in state %s\n', name);
                return
            end
            
            fprintf('no state exists with name %s\n', name);
        end
        
        function rc = check_event(obj, name)
           for i=1:numel(obj.eventsd)
               if(strcmp(obj.eventsd{i}.event, name))
                   rc = obj.eventsd{i}.callback(obj, obj.states{obj.current_state}, obj.robot);
                   return;
               end
           end
           
           % return code (rc)
           fprintf('no event exists with name %s\n', name);
           rc = false;
        end
        
        %% Odometry
        
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
