classdef Part2Test < simiam.test.PartTest

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
            
            timeS = 15;
            nSteps = timeS/app.simulator_.time_step;
            for i = 1:nSteps
                app.simulator_.step([],[]);
%                 pause(app.simulator_.time_step);
                [x, y, theta] = robot_s.pose.unpack();
                if ((norm([x - x_g; y - y_g]) < 0.05) || app.is_state_crashed_)
                    break;
                end
            end
            
            t = robot_s.supervisor.p.t;
            y = robot_s.supervisor.p.y;
            r = robot_s.supervisor.p.r;
            
            result = simiam.test.week3.Part2Test.process_data(t, app.simulator_.time_step, r, y);
            
            fprintf('Test: (x_g,y_g)=(%0.3f,%0.3f); Result: (settle time, percent overshoot)=(%s)\n', x_g, y_g, result);
            
            app.ui_close();
        end
        
        function result = process_data(t, dt, r, y)
            p_diff = abs((r-y)./r);
            
            settle_time_k = -1;
            series_i = 0;
            series_i_max = 20;
            
            for k = 1:numel(t)
                if p_diff(k) < 0.1
                    series_i = series_i + 1;
                    if (series_i > series_i_max)
                        settle_time_k = k-series_i_max; 
                        break;
                    end
                else
                    series_i = 0;
                    settle_time_k = -1;
                end
            end
            
            fprintf('settle time: %0.3fs\n', settle_time_k*dt);
            
            [min_y, i] = min(y);
            po = abs(r(i)-min_y)/r(i);
            
            if isnan(po)
                po = 1.000;
            end
            
            fprintf('percent overshoot: %0.3f\n', abs(po));
            
            result = sprintf('%0.3f,%0.3f', settle_time_k*dt, abs(po));
        end
    end
    
end

