classdef quad_tree < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        node_capacity_
        max_depth_
        root_
        depth_
        geometry_
        parent_
    end
    
    methods
        
        function obj = quad_tree(qt_geometry, qt_node_capacity, qt_max_depth)
            assert(qt_node_capacity > 0, 'node capacity must be larger than 0');
            obj.node_capacity_ = qt_node_capacity;
            
            assert(qt_max_depth > 0, 'maximum depth of tree must be larger than 0');
            obj.max_depth_ = qt_max_depth;
            
            assert(min(size(qt_geometry)==[1,4]), 'geometry must be defined as [x y width height]');            
            obj.depth_ = 1;
            
            qt_parent = axes();
            axis(qt_parent, 'square');
            hold(qt_parent, 'on');
            axis(qt_parent, [qt_geometry(1) qt_geometry(1)+qt_geometry(3) qt_geometry(2) qt_geometry(2)+qt_geometry(4)]);
            
            obj.root_ = mcodekit.tree.quad_tree_node(qt_parent, obj.depth_, qt_node_capacity, qt_max_depth, qt_geometry);
            obj.geometry_ = obj.root_.geometry_;
            obj.parent_ = qt_parent;
            set(obj.parent_, 'ButtonDownFcn', @obj.find_quad_by_click);
        end
        
        function insert_point(obj, qt_point)
            bool = obj.root_.insert_point(mcodekit.tree.quad_tree_point(obj.parent_,qt_point));
            if (~bool)
                error('point does not fit in tree');
            end
        end
        
        function find_fixed_radius_neighbors(obj, qt_point, qt_radius)
            t = mcodekit.tree.quad_tree_point(obj.parent_, qt_point);
            set(t.gfx_, 'MarkerFaceColor', 'k');
            set(t.gfx_, 'MarkerEdgeColor', 'k');
            
            theta = linspace(0, 2*pi, 2000);
            plot(obj.parent_, (qt_point(1)+qt_radius*cos(theta)), (qt_point(2)+qt_radius*sin(theta)), 'k-');
            
            q = mcodekit.queue.fifo_queue();
            q.enqueue(obj.root_);
            p = fifo_queue();
            while(~q.empty())
                node = q.dequeue();
                if(node.partitioned_)
                    for i=1:4
                        disp('enqueue?');
                        if (obj.circle_intersect_quad(qt_point, qt_radius, node.quads_(i).geometry_))
                            q.enqueue(node.quads_(i));
                            disp('yes!');
                        else
                            disp('no!');
                        end
                    end
                else
                    for i=1:node.point_count_
                        s = node.points_(i);
                        if (sqrt((s.x_-qt_point(1))^2+(s.y_-qt_point(2))^2) <= qt_radius)
                            p.enqueue(s);
                        end
                    end
                end
            end
            
            while(~p.empty())
                s = p.dequeue();
                set(s.gfx_, 'MarkerFaceColor', 'r');
                set(s.gfx_, 'MarkerEdgeColor', 'r');
            end
        end
        
        function bool = circle_intersect_quad(obj, qt_point, qt_radius, qt_quad)
            cd_x = abs(qt_point(1)-qt_quad.cx_);
            cd_y = abs(qt_point(2)-qt_quad.cy_);
            
            if (cd_x > (qt_quad.width_/2+qt_radius))
                bool = false;
                return;
            end
            
            if (cd_y > (qt_quad.height_/2+qt_radius))
                bool = false;
                return;
            end
            
            if (cd_x <= (qt_quad.width_/2))
                bool = true;
                return;
            end
            
            if (cd_y <= (qt_quad.height_/2))
                bool = true;
                return;
            end
            
            cd_sqr = sqrt((cd_x-qt_quad.width_/2)^2+(cd_y-qt_quad.height_/2)^2);
            
            bool = (cd_sqr <= qt_radius);         
        end
        
        function find_quad_by_click(obj, src, event)
            click = get(obj.parent_, 'CurrentPoint');
            click_src = click(1,1:2);
            p = mcodekit.tree.quad_tree_point([],click_src);
            
            q = obj.root_;
            while(q.partitioned_)
                for i=1:4
                    bool = q.quads_(i).geometry_.point_in_quad(p);
                    if(bool)
                        q = q.quads_(i);
                        break;
                    end
                end
            end
            
            for i=1:q.point_count_
                set(q.points_(i).gfx_, 'MarkerFaceColor', 'r');
                set(q.points_(i).gfx_, 'MarkerEdgeColor', 'r');
            end
            disp('check');
        end
        
        
    end
    
end