classdef Part3Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            v = cell2mat(regexp(input, 'v=[0-9]*.[0-9]*;', 'match'));
            v = str2double(v(3:end-1));
            
            w = cell2mat(regexp(input, 'w=[0-9]*.[0-9]*;', 'match'));
            w = str2double(w(3:end-1));
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            
            [vel_r, vel_l] = robot_s.supervisor.ensure_w(robot_s.robot, v, w);
            [v_s, w_s] = robot_s.robot.dynamics.diff_to_uni(vel_r, vel_l);
            
%             [vel_r_us, vel_l_us] = robot_s.robot.dynamics.uni_to_diff(v, w);
%             [vel_r_us, vel_l_us] = robot_s.robot.limit_speeds(vel_r_us, vel_l_us);
%             [v_us, w_us] = robot_s.robot.dynamics.diff_to_uni(vel_r_us, vel_l_us);
            
            w
            w_s
%             w_us
%             v_us
            
            p_error = (w-w_s)/w;
            
            result = sprintf('%0.3f', p_error);
            
            app.ui_close();
        end
    end
    
end

