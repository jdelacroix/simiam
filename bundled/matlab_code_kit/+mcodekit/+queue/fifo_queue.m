classdef fifo_queue < mcodekit.list.dl_list

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
 
    properties
        
    end
    
    methods
        function obj = fifo_queue()
            obj = obj@mcodekit.list.dl_list();
        end
        
        function enqueue(obj, key)
            obj.insert_key(key, 1);
        end
        
        function key = dequeue(obj)
            key = obj.remove_key(obj.size_);
        end
        
        function bool = empty(obj)
            bool = (obj.size_ == 0);
        end
    end
    
end