classdef JoystickTankDrive < simiam.controller.Controller

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
        inputs = struct('vel_max', 0);
        outputs = struct('v', 0, 'w', 0);
    end
    
    methods
    %% METHODS
        
        function obj = JoystickTankDrive()
            %% GOTOGOAL Constructor
            obj = obj@simiam.controller.Controller('joy_tank_drive');
            
            % initialize memory banks
            
            % plot support
            obj.p = [];
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
        
            [axes, buttons] = Joystick();
            
            vel_r = -axes(4)/(2^15)*inputs.vel_max;
            vel_l = -axes(2)/(2^15)*inputs.vel_max;
            
            [v, w] = robot.dynamics.diff_to_uni(vel_r, vel_l);
            outputs.v = v;
            outputs.w = w;
        end
        
    end
    
end

