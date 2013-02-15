classdef GoToAngle < simiam.controller.Controller
%% GOTOANGLE steers the robot towards an angle with a constant velocity using PID
%
% Properties:
%   none
%
% Methods:
%   execute - Computes the left and right wheel speeds for go-to-goal.
    
    properties
        %% PROPERTIES
        
        % memory banks
        Kp
        Ki
        Kd
        
        e_k_1
        E_k
    end
    
    properties (Constant)
        % I/O
        inputs = struct('x_g', 0, 'y_g', 0, 'theta_d', 0);
        outputs = struct('v', 0, 'w', 0);
    end
    
    methods
    %% METHODS
        
        function obj = GoToAngle()
            %% GOTOANGLE Constructor
            obj = obj@simiam.controller.Controller('go_to_angle');
            
            % initialize memory banks
            obj.Kp = 1;
            obj.Ki = 0.1;
            obj.Kd = 0.01;
            
            obj.e_k_1 = 0;
            obj.E_k = 0;
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
        %% EXECUTE Computes the left and right wheel speeds for go-to-goal.
        %   [v, w] = execute(obj, robot, x_g, y_g, v) will compute the
        %   necessary linear and angular speeds that will steer the robot
        %   to the angle (theta_d) with a constant linear velocity
        %   of v.
        %
        %   See also controller/execute
        
            % Retrieve the (relative) goal angle
            theta_d = inputs.theta_d;
            
            % Get estimate of current pose
            [x, y, theta] = state_estimate.unpack();
            
            % Compute the v,w that will get you to the goal
            v = inputs.v;
            
            e_k = theta_d-theta;
            e_k = atan2(sin(e_k),cos(e_k));
            
            w = obj.Kp*e_k + obj.Ki*(obj.E_k+e_k*dt) + obj.Kd*(e_k-obj.e_k_1)/dt;
            
            obj.E_k = obj.E_k+e_k*dt;
            obj.e_k_1 = e_k;
            
            outputs = obj.outputs;  % make a copy of the output struct
            outputs.v = v;
            outputs.w = w;
        end
        
    end
    
end

