classdef Queue < simiam.containers.ArrayList
    %QUEUE A first-in, first-out (FIFO) queue implementation.
    %   Queue(initialCapacity) is a first-in, first-out queue
    %   implementation based on ArrayList with a maximum, fixed capacity
    %   specified by initialCapacity.
    %
    %   % Example
    %   %   aQueue = containers.Queue(5);
    %   %   aQueue.enqueue(1);
    %   %   aQueue.enqueue({2,3,4,5,6});    % When enqueuing elements
    %   %                                   % beyond the capacity of the
    %   %                                   % queue, overflow is discarded.
    %   %   numberTwoAndThree = aQueue.dequeue(2); 
    %
    %   Queue Methods:
    %       enqueue     - Insert elements into the queue.
    %       dequeue     - Remove elements from the queue.
    %
    %   See also containers.ArrayList.
    
    % Copyright (C) 2013, Georgia Tech Research Corporation
    % see the LICENSE file included with this software
    
    properties
    end
    
    methods
        
        function obj = Queue(initialCapacity)
            %% QUEUE Constructor
            %   obj = Queue(initialCapacity) creates a queue with a
            %   maximum, fixed capacity.
            
            obj = obj@simiam.containers.ArrayList(initialCapacity);
        end
        
        function enqueue(obj, elementOrElements)
            %% ENQUEUE Insert elements into the queue.
            %   enqueue(elementOrElements) inserts an element or multiple
            %   elements provided in a cell array into the queue. Any
            %   elements already in the list that need to be removed to
            %   make space for the new elements are discarded.
            
            nElements = length(elementOrElements);
            nOverflow = nElements+obj.Count-obj.Capacity;
            if nOverflow > 0
                obj.removeFirstN(nOverflow);
            end
            obj.appendElement(elementOrElements);
        end
        
        function elementOrElements = dequeue(obj, nElements)
            %% DEQUEUE Remove elements from the queue.
            %   elementOrElements = dequeue(nElements) removes N elements
            %   from the queue. An error is thrown if there are not enough
            %   elements in the queue to remove.
            
            assert(obj.Count-nElements >= 0, 'Cannot dequeue more elements than are currently in the queue.');
            elementOrElements = obj.removeFirstN(nElements);
        end
        
    end
    
end

