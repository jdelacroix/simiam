classdef lcrs_tree_node < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        parent_
        left_child_
        right_sibling_
        key_
        depth_
    end
    
    methods
        
        function obj = lcrs_tree_node(varargin)
            switch nargin
                case 1
                    obj.parent_ = [];
                    obj.key_ = varargin{1};
                    obj.depth_ = 0;
                case 2
                    obj.parent_ = varargin{1};
                    obj.key_ = varargin{2};
                    obj.depth_ = obj.parent_.depth_+1;
                otherwise
                    error('Wrong number of arguments.');
            end
            obj.left_child_ = [];
            obj.right_sibling_ = [];
        end
        
        function add_child(obj, child)
            if(isempty(obj.left_child_))
                obj.left_child_ = child;
            else
                obj.left_child_.add_sibling(child);
            end
        end
        
        function add_sibling(obj, sibling)
            if(isempty(obj.right_sibling_))
                obj.right_sibling_ = sibling;
            else
                obj.right_sibling_.add_sibling(sibling);
            end
        end
        
    end
    
end

