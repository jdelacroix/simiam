classdef Part2Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            v = cell2mat(regexp(input, 'v=[0-9]*.[0-9]*;', 'match'));
            v = str2double(v(3:end-1));
            
            theta_d = cell2mat(regexp(input, 'theta_d=[0-9]*.[0-9]*;', 'match'));
            theta_d = str2double(theta_d(9:end-1));
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            robot_s.supervisor.v = v;
            robot_s.supervisor.theta_d = theta_d;
            
            nSteps = 25;
            for i = 1:nSteps
                app.simulator_.step([],[]);
                pause(app.simulator_.time_step);
            end
            
            % Export percent error between actual and estimated pose
            
            [x,y,theta] = robot_s.supervisor.state_estimate.unpack();
            [rx, ry, rtheta] = robot_s.pose.unpack();
            
            pex = (rx-x)/rx;
            pey = (ry-y)/ry;
            petheta = (rtheta-theta)/rtheta;
            
            result = sprintf('%0.3f,%0.3f,%0.3f', abs(pex), abs(pey), abs(petheta));
            
            app.ui_close();
        end
    end
    
end

