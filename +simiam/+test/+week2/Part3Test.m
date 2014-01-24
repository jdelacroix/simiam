classdef Part3Test < simiam.test.PartTest

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
        
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)

            dist_1 = cell2mat(regexp(input, 'dist_1=[0-9]*.[0-9]*;', 'match'));
            dist_1 = str2double(dist_1(8:end-1));
            
            dist_2 = cell2mat(regexp(input, 'dist_2=[0-9]*.[0-9]*;', 'match'));
            dist_2 = str2double(dist_2(8:end-1));
            
            app = simiam.ui.AppWindow(root_path, 'testing');
            app.load_ui();
            
            robot_s = app.simulator_.world.robots.elementAt(1);
            
            ir_sensor = robot_s.robot.ir_array(1);
            
            ir_sensor.update_range(dist_1);
            ir_distances = robot_s.robot.get_ir_distances();
            
            ir_test_1 = (dist_1 - ir_distances(1))/dist_1;
            
            ir_sensor.update_range(dist_2);
            ir_distances = robot_s.robot.get_ir_distances();
            
            ir_test_2 = (dist_2 - ir_distances(1))/dist_2;
            
            
            
            result = sprintf('%0.3f,%0.3f', abs(ir_test_1), abs(ir_test_2));
            
            app.ui_close();
        end
    end
    
end

