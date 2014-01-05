classdef GaussianNoise < simiam.robot.sensor.noise.NoiseModel
    
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        mean
        standard_deviation
    end
    
    methods
        
        function obj = GaussianNoise(mean, sigma)
            obj.mean = mean;
            obj.standard_deviation = sigma;
        end
        
        function data_with_noise = apply_noise(obj, data)
            noise = obj.mean + obj.standard_deviation*randn(size(data));
            data_with_noise = data + noise;
        end
    end
    
end

