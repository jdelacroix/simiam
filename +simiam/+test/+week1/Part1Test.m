classdef Part1Test < simiam.test.PartTest
    %PART1TEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function result = run_test(input, root_path)
            app = simiam.ui.AppWindow(root_path, false);
            app.load_ui();
            app.ui_button_start([],[]);
            app.ui_close();

            result = num2str(-1);
        end
    end
    
end

