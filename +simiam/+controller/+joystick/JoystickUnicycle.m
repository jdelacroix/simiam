classdef JoystickUnicycle < simiam.controller.Controller

% Copyright (C) 2014, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        %% PROPERTIES
        
        % memory banks
        
        % plot support
        p
    end
    
    properties (Constant)
        % I/O
        inputs = struct('v_max', 0, 'w_max', 0);
        outputs = struct('v', 0, 'w', 0);
    end
    
    methods
    %% METHODS
        
        function obj = JoystickUnicycle()
            %% GOTOGOAL Constructor
            obj = obj@simiam.controller.Controller('joy_unicycle');
            
            % initialize memory banks
            
            % plot support
            obj.p = [];
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
        
            [axes, buttons] = Joystick();
            outputs.v = -axes(2)/(2^15)*inputs.v_max;
            outputs.w = -axes(3)/(2^15)*inputs.w_max;
        end
        
    end
    
end

