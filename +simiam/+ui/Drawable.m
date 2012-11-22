classdef Drawable < handle
%DRAWABLE Summary of this class goes here
%   Detailed explanation goes here

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties (SetAccess = protected)
        parent
        
        x
        y
        theta
        
        surfaces
    end
    
    methods
        function obj = Drawable(parent, x, y, theta)
           obj.x = x;
           obj.y = y;
           obj.theta = theta;
           obj.parent = parent;
           
           obj.surfaces = dl_list();
        end
        
        function updatePose(obj, x, y, theta)
           obj.x = x;
           obj.y = y;
           obj.theta = theta;
           obj.drawSurfaces();
        end
        
        function addSurface(obj, geometry, color)
            surface_g = geometry;
            T = obj.transformationMatrix();
            surface_h = patch('Parent', obj.parent, ...
                            'Vertices', T*geometry, ...
                            'Faces', 1:size(geometry,1), ...
                            'FaceColor', 'flat', ...
                            'FaceVertexCData', color);
            surface = struct('geometry', surface_g, 'handle', surface_h);
            obj.surfaces.append_key(surface);
        end
        
        function drawSurfaces(obj)
            T = obj.transformationMatrix();
            i = obj.surfaces.get_iterator();
            while(i.has_next())
                surface = i.next();
                set(surface.handle, 'Vertices', T*surface.geometry);
            end
        end
        
        function T = transformationMatrix(obj)
            T = [ cos(obj.theta) -sin(obj.theta) obj.x;
                  sin(obj.theta)  cos(obj.theta) obj.y;
                               0               0     1];
        end
    end
end

