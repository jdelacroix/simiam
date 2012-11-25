classdef WheelEncoder < handle
    
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        type
        
        radius
        length
        ticks_per_rev
    end
    
    properties (Access = private)
        count
    end
    
    properties (Dependent = true)
       state 
    end
    
    methods
        function obj = WheelEncoder(type, radius, length, ticks_per_rev)
            obj.radius = radius;
            obj.length = length;
            obj.type = type;
            obj.ticks_per_rev = ticks_per_rev;
            obj.count = 0;
        end
        
        function set.state(obj, val)
            % input : wheel travel distance
            % output : encoder counts
            obj.count = ceil(val*obj.radius*obj.ticks_per_rev/(2*pi*obj.radius));
        end
        
        function val = get.state(obj)
            val = obj.count;
        end
    end
end

