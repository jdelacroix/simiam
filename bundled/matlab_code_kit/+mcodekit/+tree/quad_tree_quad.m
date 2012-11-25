classdef quad_tree_quad < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        x_
        y_
        width_
        height_
        cx_
        cy_
        side_ab_
        side_ad_
        gfx_
    end
    
    methods
        function obj = quad_tree_quad(parent, qt_geometry)
            assert(min(size(qt_geometry)==[1,4])', 'quad geometry must be [x, y, width, height]');
            obj.x_ = qt_geometry(1);
            obj.y_ = qt_geometry(2);
            assert(qt_geometry(3) > 0, 'width must be positive');
            obj.width_ = qt_geometry(3);
            assert(qt_geometry(4) > 0, 'height must be positive');
            obj.height_ = qt_geometry(4);
            
            obj.cx_ = obj.x_ + obj.width_/2;
            obj.cy_ = obj.y_ + obj.height_/2;
            
            obj.side_ab_ = [obj.width_ 0];
            obj.side_ad_ = [0 obj.height_];
            
            obj.gfx_ = rectangle('Parent', parent, 'Position', qt_geometry, 'EdgeColor', 'r');
        end
        
        function geom = to_geometry(obj)
            geom = [obj.x_ obj.y_ obj.width_ obj.height_];
        end
        
        function bool = point_in_quad(obj, qt_point)
            v_p = [qt_point.x_ qt_point.y_];
            
            v_ab = obj.side_ab_;
            v_ad = obj.side_ad_;
            
            v_ap = v_p-[obj.x_ obj.y_];
            
            dot_ap_ab = dot(v_ap,v_ab);
            dot_ab_ab = dot(v_ab,v_ab);
            dot_ap_ad = dot(v_ap,v_ad);
            dot_ad_ad = dot(v_ad,v_ad);
            
            bool = (0<=dot_ap_ab) && (dot_ap_ab<=dot_ab_ab) && (0<=dot_ap_ad) && (dot_ap_ad<=dot_ad_ad);
        end
    end
    
end