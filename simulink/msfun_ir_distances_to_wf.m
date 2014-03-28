function msfun_ir_distances_to_wf(block)

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
robot = [];
sensor_placement = zeros(3,9);

setup(block);

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
    function setup(block)
        
        % Register number of ports
        block.NumInputPorts  = 4;
        block.NumOutputPorts = 1;
        
        % Setup port properties to be inherited or dynamic
        % block.SetPreCompInpPortInfoToDynamic;
        % block.SetPreCompOutPortInfoToDynamic;
        block.SetPreCompPortInfoToDefaults;
        
        % Override input port properties
        for i=1:3
            block.InputPort(i).Dimensions  = 1;
            block.InputPort(i).DatatypeID  = 0;  % double
            block.InputPort(i).Complexity  = 'Real';
            block.InputPort(i).DirectFeedthrough = true;      
            block.InputPort(i).SamplingMode = 0;
        end
        
        block.InputPort(4).Dimensions  = 9;
        block.InputPort(4).DatatypeID  = 0;  % double
        block.InputPort(4).Complexity  = 'Real';
        block.InputPort(4).DirectFeedthrough = true;
        
        % Override output port properties
        block.OutputPort(1).Dimensions       = [2 9];
        block.OutputPort(1).DatatypeID  = 0; % double
        block.OutputPort(1).Complexity  = 'Real';
        
        % Set up the states
        block.NumContStates = 0;
        block.NumDworks = 0;
        
        % Register parameters
        block.NumDialogPrms     = 0;
%         block.DialogPrmsTunable = {'NonTunable', 'NonTunable', 'NonTunable'};
        
        % Register sample times
        %  [0 offset]            : Continuous sample time
        %  [positive_num offset] : Discrete sample time
        %
        %  [-1, 0]               : Inherited sample time
        %  [-2, 0]               : Variable sample time
        block.SampleTimes = [0.033 0];
        
        % Specify the block simStateCompliance. The allowed values are:
        %    'UnknownSimState', < The default setting; warn and assume DefaultSimState
        %    'DefaultSimState', < Same sim state as a built-in block
        %    'HasNoSimState',   < No sim state
        %    'CustomSimState',  < Has GetSimState and SetSimState methods
        %    'DisallowSimState' < Error out when saving or restoring the model sim state
        block.SetAccelRunOnTLC(false); % run block in interpreted mode even w/ Acceleration
        block.SimStateCompliance = 'DefaultSimState';
        
        %% -----------------------------------------------------------------
        %% The MATLAB S-function uses an internal registry for all
        %% block methods. You should register all relevant methods
        %% (optional and required) as illustrated below. You may choose
        %% any suitable name for the methods and implement these methods
        %% as local functions within the same file. See comments
        %% provided for each function for more information.
        %% -----------------------------------------------------------------
        
        block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
        block.RegBlockMethod('InitializeConditions', @InitializeConditions);
        block.RegBlockMethod('Start', @Start);
        block.RegBlockMethod('Outputs', @Outputs);     % Required
        block.RegBlockMethod('Update', @Update);
        block.RegBlockMethod('Terminate', @Terminate); % Required
        
    end %end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
    function DoPostPropSetup(block)
        
    end
%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is
%%                      present in an enabled subsystem configured to reset
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
    function InitializeConditions(block)
        
    end %end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
    function Start(block)
        
        customData = getRobotBlockUserData(bdroot(block.BlockHandle), '1');
        robot = customData('robotHandle');
        
        for i=1:9
            [x, y, theta] = robot.ir_array(i).location.unpack();
            sensor_placement(:,i) = [x; y; theta];
        end
        
    end %endfunction

    function R = get_transformation_matrix(x, y, theta)
        R = [cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1];
    end

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
    function Outputs(block)
        
        ir_array_values = block.InputPort(4).Data;
        ir_distances_sf = 0.02-log(ir_array_values/3960)/30;
        
        ir_distances_rf = zeros(3,9);
        for i=1:9
            x_s = sensor_placement(1,i);
            y_s = sensor_placement(2,i);
            theta_s = sensor_placement(3,i);
            
            R = get_transformation_matrix(x_s,y_s,theta_s);
            ir_distances_rf(:,i) = R*[ir_distances_sf(i); 0; 1];
        end
        
        % Apply the transformation to world frame.
        x = block.InputPort(1).Data;
        y = block.InputPort(2).Data;
        theta = block.InputPort(3).Data;
        
        R = get_transformation_matrix(x,y,theta);
        ir_distances_wf = R*ir_distances_rf;
        
        block.OutputPort(1).Data = ir_distances_wf(1:2,:);
        
        
    end %end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
    function Update(block)
        
    end %end Update

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
    function Terminate(block)
        
    end %end Terminate

end
