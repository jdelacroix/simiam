classdef Part2Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            
            v = cell2mat(regexp(input, 'v=-?[0-9]*.[0-9]*;', 'match'));
            v = str2double(v(3:end-1));
            
            dir = cell2mat(regexp(input, 'dir=(left|right);', 'match'));
            dir = dir(5:end-1);
            
            theta = cell2mat(regexp(input, 'theta=-?[0-9]*.[0-9]*;', 'match'));
            theta = str2double(theta(7:end-1));
                        
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
            robot_s.supervisor.fw_direction = dir;
            robot_s.pose.set_pose([0, 0, theta]);
            robot_s.supervisor.state_estimate.set_pose([0, 0, theta]);
            
            new_lap = true;
            lap_count = 0;
            
            timeS = 90;
            nSteps = timeS/app.simulator_.time_step;
            nthStep = 0;
            for i = 1:nSteps
                app.simulator_.step([],[]);
%                 pause(app.simulator_.time_step);
                [x, y, theta] = robot_s.pose.unpack();
                if (new_lap && (norm([x;y]) > 0.1))
                    new_lap = false;
                    lap_count = lap_count+1;
                    if (lap_count > 0)
                        fprintf('Finished lap #%d\n', lap_count-1);
                    end
                elseif (~new_lap && (norm([x;y]) < 0.1))
                    new_lap = true;
                    fprintf('Starting lap #%d\n', lap_count);
                end
                
                nthStep = i;

                if (app.is_state_crashed_ || lap_count > 2)
                    break;
                end
            end
            
            fprintf('Completed %d lap(s) in %0.1fs\n', lap_count-1, nthStep*app.simulator_.time_step);
            
            check_1 = (~app.is_state_crashed_ && lap_count > 2);
            result = sprintf('%d', check_1);
            app.ui_close();
        end
    end
    
end

