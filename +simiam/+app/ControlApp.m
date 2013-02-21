classdef ControlApp < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        supervisors
        timeout
        time
        goals
        index
    end
    
    methods
        function obj = ControlApp()
            obj.supervisors = mcodekit.list.dl_list();
            obj.time = 0;
        end
        
        function run(obj, dt)
            
        end
    end
    
end

