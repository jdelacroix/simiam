function msfun_khepera3(block)

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
robot = [];

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
        block.NumInputPorts  = 2;
        block.NumOutputPorts = 2;
        
        % Setup port properties to be inherited or dynamic
        % block.SetPreCompInpPortInfoToDynamic;
        % block.SetPreCompOutPortInfoToDynamic;
        block.SetPreCompPortInfoToDefaults;
        
        % Override input port properties
        block.InputPort(1).Dimensions        = 1;
        block.InputPort(1).DatatypeID  = 0;  % double
        block.InputPort(1).Complexity  = 'Real';
        block.InputPort(1).DirectFeedthrough = false;
        
        block.InputPort(2).Dimensions        = 1;
        block.InputPort(2).DatatypeID  = 0;  % double
        block.InputPort(2).Complexity  = 'Real';
        block.InputPort(2).DirectFeedthrough = false;
        
        block.InputPort(1).SamplingMode = 0;
        block.InputPort(2).SamplingMode = 0;
        
        % Override output port properties
        block.OutputPort(1).Dimensions       = 9;
        block.OutputPort(1).DatatypeID  = 0; % double
        block.OutputPort(1).Complexity  = 'Real';
        
        block.OutputPort(2).Dimensions       = 2;
        block.OutputPort(2).DatatypeID  = 0; % double
        block.OutputPort(2).Complexity  = 'Real';
        
        % Set up the states
        block.NumContStates = 0;
        block.NumDworks = 0;
        
        % Register parameters
        block.NumDialogPrms     = 3;
        block.DialogPrmsTunable = {'NonTunable', 'NonTunable', 'NonTunable'};
        
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
        
        x_0 = block.DialogPrm(1).Data;
        y_0 = block.DialogPrm(2).Data;
        theta_0 = block.DialogPrm(3).Data;
        
        customData = getSimulatorBlockUserData(bdroot(block.BlockHandle));
        simulator = customData('simulatorHandle');
        
        robot = simulator.world.add_robot('Khepera3', 'Supervisor', x_0, y_0, theta_0);
        
        % store info in custom data;
        customData = containers.Map('UniformValues', false);
        customData('robotHandle') = robot;
        set(block.BlockHandle, 'UserData', customData, 'UserDataPersistent', 'off');
        
    end %endfunction

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
    function Outputs(block)
        
%         customData = get(block.BlockHandle, 'UserData');
%         robot = customData('robotHandle');
        
        block.OutputPort(1).Data = robot.ir_array.get_range();
        robot.encoders.ticks
        block.OutputPort(2).Data = [robot.encoders.ticks];
        
    end %end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
    function Update(block)
        
%         customData = get(block.BlockHandle, 'UserData');
%         robot = customData('robotHandle');
        
        vel_r = block.InputPort(1).Data;
        vel_l = block.InputPort(2).Data;
        
        robot.set_wheel_speeds(vel_r,vel_l);
        
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
