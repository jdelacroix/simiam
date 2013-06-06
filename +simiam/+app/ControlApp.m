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
    end
    
    methods
        function obj = ControlApp(root)
            obj.supervisors = simiam.containers.ArrayList(10);
            obj.time = 0;
            obj.root = root;
        end
        
        function run(obj, dt)
            [x, y, theta] = obj.supervisors.elementAt(1).state_estimate.unpack();
            
            nRobots = length(obj.supervisors);
            
            for i = 2:nRobots
                [xf, yf, thetaf] = obj.supervisors.elementAt(i).state_estimate.unpack();
                u = [xf-x; yf-y];
                theta_o = atan2(u(2), u(1));
                d = 0.3;
                obj.supervisors.elementAt(i).goal = [x+d*cos(theta_o); y+d*sin(theta_o)];
            end
            
        end
        
        function ui_press_mouse(obj, click_src)
            obj.supervisors.elementAt(1).goal = click_src;
        end
    end
    
end