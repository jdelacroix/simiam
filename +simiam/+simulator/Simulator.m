classdef Simulator < handle
%% SIMULATOR is responsible for stepping the program through the simulation.
%
% Simulator Properties:
%   parent          - AppWindow graphics handle
%   clock           - Global timer for the simulation
%   time_step       - Time step for the simulation
%   split           - Split between calls to step()
%
% Simulator Methods:
%   step            - Executes one time step of the simulation.
%   start           - Starts the simulation.
%   stop            - Stops the simulation.

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        %% PROPERTIES
        
        parent          % AppWindow graphics handle
        clock           % Global timer for the simulation
        time_step       % Time step for the simulation
        split           % Split between calls to step()
    end
    
    methods
        %% METHODS
        
        function obj = Simulator(parent, time_step)
        %% SIMULATOR Constructor
        %   obj = Simulator(parent, time_step) is the default constructor
        %   that sets the graphics handle and the time step for the
        %   simulation.
        
            obj.parent = parent;
            obj.time_step = time_step;
            obj.clock = timer('Period', obj.time_step, ...
                              'TimerFcn', @obj.step, ...
                              'ExecutionMode', 'fixedRate');
        end
        
        function step(obj, src, event)
        %% STEP Executes one time step of the simulation.
        %   step(obj, src, event) is the timer callback which is executed
        %   once every time_step seconds.
            
            obj.split = get(obj.clock, 'InstantPeriod');
            fprintf('Split: %0.3f\n', obj.split);
        end
        
        function start(obj)
        %% START Starts the simulation.
        
            start(obj.clock);
        end
        
        function stop(obj)
        %% STOP Stops the simulation.
        
            stop(obj.clock);
        end
    end
    
end