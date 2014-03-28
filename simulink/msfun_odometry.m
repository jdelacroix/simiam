function msfun_odometry(block)

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
myPrevTicks = struct('right', 0, 'left', 0);

setup(block);

%endfunction

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
        block.NumOutputPorts = 3;
        
        % Setup port properties to be inherited or dynamic
        % block.SetPreCompInpPortInfoToDynamic;
        % block.SetPreCompOutPortInfoToDynamic;
        block.SetPreCompPortInfoToDefaults;
        
        % Override input port properties
        for i=1:3
            block.InputPort(i).Dimensions        = 1;
            block.InputPort(i).DatatypeID  = 0;  % double
            block.InputPort(i).Complexity  = 'Real';
            block.InputPort(i).DirectFeedthrough = true;
        end
        
        block.InputPort(4).Dimensions        = 2;
        block.InputPort(4).DatatypeID  = 0;  % double
        block.InputPort(4).Complexity  = 'Real';
        block.InputPort(4).DirectFeedthrough = true;
        
        block.InputPort(1).SamplingMode = 0;
        block.InputPort(2).SamplingMode = 0;
        block.InputPort(3).SamplingMode = 0;
        block.InputPort(4).SamplingMode = 0;
        
        % Override output port properties
        block.OutputPort(1).Dimensions       = 1;
        block.OutputPort(1).DatatypeID  = 0; % double
        block.OutputPort(1).Complexity  = 'Real';
        
        block.OutputPort(2).Dimensions       = 1;
        block.OutputPort(2).DatatypeID  = 0; % double
        block.OutputPort(2).Complexity  = 'Real';
        
        block.OutputPort(2).Dimensions       = 1;
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
        
    end %setup

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
        
        myPrevTicks = struct('right', 0, 'left', 0);
        
    end

%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
    function Start(block)
        
    end %endfunction

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
    function Outputs(block)
        
        % Get wheel encoder ticks from the robot
        right_ticks = block.InputPort(4).Data(1);
        left_ticks = block.InputPort(4).Data(2);
        
        % Recal the previous wheel encoder ticks
        prev_right_ticks = myPrevTicks.right;
        prev_left_ticks = myPrevTicks.left;
        
        % Previous estimate
        x = block.InputPort(1).Data;
        y = block.InputPort(2).Data;
        theta = block.InputPort(3).Data;
        
        % Compute odometry here
        R = block.DialogPrm(1).Data;
        L = block.DialogPrm(2).Data;
        ticks_per_rev = block.DialogPrm(3).Data;
        m_per_tick = (2*pi*R)/ticks_per_rev;
        
        d_right = (right_ticks-prev_right_ticks)*m_per_tick;
        d_left = (left_ticks-prev_left_ticks)*m_per_tick;
        d_center = (d_right + d_left)/2;
        
        x_dt = d_center*cos(theta);
        y_dt = d_center*sin(theta);
        theta_dt = (d_right - d_left)/L;
        
        theta_new = theta + theta_dt;
        x_new = x + x_dt;
        y_new = y + y_dt;
        %             fprintf('Estimated pose (x,y,theta): (%0.3g,%0.3g,%0.3g)\n', x_new, y_new, theta_new);
        
        % Save the wheel encoder ticks for the next estimate
        myPrevTicks.right = right_ticks;
        myPrevTicks.left = left_ticks;
        
        % Update your estimate of (x,y,theta)
        block.OutputPort(1).Data = x_new;
        block.OutputPort(2).Data = y_new;
        block.OutputPort(3).Data = theta_new;
        
        
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