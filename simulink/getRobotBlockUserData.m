% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

function data = getRobotBlockUserData(modelHandle, robotID)

blockName = find_system(modelHandle,...
    'SearchDepth', 1, ...
    'MaskType', 'Khepera3', ...
    'robot_id', robotID);

if numel(blockName) == 0
    error('Cannot find KheperaIII Block for ''%s'' at top level of model', robotID);
elseif numel(blockName) > 1
    error('Multiple KheperaIII Blocks for ''%s''', robotID);
end

data = get_param(blockName, 'UserData');
if isempty(data)
   error('KheperaIII Block is not initialized'); 
end