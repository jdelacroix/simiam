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
        theta_o
    end
    
    methods
        function obj = ControlApp(root)
            obj.supervisors = simiam.containers.ArrayList(10);
            obj.time = 0;
            obj.root = root;
        end
        
        function run(obj, dt)
            robot = obj.supervisors.elementAt(1);
            [x, y, theta] = robot.state_estimate.unpack();
            robot.controllers{4}.v_max = 0;
            robot.controllers{4}.alpha = 0.25;
            robot.controllers{4}.Kp = 12;
            robot.d_pursue = 0;
            
            is_init = ~all(robot.goal == [0;0]);
            robot.is_init = is_init;
            
            nRobots = length(obj.supervisors);
            
            for i = 2:nRobots
                robot = obj.supervisors.elementAt(i);
                [xf, yf, thetaf] = robot.state_estimate.unpack();
                robot.is_init = is_init;
                u = [xf-x; yf-y];
                d = sqrt(u(1)^2+u(2)^2);
                
                if (d < 1)
                    robot.controllers{4}.v_max = 0.3;
                    robot.controllers{4}.alpha = 0.2;
                    robot.controllers{4}.Kp = 4;
                    obj.theta_o = atan2(u(2), u(1));
                    d = 0;
                elseif (d > 1.1)
                    robot.controllers{4}.v_max = 0.15;
                    robot.controllers{4}.alpha = 0.2;
                    robot.controllers{4}.Kp = 8;
                    obj.theta_o = atan2(u(2), u(1)) + (-pi/2+pi/4*(randi(5,1)-1));
                end
%                 u = [xf-x; yf-y];
%                 theta_o = atan2(u(2), u(1));
%                 theta_o = atan2(sin(theta_o), cos(theta_o));
%                 d = 0.00;
%                 obj.supervisors.elementAt(i).goal = [x+d*cos(theta_o); y+d*sin(theta_o)];
                d = 2/3*d;
                obj.theta_o = atan2(sin(obj.theta_o), cos(obj.theta_o));
                obj.supervisors.elementAt(i).goal = [x+d*cos(obj.theta_o); y+d*sin(obj.theta_o)];
            end
            
        end
        
        function ui_press_mouse(obj, click_src)
            obj.supervisors.elementAt(1).goal = click_src;
        end
    end
    
end