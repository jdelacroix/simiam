classdef Mutex < handle

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties (Access = private)
        handle
    end
    
    methods 
        
        function obj = Mutex()
            obj.handle = figure('Visible', 'off', 'UserData', []);
        end
        
        function acquire(obj, owner)
%             if (get(obj.handle, 'UserData') == owner)
%                 fprintf('You have already acquired this mutex.\n');
%             else
                waitfor(obj.handle, 'UserData', []);
                set(obj.handle, 'UserData', owner);
%             end
        end
        
        function release(obj, owner)
            if (get(obj.handle, 'UserData') == owner)
                set(obj.handle, 'UserData', []);
            else
                fprintf('You do not own this mutex, so you cannot release it.\n');
            end
        end
    end
    
end

