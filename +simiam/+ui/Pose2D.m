classdef Pose2D < handle
    
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        x
        y
        theta
    end
    
    methods
        function obj = Pose2D(x, y, theta)
           obj.x = x;
           obj.y = y;
           obj.theta = theta;
        end
        
        function set_pose(obj, array)
            obj.x = array(1);
            obj.y = array(2);
            obj.theta = array(3);
        end
        
        function set_pose_with_pose(obj, pose)
            obj.x = pose.x;
            obj.y = pose.y;
            obj.theta = pose.theta;
        end
        
        function [x, y, theta] = unpack(obj)
            x = obj.x;
            y = obj.y;
            theta = obj.theta;
        end
        
        function T = get_transformation_matrix(obj)
            T = [ cos(obj.theta) -sin(obj.theta) obj.x;
                  sin(obj.theta)  cos(obj.theta) obj.y;
                               0               0     1];
        end
        
        function d = get_norm(obj, pose)
            d = sqrt((obj.x-pose.x)^2+(obj.y-pose.y)^2);
        end
    end
    
    methods (Static)
        function rad = deg2rad(deg)
            rad = deg*pi/180;
        end
        
        function deg = rad2deg(rad)
            deg = rad*180/pi;
        end
    end
end