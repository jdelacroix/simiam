classdef ArrayList < handle
    %ARRAYLIST A cell array implementation of java.util.ArrayList
    %   ArrayList(initialCapacity) mimics a fixed sized Java ArrayList
    %   using a cell array to store the data elements. initialCapacity must
    %   be greater than one and less than infinity.
    %
    %   % Example:
    %   %   Append, insert, and remove elements from the ArrayList.
    %   
    %   aList = containers.ArrayList(10);
    %   aList.appendElements(1);
    %   aList.appendElements({5,6,7,8,9,10});  % Multiple elements
    %                                          % must be appended as 
    %                                          % a cell array.
    %   aList.insertAtIndex(2, {2,3,4});
    %   numberTwoAndThree = aList.removeAtIndex(2:3);
    %   numberNineAndTen = aList.removeLastN(2);
    %   numberSeven = aList.removeElement(7);
    %
    %   ArrayList Methods:
    %       appendElement       - Append an element or elements to the end.
    %       elementAt           - Return the element at a specific index.
    %       insertAtIndex       - Insert an element at a specific index.
    %       isempty             - Returns true if the array is empty.
    %       lastElement         - Returns the last element.
    %       length              - Returns the number of elements.
    %       removeAtIndex       - Remove element at a specific index.
    %       removeElement       - Remove element from the array.
    %       removeFirstN        - Remove the first N elements.
    %       removeLast          - Remove the last element.
    %       removeLastN         - Remove the last N elements.
    %
    %  ArrayList Properties:
    %       Array               - Cell array storing all elements.
    %       Capacity            - The maximum, fixed capacity of the array.
    %       Count               - Number of elements in the array.
    
    % Copyright (C) 2013, Georgia Tech Research Corporation
    % see the LICENSE file included with this software
    
    properties (SetAccess = private)
        Count       % Number of elements in the array
        Capacity    % The maximum capacity of the array
    end
    
    properties (Access = private)
        Array       % Data structure in which elements are stored
    end
    
    methods
        
        
        function obj = ArrayList(initialCapacity)
            %% ARRAYLIST Constructor
            %   obj = ArrayList(initialCapacity) is the default constructor
            %   that creates an array list with a maximum, fixed capacity
            %   of initialCapacity elements.
            
            assert(all(imag(initialCapacity) == 0) && all(mod(initialCapacity,1) == 0), ...
                   'simiam:NotRealInteger', ...
                   'Initial capacity must be a real integer.')
            assert(initialCapacity > 0 && initialCapacity < Inf, ...
                   'simiam:OutOfBounds', ...
                   'Initial capacity must be greater than zero and less than infinity.');
            
            obj.Capacity = initialCapacity;
            obj.Array = cell(obj.Capacity, 1);
            obj.Count = 0;
        end
        
        
        function appendElement(obj, elementOrElements)
            %% APPENDELEMENT Append an element or elements to the end.
            %   appendElement(elementOrElements) appends an element or
            %   multiple elements to the end of the array. If multiple
            %   elements are appended, then they must be input as a cell
            %   array. An error is thrown if there is not enough space to
            %   append all of the elements.
            if iscell(elementOrElements)
                nElements = length(elementOrElements);
            else
                elementOrElements = {elementOrElements};
                nElements = 1;
            end
            assert(obj.Count+nElements <= obj.Capacity, ...
                   'simiam:NotEnoughSpace', ...
                   'Not enough space to append %d elements.', nElements);
