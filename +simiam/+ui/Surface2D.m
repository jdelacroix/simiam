classdef Surface2D < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        centroid_
        geometry_
        handle_
        geometric_span_
        edge_set_
    end
    
    properties (Access = private)
        vertex_set_
        is_drawable_
    end
    
    methods
        function obj = Surface2D(varargin)
            switch(nargin)
                case 1,
                    obj.geometry_ = varargin{1};
                    obj.is_drawable_ = false;
                case 2,
                    obj.handle_ = varargin{1};
                    obj.geometry_ = varargin{2};
                    obj.is_drawable_ = true;
                otherwise
                    error('expected 1 or 2 arguments');
            end
            obj.vertex_set_ = obj.geometry_;
            
            % compute the surface's centroid
%             obj.centroid_ = mean(obj.geometry_(:,1:2));
            n = size(obj.geometry_,1);
            obj.centroid_ = sum(obj.geometry_(:,1:2),1)/n;
            
            % compute the surface's geometric span
            obj.geometric_span_ = 2*max(sqrt((obj.geometry_(:,1)-obj.centroid_(1)).^2+(obj.geometry_(:,2)-obj.centroid_(2)).^2));
            
            obj.edge_set_ = [obj.geometry_(:,1:2) obj.geometry_([2:n,1],1:2)];
        end
        
        function transform_surface(obj, T)
            obj.geometry_ = obj.vertex_set_*T';
            n = size(obj.geometry_,1);
            obj.edge_set_(:,1:2) = obj.geometry_(:,1:2);
            obj.edge_set_(:,3:4) = obj.geometry_([2:n,1],1:2);
%             obj.edge_set_(:,3:4) = circshift(obj.geometry_(:,1:2),-1);
            obj.centroid_ = sum(obj.geometry_(:,1:2),1)/n;
            if(obj.is_drawable_)
                set(obj.handle_, 'Vertices', obj.geometry_);
            end
        end
        
        function set_drawability(obj, is_drawable)
            obj.is_drawable_ = is_drawable;
        end
        
        function update_geometry(obj, geometry)
            obj.vertex_set_ = geometry;
%             obj.centroid_ = sum(obj.geometry_(:,1:2),1)/size(obj.geometry_,1);
%             obj.geometric_span_ = 2*max(sqrt((obj.geometry_(:,1)-obj.centroid_(1)).^2+(obj.geometry_(:,2)-obj.centroid_(2)).^2));
%             obj.geometric_span_ = 2*max(sqrt((obj.vertex_set_(:,1)-obj.centroid_(1)).^2+(obj.vertex_set_(:,2)-obj.centroid_(2)).^2));
        end
        
        function bool = precheck_surface(obj, surface)
            d = sqrt((obj.centroid_(1)-surface.centroid_(1))^2+(obj.centroid_(2)-surface.centroid_(2))^2);
%             bool = (d < (obj.geometric_span_+surface.geometric_span_)/sqrt(3));
            bool = (d < (obj.geometric_span_+surface.geometric_span_)/1.7321);
        end
        
        function points = intersection_with_surface(obj, surface)
            edge_set_a = obj.edge_set_;
            edge_set_b = surface.edge_set_';
            
            n_edges_a = size(edge_set_a,1);
            n_edges_b = size(edge_set_b,2);
            
            index_a = ones(1,n_edges_a);
            index_b = ones(n_edges_b, 1);
            
            m_x_1 = edge_set_a(:,1*index_b);
            m_x_2 = edge_set_a(:,3*index_b);
            m_x_3 = edge_set_b(1*index_a,:);
            m_x_4 = edge_set_b(3*index_a,:);
            
            m_y_1 = edge_set_a(:,2*index_b);
            m_y_2 = edge_set_a(:,4*index_b);
            m_y_3 = edge_set_b(2*index_a,:);
            m_y_4 = edge_set_b(4*index_a,:);
          
            m_y_13 = (m_y_1-m_y_3);
            m_x_13 = (m_x_1-m_x_3);
            m_x_21 = (m_x_2-m_x_1);
            m_y_21 = (m_y_2-m_y_1);    
            m_x_43 = (m_x_4-m_x_3);
            m_y_43 = (m_y_4-m_y_3);
            
            n_edge_a = (m_x_43.*m_y_13)-(m_y_43.*m_x_13);
            n_edge_b = (m_x_21.*m_y_13)-(m_y_21.*m_x_13);
            d_edge_ab = (m_y_43.*m_x_21)-(m_x_43.*m_y_21);
            
            u_a = (n_edge_a./d_edge_ab);
            u_b = (n_edge_b./d_edge_ab);
            
            intersect_set_x = m_x_1+(m_x_21.*u_a);
            intersect_set_y = m_y_1+(m_y_21.*u_a);
            is_in_segment = (u_a >= 0) & (u_a <= 1) & (u_b >= 0) & (u_b <= 1);

            points = [intersect_set_x(is_in_segment) intersect_set_y(is_in_segment)];
        end
    end
end

