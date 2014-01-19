classdef WheelEncoder < handle
    
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        type
        
        radius
        length
        ticks_per_rev
        
        ticks
        
        total_distance
    end
    
    methods
        function obj = WheelEncoder(type, radius, length, ticks_per_rev)
            obj.radius = radius;
            obj.length = length;
            obj.type = type;
            obj.ticks_per_rev = ticks_per_rev;
            obj.ticks = 0;
            obj.total_distance = 0;
        end
        
        function update_ticks(obj, wheel_velocity, dt)
            obj.ticks = obj.ticks + obj.distance_to_ticks(wheel_velocity*dt);
        end
        
        function reset_ticks(obj)
            obj.ticks = 0;
        end
        
        function ticks = distance_to_ticks(obj, distance)
            obj.total_distance = obj.total_distance + distance;
            ticks = round((obj.total_distance*obj.ticks_per_rev)/(2*pi));
            obj.total_distance = obj.total_distance - obj.ticks_to_distance(ticks);
        end
        
        function distance = ticks_to_distance(obj, ticks)
            distance = (ticks*2*pi)/obj.ticks_per_rev;
        end
    end
end

