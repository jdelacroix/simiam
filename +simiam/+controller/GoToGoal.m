classdef GoToGoal < simiam.controller.Controller
%% GOTOGOAL steers the robot towards a goal with a constant velocity using PID
%
% Properties:
%   none
%
% Methods:
%   execute - Computes the left and right wheel speeds for go-to-goal.
    
    properties
        %% PROPERTIES
        
        % memory banks
    end
    
    properties (Constant)
        % I/O
        inputs = struct('x_g', 0, 'y_g', 0, 'v', 0);
        outputs = struct('v', 0, 'w', 0);
    end
    
    methods
    %% METHODS
        
        function obj = GoToGoal()
            %% GOTOGOAL Constructor
            obj = obj@simiam.controller.Controller('go_to_goal');
            
            % initialize memory banks
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
        %% EXECUTE Computes the left and right wheel speeds for go-to-goal.
        %   [v, w] = execute(obj, robot, x_g, y_g, v) will compute the
        %   necessary linear and angular speeds that will steer the robot
        %   to the goal location (x_g, y_g) with a constant linear velocity
        %   of v.
        %
        %   See also controller/execute
        
            % Retrieve the (relative) goal location
            x_g = inputs.x_g; 
            y_g = inputs.y_g;
            
            % Get estimate of current pose
            [x, y, theta] = state_estimate.unpack();
            
            % Compute the v,w that will get you to the goal
            v = inputs.v;
            
            % desired (goal) heading
            theta_d = 0;
            
            w = 0;
            
            outputs = obj.outputs;  % make a copy of the output struct
            outputs.v = v;
            outputs.w = w;
        end
        
    end
    
end

