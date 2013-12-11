classdef ControlApp < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        supervisors
        root
    end
    
    methods
        function obj = ControlApp(root)
            obj.supervisors = simiam.containers.ArrayList(2);
            obj.root = root;
        end
        
        function run(obj, dt)
%             aLeaderRobot = obj.supervisors.elementAt(1);
%             aFollowerRobot = obj.supervisors.elementAt(2);
            
%             [x, y, theta] = aLeaderRobot.state_estimate.unpack();
%             [xf, yf, thetaf] = aFollowerRobot.state_estimate.unpack();
%             u = [xf-x; yf-y];
%             theta_d = atan2(u(2),u(1));
            
%             x_n = x+0.25*cos(theta_d);
%             y_n = y+0.25*sin(theta_d);
%             aFollower = obj.supervisors.elementAt(2);
%             aFollower.goal = [x_n; y_n];
        end
        
        function ui_press_mouse(obj, click_src)
%             aLeader = obj.supervisors.elementAt(1);
%             aLeader.goal = click_src;
        end
    end
    
end
