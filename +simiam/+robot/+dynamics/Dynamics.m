classdef Dynamics < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        options
    end
    
    methods
        
        function obj = Dynamics()
            obj.options = odeset('RelTol',1e-3,'AbsTol',1e-6);
        end
        
        function pose_t_1 = apply_dynamics(obj, pose_t, dt)

        end
    end
    
end

