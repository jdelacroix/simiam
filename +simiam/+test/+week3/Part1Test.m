classdef Part1Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            v = cell2mat(regexp(input, 'v=[0-9]*.[0-9]*;', 'match'));
            v = str2double(v(3:end-1));
            
            x_g = cell2mat(regexp(input, 'x_g=-?[0-9]*.[0-9]*;', 'match'));
            x_g = str2double(x_g(5:end-1));
            
            y_g = cell2mat(regexp(input, 'y_g=-?[0-9]*.[0-9]*;', 'match'));
            y_g = str2double(y_g(5:end-1));
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            robot_s.supervisor.v = v;
            robot_s.supervisor.goal = [x_g, y_g];

            timeS = 30;
            nSteps = timeS/app.simulator_.time_step;
            arrival = false;
            for i = 1:nSteps
                app.simulator_.step([],[]);
%                 pause(app.simulator_.time_step);
                [x, y, theta] = robot_s.pose.unpack();
                if (norm([x - x_g; y - y_g]) < 0.05)
                    arrival = true;
                    break;
                elseif app.is_state_crashed_
                    break;
                end
            end
            
            fprintf('Test: (x_g,y_g)=(%0.3f,%0.3f); Result (x,y)=(%0.3f,%0.3f)\n', x_g, y_g, x, y);
            
            % Export percent error between actual and estimated pose
            
            result = sprintf('%d', arrival);
            
            app.ui_close();
        end
    end
    
end

