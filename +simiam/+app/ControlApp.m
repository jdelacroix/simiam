classdef ControlApp < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        supervisors
        root
    end
    
    methods
        function obj = ControlApp(root)
            obj.supervisors = simiam.containers.ArrayList(5);
            obj.root = root;
        end
        
        function run(obj, dt)

        end
    end
    
end
