classdef Part1Test < simiam.test.PartTest

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
            robot = robot_s.robot;
            [vel_r, vel_l] = robot.dynamics.uni_to_diff(v,w);
            
            result = sprintf('%0.3f,%0.3f', vel_r, vel_l);
            
            app.ui_close();
        end
    end
    
end

