classdef Pose2D < handle
    
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        x
        y
        theta
    end
    
    properties (Dependent = true)
        state
    end
    
    methods
        function obj = Pose2D(x, y, theta)
           obj.x = x;
           obj.y = y;
           obj.theta = theta;
        end
        
        function set.state(obj, val)
            assert(size(val) == [1,3], 'invalid format: expected [x, y, theta]');
            obj.x = val(1);
            obj.y = val(2);
            obj.theta = val(3);
        end
        
        function val = get.state(obj)
            val = [obj.x obj.y obj.theta];
        end
        
        function T = transformationMatrix(obj)
            T = [ cos(obj.theta) -sin(obj.theta) obj.x;
                  sin(obj.theta)  cos(obj.theta) obj.y;
                               0               0     1];
        end
    end
end