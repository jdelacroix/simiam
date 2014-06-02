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
            % nothing to do here
        end
        
        function ui_press_mouse(obj, click_src)
            % nothing to do here
        end
    end
    
end
