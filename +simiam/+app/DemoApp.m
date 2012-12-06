classdef DemoApp < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        supervisors
    end
    
    methods
        function obj = DemoApp()
            obj.supervisors = mcodekit.list.dl_list();
        end
        
        function run(obj, dt)
            
        end
        
        function ui_press_mouse(obj, click_src)
            obj.supervisors.head_.key_.goal = click_src;
        end
    end
    
end

