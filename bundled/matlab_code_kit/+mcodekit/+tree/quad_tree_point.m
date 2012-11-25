classdef quad_tree_point < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        x_
        y_
        gfx_
    end
    
    methods
        function obj = quad_tree_point(parent, qt_geometry)
           assert(min(size(qt_geometry)==[1,2]), 'point geometry must be [x, y]');
           obj.x_ = qt_geometry(1);
           obj.y_ = qt_geometry(2);
           if(~isempty(parent))
                obj.gfx_ = plot(parent, obj.x_, obj.y_, 'bo-', 'MarkerFaceColor', 'b');
           end
        end
            
    end
    
end
