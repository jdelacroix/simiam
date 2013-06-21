classdef ControlApp < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        supervisors
        timeout
        time
        goals
        index
        root
        leader
        follower
    end
    
    methods
        function obj = ControlApp(root)
            obj.supervisors = mcodekit.list.dl_list();
            obj.time = 0;
            obj.root = root;
        end
        
        function run(obj, dt)
            [x, y, theta] = obj.leader.unpack();
            [xf, yf, thetaf] = obj.follower.unpack();
            u = [xf-x; yf-y];
            theta_d = atan2(u(2),u(1));
            
            x_n = x+0.25*cos(theta_d);
            y_n = y+0.25*sin(theta_d);
            obj.supervisors.head_.next_.key_.goal = [x_n; y_n];
        end
        
        function ui_press_mouse(obj, click_src)
            obj.supervisors.head_.key_.goal = click_src;
        end
    end
    
end
