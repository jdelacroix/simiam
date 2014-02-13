classdef Part1Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            v = cell2mat(regexp(input, 'v=-?[0-9]*.[0-9]*;', 'match'));
            v = str2double(v(3:end-1));
            
            x_g = cell2mat(regexp(input, 'x_g=-?[0-9]*.[0-9]*;', 'match'));
            x_g = str2double(x_g(5:end-1));
            
            y_g = cell2mat(regexp(input, 'y_g=-?[0-9]*.[0-9]*;', 'match'));
            y_g = str2double(y_g(5:end-1));
                        
%             tokens = strsplit(input, ';');
%             
%             inputs = struct();
%             for i = 1:(numel(tokens)-1)
%                 token = strsplit(tokens{i}, '=');
%                 key = token{1};
%                 value = str2double(token{2});
%                 inputs.(key) = value;
%             end
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            robot_s.supervisor.v = v;
            robot_s.supervisor.goal = [x_g, y_g];
            robot_s.supervisor.is_blending = true;
            robot_s.supervisor.switch_to_state('ao_and_gtg');   % make sure ao_and_gtg is running
            
            timeS = 60;
            nSteps = timeS/app.simulator_.time_step;
            for i = 1:nSteps
                app.simulator_.step([],[]);
%                 pause(app.simulator_.time_step);
                if (robot_s.supervisor.check_event('at_goal') || app.is_state_crashed_)
                    break;
                end
            end
            
            check_1 = (robot_s.supervisor.check_event('at_goal') && ~app.is_state_crashed_);
            result = sprintf('%d', check_1);
            
            app.ui_close();
        end
    end
    
end

