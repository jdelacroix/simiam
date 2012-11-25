classdef (Abstract) Dynamics < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        
    end
    
    methods (Abstract)
        pose_t_1 = apply_dynamics(obj, pose_t, dt)
    end
    
end

