classdef r_dense_tree < mcodekit.tree.lcrs_tree

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties

    end
    
    methods
        
        function obj = r_dense_tree()
            obj = obj@mcodekit.tree.lcrs_tree();
        end
        
        function seed_tree(obj, q_0)
            obj.root_ = q_0;
            obj.height_ = 0;
        end
        
        function grow_tree(obj, steps)
%             tglobal = tic;
            for i=1:steps
                q_rand = obj.rand_conf();
                [q_near, d] = obj.nearest_vertex(q_rand);
                q_new = obj.new_conf(q_near, q_rand);
                obj.add_node(q_near, q_new);
%                 telapsed = toc(tstart);
%                 fprintf('iteration %d, split %0.3f, time %0.3f\n', i, telapsed, toc(tglobal));
            end
        end
        
        function q_rand = rand_conf(obj)
            [m, n] = size(obj.root_.key_);
            q_rand = mcodekit.tree.lcrs_tree_node(rand(m,n));
        end
        
        function [q_near, d] = nearest_vertex(obj, q_rand)
            d = inf;
            q = mcodekit.queue.fifo_queue();
            q.enqueue(obj.root_);
            while(q.size_ > 0)
               v = q.dequeue();
               p = norm(q_rand.key_-v.key_);
               if(p < d)
                   q_near = v;
                   d = p;
               end
               
               if(~isempty(v.left_child_))
                   q.enqueue(v.left_child_);
               end
               
               if(~isempty(v.right_sibling_))
                   q.enqueue(v.right_sibling_);
               end
            end
        end
        
        function q_new = new_conf(obj, q_near, q_rand)
            u = q_rand.key_-q_near.key_;
            q_new = mcodekit.tree.lcrs_tree_node(q_near, q_near.key_+1/norm(u)*u);
        end
    end
    
end

