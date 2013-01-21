classdef ControlApp < handle

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
        function obj = ControlApp()
            obj.supervisors = mcodekit.list.dl_list();
            obj.time = 0;
        end
        
        function run(obj, dt)
            
        end
    end
    
end

