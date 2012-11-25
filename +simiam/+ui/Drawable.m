classdef Drawable < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        surfaces
        parent
    end
    
    properties (Access = protected)
        pose
    end
    
    methods
        function obj = Drawable(parent, pose)
           obj.pose = pose;
           obj.parent = parent;
           obj.surfaces = mcodekit.list.dl_list();
        end
    end
    
    methods (Access = protected)
        function update_pose(obj, pose)
           obj.pose.set_pose(pose);
           obj.draw_surfaces();
        end
        
        function add_surface(obj, geometry, color)
            surface_g = geometry;
            T = obj.pose.get_transformation_matrix();
            surface_h = patch('Parent', obj.parent, ...
                            'Vertices', geometry*T', ...
                            'Faces', 1:size(geometry,1), ...
                            'FaceColor', 'flat', ...
                            'FaceVertexCData', color);
            surface = struct('geometry', surface_g, 'handle', surface_h);
            obj.surfaces.append_key(surface);
        end
        
        function draw_surfaces(obj)
            T = obj.pose.get_transformation_matrix();
            i = obj.surfaces.get_iterator();
            while(i.has_next())
                surface = i.next();
                set(surface.handle, 'Vertices', surface.geometry*T');
            end
        end
    end
end

