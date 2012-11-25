classdef lcrs_tree < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        root_
        height_
    end
    
    methods
        
        function obj = lcrs_tree(varargin)
            switch nargin
                case 0
                    obj.root_ = [];
                    obj.height_ = -1;
                case 1
                    if(isa(varargin{1},'lrcs_tree_node'))
                        obj.root_ = varargin{1};
                    else
                        obj.root_ = mcodekit.tree.lcrs_tree_node(varargin{1});
                    end
                    obj.height_ = 0;
                otherwise
                    error('Wrong number of arguments.');
            end
        end
        
        function add_node(obj, varargin)
            switch size(varargin,2)
                case 1
                    child = varargin{1};
                case 2
                    parent = varargin{1};
                    child = varargin{2};
                    child.parent_ = parent;
                    child.depth_ = parent.depth_+1;
                otherwise
                    error('Wrong number of parameters.');
            end
            child.parent_.add_child(child);
            if(child.depth_ > obj.height_)
                obj.height_ = child.depth_;
            end
        end
        
    end
    
end