%             assert(iscell(elementOrElements), ...
%                    'simiam:IncorrectDataType', ...
%                    'Input must be a cell array.');
            obj.Array(obj.Count+(1:nElements)) = elementOrElements;
            obj.Count = obj.Count+nElements;
        end
        
        function insertAtIndex(obj, elementOrElements, index)
            %% INSERTATINDEX Insert an element or elements at a specific index.
            %   insertAtIndex(elemntOrElments, index) inserts an element or
            %   multiple elements at a specific index in the range
            %   [1,min(obj.Count+1,obj.Capacity]. If multiple elements are
            %   inserted, then they must be input as a cell array. An error
            %   is thrown if there is not enough space to insert all of the
            %   elements.
            
            if iscell(elementOrElements)
                nElements = length(elementOrElements);
            else
                elementOrElements = {elementOrElements};
                nElements = 1;
            end
            assert(obj.Count+nElements <= obj.Capacity, ...
                   'simiam:NotEnoughSpace', ...
                   'Not enough space to insert %d elements.', nElements);
%             assert(iscell(elementOrElements), ...
%                    'simiam:IncorrectDataType', ...
%                    'Input must be a cell array.');
            obj.validateIndex(index);
            
            obj.Array(obj.Count+(1:nElements)) = obj.Array(index:obj.Count);
            obj.Array(index+{1:nElements}) = elementOrElements;
            obj.Count = obj.Count+nElements;
        end
        
        function elementOrElements = removeAtIndex(obj, indexOrIndices)
            %% REMOVEATINDEX Remove element(s) at a specific index or indicies.
            %   elementOrElements = removeAtIndex(indexOrIndicies) removes
            %   and returns the elements located at a specific index or
            %   indicies. An error is thrown if there are not enough
            %   elements in the array to remove or the indices are out of
            %   bounds.
            
            nElements = length(indexOrIndices);
            assert(obj.Count-nElements >= 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot remove more elements than are currently in the array.');
            obj.validateIndex(indexOrIndices);
            elementOrElements = cell(nElements, 1);
            
            [sortedIndices, sortIndex] = sort(indexOrIndices, 'descend');
            for i = 1:nElements
                index = sortedIndices(i);
                elementOrElements{sortIndex(i)} = obj.Array{index};
                for j = (index+1):obj.Count
                    obj.Array{j-1} = obj.Array{j};
                end
                obj.Array{obj.Count} = [];
                obj.Count = obj.Count-1;
            end
        end
        
        function removeElement(obj, elementOrElements)
            %% REMOVEELEMENT Remove element(s) from the array.
            %   removeElement(elementOrElements) removes the elements 
            %   specified in the input if they are found. An error is 
            %   thrown if there are not enough elements in the array 
            %   to remove.
            
            nElements = length(elementOrElements);
            assert(obj.Count-nElements >= 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot remove more elements than are currently in the array.');
            for i = 1:obj.Count
                if(any(obj.Array(i) == elementOrElements))
                    obj.removeAtIndex(i);
                    break;
                end
            end
        end
        
        function element = removeLast(obj)
            %% REMOVELAST Remove the last element.
            %   element = removeLast() removes the last element from the
            %   array. An error is thrown if the array is empty.
            
            assert(obj.Count > 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot remove from an empty array.');
            element = obj.removeAtIndex(obj.Count);
        end
        
        function elements = removeLastN(obj, nElements)
            %% REMOVELASTN Removes the last N elements.
            %   elements = removeLastN(nElements) removes the last N
            %   elements from the array. An error is thrown if there are
            %   not enough elements to remove.
            
            assert(obj.Count-nElements >=0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot remove more elements than are currently in the array.');
            elements = obj.removeAtIndex((obj.Count-nElements):obj.Count);
        end
        
        function elements = removeFirstN(obj, nElements)
            %% REMOVEFIRSTN Removes the first N elements
            %   elements = removeFirstN(nElements) removes the first N
            %   elements from the array. An error is thrown if there are
            %   not enough elements to remove.
            
            assert(obj.Count-nElements >= 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot remove more elements than are currently in the array.');
            elements = obj.removeAtIndex(1:nElements);
        end
        
        function count = length(obj)
            %% LENGTH Returns the number of elements.
            %   count = length() returns the number of elements currently
            %   stored in the array.
            
            count = obj.Count;
        end
        
        function bool = isempty(obj)
            %% ISEMPTY Returns true if the array is empty.
            %   bool = isempty() returns true if the array is empty, false
            %   otherwise.
            
            bool = (obj.Count == 0);
        end
        
        function element = lastElement(obj)
            %% LASTELEMENT Returns the last element.
            %   element = lastElement() returns the last element in the
            %   array. An error is thrown if there are no elements stored
            %   in the array.
            
            assert(obj.Count > 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot fetch from an empty array.');
            element = obj.Array{obj.Count};
        end
    
        function elementOrElements = elementAt(obj, indexOrIndices)
            %% ELEMENTAT Return the element at the specific index.
            %   elementOrElements = elementAt(indexOrIndicies)returns the
            %   element or elements at the specific index or indicies. An
            %   error is thrown if the array is empty.
            
            assert(obj.Count > 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot fetch from an empty array.');
            obj.validateIndex(indexOrIndices);
            if length(indexOrIndices) > 1
                elementOrElements = obj.Array(indexOrIndices);
            else
                elementOrElements = obj.Array{indexOrIndices};
            end
        end
        
        function replaceElementAt(obj, element, index)
            %% REPLACEELEMENTAT Replaces the element at the specific index.
            %   replaceElementAt(element, index) replaces the
            %   element or elements at the specific index or indicies. An
            %   error is thrown if the array is empty.
            
            assert(obj.Count > 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot fetch from an empty array.');
            obj.validateIndex(index);
            obj.Array{index} = element;
        end
        
        function elementOrElements = allElements(obj)
            assert(obj.Count > 0, ...
                   'simiam:NotEnoughElementsLeft', ...
                   'Cannot fetch from an empty array.');
            elementOrElements = obj.Array(1:obj.Count);   
        end
        
        function disp(obj)
            %% DISP Display the cell array.
            %   disp() displays the contents of the cell array.
            
            disp(obj.Array);
        end
        
    end
    
    methods (Access = private)
        
        function validateIndex(obj, indexOrIndices)
            %% VALIDATEINDEX Validate the index based on the properties of the array.
            %   validateIndex(indexOrIndices) throws an error if the index
            %   or indices are not positive, real integers than are
            %   not within the bounds of the array.
            
            assert(all(imag(indexOrIndices) == 0) && all(mod(indexOrIndices,1) == 0), ...
                   'simiam:NotRealInteger', ...
                   'index must be a real integer.')
            assert(all(indexOrIndices > 0) && all(indexOrIndices <= min(obj.Count+1, obj.Capacity)), ...
                   'simiam:OutOfBounds', ...
                   'index must be within bounds of the array.');
        end
        
    end
end