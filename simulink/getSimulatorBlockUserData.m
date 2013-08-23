% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

function data = getSimulatorBlockUserData(modelHandle)

blockName = find_system(modelHandle,...
    'SearchDepth', 1, ...
    'MaskType', 'Simulator');

if numel(blockName) == 0
    error('Cannot find Simulator Block at top level of model');
elseif numel(blockName) > 1
    error('Multiple Simulator Blocks');
end

data = get_param(blockName, 'UserData');
if isempty(data)
   error('Simulator Block is not initialized'); 
end