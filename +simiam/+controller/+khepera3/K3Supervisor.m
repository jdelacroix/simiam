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
        gains
        sgains
        velocity
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
            
            % set the initial controller
            obj.current_controller = obj.controllers{1};
            
            obj.prev_ticks = struct('left', 0, 'right', 0);
        end
        
        function configure_from_file(obj, filename)
            parameters = xmlread(filename);
            
%             goal_xml = parameters.getElementsByTagName('goal').item(0);
%             x_g = str2double(goal_xml.getAttribute('x'));
%             y_g = str2double(goal_xml.getAttribute('y'));
%             obj.goal = [x_g;y_g];
%             fprintf('goal: (%0.3f,%0.3f)\n', x_g, y_g);
            
            v_xml = parameters.getElementsByTagName('velocity').item(0);
            v = str2double(v_xml.getAttribute('v'));
            obj.velocity = v;
            fprintf('velocity: (%0.3f)\n', v);
            
            gains_xml = parameters.getElementsByTagName('gains').item(0);
            k_p = str2double(gains_xml.getAttribute('kp'));
            k_i = str2double(gains_xml.getAttribute('ki'));
            k_d = str2double(gains_xml.getAttribute('kd'));
            fprintf('gains: (%0.3f,%0.3f,%0.3f)\n', k_p, k_i, k_d);
            obj.controllers{1}.Kp = k_p;
            obj.controllers{1}.Ki = k_i;
            obj.controllers{1}.Kd = k_d;
            
            sgains_xml = parameters.getElementsByTagName('sensorgains').item(0);
            s_g_1 = str2double(sgains_xml.getAttribute('s1'));
            s_g_2 = str2double(sgains_xml.getAttribute('s2'));
            s_g_3 = str2double(sgains_xml.getAttribute('s3'));
            s_g_4 = str2double(sgains_xml.getAttribute('s4'));
            s_g_5 = str2double(sgains_xml.getAttribute('s5'));
            s_g_6 = str2double(sgains_xml.getAttribute('s6'));
            s_g_7 = str2double(sgains_xml.getAttribute('s7'));
            s_g_8 = str2double(sgains_xml.getAttribute('s8'));
            s_g_9 = str2double(sgains_xml.getAttribute('s9'));
            obj.sgains = [s_g_1 s_g_2 s_g_3 s_g_4 s_g_5 s_g_6 s_g_7 s_g_8 s_g_9]; 
            fprintf('sensor gains: (%0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f)\n', obj.sgains);
            
        end
        
        function execute(obj, dt)
        %% EXECUTE Selects and executes the current controller.
        %   execute(obj, robot) will select a controller from the list of
        %   available controllers and execute it.
        %
        %   See also controller/execute
                                
        inputs = obj.current_controller.inputs;
        inputs.sgains = obj.sgains;
        inputs.v = obj.velocity;
        
        outputs = obj.current_controller.execute(obj.robot, obj.state_estimate, inputs, dt);
        
        [vel_r, vel_l] = obj.robot.dynamics.uni_to_diff(outputs.v, outputs.w);
        
        obj.robot.set_wheel_speeds(vel_r, vel_l);
            
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
            R = obj.robot.wheel_radius;
            L = obj.robot.wheel_base_length;
            m_per_tick = (2*pi*R)/obj.robot.encoders(1).ticks_per_rev;
            
            d_right = (right_ticks-prev_right_ticks)*m_per_tick;
            d_left = (left_ticks-prev_left_ticks)*m_per_tick;
            
            d_center = (d_right + d_left)/2;
            phi = (d_right - d_left)/L;
            
            theta_new = theta + phi;
            x_new = x + d_center*cos(theta);
            y_new = y + d_center*sin(theta);
                           
%             fprintf('Estimated pose (x,y,theta): (%0.3g,%0.3g,%0.3g)\n', x_p, y_p, theta_p);
            
            % Update your estimate of (x,y,theta)
            obj.state_estimate.set_pose([x_new, y_new, theta_new]);
        end
    end
end
