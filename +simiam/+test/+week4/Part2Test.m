classdef Part2Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            tokens = strsplit(input, ';');
            
            inputs = struct();
            for i = 1:(numel(tokens)-1)
                token = strsplit(tokens{i}, '=');
                key = token{1};
                value = str2double(token{2});
                inputs.(key) = value;
            end
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            robot_s.supervisor.v = inputs.v;
            
            timeS = 60;
            nSteps = timeS/app.simulator_.time_step;
            for i = 1:nSteps
                app.simulator_.step([],[]);
%                 pause(app.simulator_.time_step);
                if (app.is_state_crashed_)
                    break;
                end
            end
            
            
            
            % Export percent error between actual and estimated pose
            
            result = sprintf('%d', app.is_state_crashed_);
            
            app.ui_close();
        end
    end
    
end

