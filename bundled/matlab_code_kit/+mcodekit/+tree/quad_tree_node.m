classdef quad_tree_node < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        parent_
        node_capacity_
        max_depth_
        depth_
        geometry_
        quads_ = mcodekit.tree.quad_tree_node.empty(1,0);
        point_count_
        partitioned_
        points_ = mcodekit.tree.quad_tree_point.empty(1,0);
    end
    
    methods
        
        function obj = quad_tree_node(qt_parent, qt_depth, qt_node_capacity, qt_max_depth, qt_geometry)
            obj.parent_ = qt_parent;
            obj.depth_ = qt_depth;
            obj.node_capacity_ = qt_node_capacity;
            obj.max_depth_ = qt_max_depth;
            obj.geometry_ = mcodekit.tree.quad_tree_quad(qt_parent, qt_geometry);
            obj.point_count_ = 0;
            obj.partitioned_ = false;
        end
        
        function bool = insert_point(obj, qt_point)
            bool = false;
            if(obj.geometry_.point_in_quad(qt_point))
                
                if(obj.point_count_ < obj.node_capacity_)
                    obj.points_(obj.point_count_+1) = qt_point;
                    bool = true;
                    obj.point_count_ = obj.point_count_+1;
                else
                    if(~obj.partitioned_)
                        obj.partitioned_ = obj.partition_quad();
                    end
                    
                    if(obj.partitioned_)
                        bool = obj.push_down_point(qt_point);
                    end
                end
                
            end
        end
        
        function bool = partition_quad(obj)
            if(obj.depth_ < obj.max_depth_)
                quad = obj.geometry_;

                sub_geometry = [quad.x_ quad.y_ quad.width_/2 quad.height_/2];
                obj.quads_(1) = mcodekit.tree.quad_tree_node(obj.parent_, obj.depth_+1, obj.node_capacity_, obj.max_depth_, sub_geometry);
                
                sub_geometry = [quad.x_+quad.width_/2 quad.y_ quad.width_/2 quad.height_/2];
                obj.quads_(2) = mcodekit.tree.quad_tree_node(obj.parent_, obj.depth_+1, obj.node_capacity_, obj.max_depth_, sub_geometry);

                sub_geometry = [quad.x_ quad.y_+quad.height_/2 quad.width_/2 quad.height_/2];
                obj.quads_(3) = mcodekit.tree.quad_tree_node(obj.parent_, obj.depth_+1, obj.node_capacity_, obj.max_depth_, sub_geometry);

                sub_geometry = [quad.x_+quad.width_/2 quad.y_+quad.height_/2 quad.width_/2 quad.height_/2];
                obj.quads_(4) = mcodekit.tree.quad_tree_node(obj.parent_, obj.depth_+1, obj.node_capacity_, obj.max_depth_, sub_geometry);
                
                for i=1:length(obj.points_)
                    bool = obj.push_down_point(obj.points_(i));
                    if(~bool)
                        error('something is not right');
                    end
                end
            else
                bool = false;
            end
        end
        
        function bool = push_down_point(obj, qt_point)
            bool = false;
            for i=1:4
                bool = obj.quads_(i).insert_point(qt_point);
                if(bool)
                    break;
                end
            end
        end
    
    end
end
