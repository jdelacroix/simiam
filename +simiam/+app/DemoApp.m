classdef DemoApp < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        supervisors
        timeout
        time
        goals
        index
    end
    
    methods
        function obj = DemoApp()
            obj.supervisors = mcodekit.list.dl_list();
            obj.time = 0;
            obj.timeout = 5;
        end
        
        function run(obj, dt)
            s = obj.supervisors.head_.key_;
            if (s.reached_goal)
                obj.time = obj.time + dt;
                if (obj.time > obj.timeout && s.reached_goal)
                    s.goal = [-5 -5];
                    s.set_current_controller(1);
                end
            end
        end
        
        function ui_press_mouse(obj, click_src)
            s = obj.supervisors.head_.key_;
            s.set_current_controller(3);
            s.goal = click_src;
            s.reached_goal = false;
            obj.time = 0;
        end
    end
    
end

