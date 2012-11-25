classdef Drawable < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties (SetAccess = protected)
        parent
        pose
        surfaces
    end
    
    methods
        function obj = Drawable(parent, x, y, theta)
           obj.pose = simiam.ui.Pose2D(x, y, theta);
           obj.parent = parent;
           
           obj.surfaces = dl_list();
        end
        
        function updatePose(obj, x, y, theta)
           obj.pose.state = [x y theta];
           obj.drawSurfaces();
        end
        
        function addSurface(obj, geometry, color)
            surface_g = geometry;
            T = obj.pose.transformationMatrix();
            surface_h = patch('Parent', obj.parent, ...
                            'Vertices', geometry*T', ...
                            'Faces', 1:size(geometry,1), ...
                            'FaceColor', 'flat', ...
                            'FaceVertexCData', color);
            surface = struct('geometry', surface_g, 'handle', surface_h);
            obj.surfaces.append_key(surface);
        end
        
        function drawSurfaces(obj)
            T = obj.pose.transformationMatrix();
            i = obj.surfaces.get_iterator();
            while(i.has_next())
                surface = i.next();
                set(surface.handle, 'Vertices', surface.geometry*T');
            end
        end
    end
    
    methods (Static)
        function rad = deg2rad(deg)
           rad = deg*pi/180; 
        end
    end
end

