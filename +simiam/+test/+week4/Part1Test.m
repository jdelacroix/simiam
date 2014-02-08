classdef Part1Test < simiam.test.PartTest

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
            
            app.simulator_.step([],[]);
            
            ir_distances_wf = robot_s.supervisor.current_controller.apply_sensor_geometry([inputs.dist_1 0.3 0.3 inputs.dist_1 0.3], simiam.ui.Pose2D(inputs.x, inputs.y, inputs.theta));
            
            error_1 = norm(ir_distances_wf(:,1)-[ 0.3637; -0.0545]);
            error_2 = norm(ir_distances_wf(:,4)-[-0.0895; -0.2932]);
            
            % Export percent error between actual and estimated pose
            
            result = sprintf('%0.3f,%0.3f', error_1, error_2);
            
            close(get(robot_s.supervisor.p.a, 'Parent'));
            app.ui_close();
        end
    end
    
end

