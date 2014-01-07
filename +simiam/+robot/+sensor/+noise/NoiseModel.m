classdef NoiseModel < handle
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
    
    end
    
    methods (Abstract)
        
        apply_noise(obj, data)
    
    end
    
end