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

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        %% PROPERTIES
        
        parent          % AppWindow graphics handle
        clock           % Global timer for the simulation
        time_step       % Time step for the simulation
        
        world           % A virtual world for the simulator
        physics
        
        coi
    end
    
    methods
        %% METHODS
        
        function obj = Simulator(parent, world, time_step)
        %% SIMULATOR Constructor
        %   obj = Simulator(parent, time_step) is the default constructor
        %   that sets the graphics handle and the time step for the
        %   simulation.
        
            obj.parent = parent;
            obj.time_step = time_step;
            obj.clock = timer('Period', obj.time_step, ...
                              'TimerFcn', @obj.step, ...
                              'ExecutionMode', 'fixedRate');
            obj.world = world;
            obj.physics = simiam.simulator.Physics(world);
            
            obj.coi = rectangle('Position', [[0 0]-1 2 2], 'Curvature', [1 1], 'LineStyle', '--', 'EdgeColor', [254 206 0]/255, 'LineWidth', 2, 'Parent', obj.parent.view_);
        end
        
        function step(obj, src, event)
        %% STEP Executes one time step of the simulation.
        %   step(obj, src, event) is the timer callback which is executed
        %   once every time_step seconds.
            
            split = max(obj.time_step, get(obj.clock, 'InstantPeriod'));
%             split = obj.time_step;
            fprintf('***TIMING***\nsimulator split: %0.3fs, %0.3fHz\n', split, 1/split);
            
            tstart = tic;
            nRobots = length(obj.world.robots);
            poseMat = zeros(nRobots, 3);
            for k = 1:nRobots
                robot_s = obj.world.robots.elementAt(k);
                robot_s.supervisor.execute(split);
                [x, y, theta] = robot_s.robot.update_state(robot_s.pose, split).unpack();
                poseMat(k,:) = [x y theta];
                robot_s.pose.set_pose([x, y, theta]);
            end
            set(obj.coi, 'Position', [poseMat(nRobots,1:2)-1 2 2]);
            u = poseMat(2,1:2)-poseMat(1,1:2);
            d = sqrt(u(1)^2+u(2)^2);
            if d < 1
                set(obj.coi, 'EdgeColor', 'r');
            else
                set(obj.coi, 'EdgeColor', [150 150 150]/255);
            end
            fprintf('controls: %0.3fs\n', toc(tstart));
            
            tstart = tic;
            obj.world.apps.head_.key_.run(split);
            fprintf('app: %0.3fs\n', toc(tstart));
            
            tstart = tic;
            bool = obj.physics.apply_physics();
            fprintf('physics: %0.3fs\n', toc(tstart));
            
            if bool(2)
                robot_s = obj.world.robots.elementAt(2);
                [x, y, theta] = robot_s.pose.unpack();
                robot_s.pose.set_pose([1, 1, theta]);
                robot_s.supervisor.state_estimate.set_pose([1, 1, theta]);
            end
            
%             if bool(3)
%                 robot_s = obj.world.robots.elementAt(3);
%                 [x, y, theta] = robot_s.pose.unpack();
%                 robot_s.pose.set_pose([-1, 1, theta]);
%                 robot_s.supervisor.state_estimate([-1, 1, theta]);
%             end
            
            tstart = tic;
            obj.parent.ui_update(split, any(bool));
            drawnow;
            fprintf('ui: %0.3fs\n', toc(tstart));
        end
        
        function start(obj)
        %% START Starts the simulation.
        
            start(obj.clock);
        end
        
        function stop(obj)
        %% STOP Stops the simulation.
        
            stop(obj.clock);
        end
        
        function shutdown(obj)
            obj.stop();
            delete(obj.clock);
        end
    end
    
end