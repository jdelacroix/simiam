% getSetupBlockUserData(modelHandle, arduinoVar)
%  Searches the model for the Arduino IO block specified by <arduinoVar> (e.g., 'Arduino1')
%  and returns the userdata of that block. Throws an error if there isn't a unique
%  match for the block or if the userdata is empty.
% 
%  modelHandle can be a string or a numeric handle 
%  arduinoVar is a string, corresponding to the arduinoVar parameter (e.g., 'Arduino1')
%
% Example:
%  customData = getSetupBlockUserData(bdroot(gcb), 'Arduino1');
%  customData = getSetupBlockUserData(bdroot(block.BlockHandle), block.DialogPrm(1).Data); % in a M S-fcn

%   Copyright 2011 The MathWorks, Inc.

function data = getRobotBlockUserData(modelHandle, robotID)

blockName = find_system(modelHandle,...
    'SearchDepth', 1, ...
    'MaskType', 'Khepera3', ...
    'robot_id', robotID);

if numel(blockName) == 0
    error('Cannot find KheperaIII Block for ''%s'' at top level of model', robotID);
%     error('Cannot find Arduino IO Setup Block for ''%s'' at top level of model', arduinoVar);
elseif numel(blockName) > 1
    error('Multiple KheperaIII Blocks for ''%s''', robotID);
%     error('Multiple Arduino IO Blocks for ''%s''', arduinoVar);
end

data = get_param(blockName, 'UserData');
if isempty(data)
   error('KheperaIII Block is not initialized'); 
end