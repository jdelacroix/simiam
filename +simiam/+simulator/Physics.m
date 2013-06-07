classdef Physics < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
%         world
        robots
        obstacles
    end
    
    methods
        function obj = Physics(world)
%             obj.world = world;
            obj.robots = [world.robots.allElements().robot];
            obj.obstacles = [world.obstacles.allElements().obstacle];
        end
        
        function bool = apply_physics(obj)
            bool = obj.body_collision_detection();
            if (bool)
                return;
            end
            obj.proximity_sensor_detection();
        end
        
        function bool = body_collision_detection(obj)
            bool = false;
            nRobots = length(obj.robots);
            nObstacles = length(obj.obstacles);

            for k = 1:nRobots
                robot = obj.robots(k);
                body_r_s = robot.surfaces.head_.key_;
                
                % check against obstacles
                for l = 1:nObstacles
%                     obstacle = obj.obstacles(l);
                    body_o_s = obj.obstacles(l).surfaces.head_.key_;
                    
                    if(body_r_s.precheck_surface(body_o_s))
                        pts = body_r_s.intersection_with_surface(body_o_s, true);
                        if (size(pts,1) > 0)
                            fprintf('COLLISION!\n');
                            bool = true;
                            return;
                        end
                    end
                end
                
                % check against other robots
                for l = 1:nRobots
%                     robot_o = token_l.key_.robot;
                    robot_o =  obj.robots(l);
                    if(robot_o ~= robot)
                        body_o_s = robot_o.surfaces.head_.key_;
                        
                        if(body_r_s.precheck_surface(body_o_s))
                            pts = body_r_s.intersection_with_surface(body_o_s, true);
                            if (size(pts,1) > 0)
                                fprintf('COLLISION!\n');
                                bool = true;
                                return;
                            end
                        end
                    end
                end
            end
        end
        
        function proximity_sensor_detection(obj)
%             token_k = obj.world.robots.head_();
            nRobots = length(obj.robots);
            nObstacles = length(obj.obstacles);

            for k = 1:nRobots
%             while (~isempty(token_k))
%                 robot = token_k.key_.robot;
                robot = obj.robots(k);
                for i = 1:length(robot.ir_array)
                    ir = robot.ir_array(i);
                    body_ir_s = ir.surfaces.head_.key_;
                    d_min = ir.max_range;
                    ir.update_range(d_min);

                    % check against obstacles
                    for l = 1:nObstacles;
                        obstacle = obj.obstacles(l);
                        body_o_s = obstacle.surfaces.head_.key_;
                        
                        if(body_ir_s.precheck_surface(body_o_s))
                            d_min = obj.update_proximity_sensor(ir, body_ir_s, body_o_s, d_min);
                        end
                    end

                    % check against other robots
                    for l = 1:nRobots
                        robot_o = obj.robots(l);
                        if(robot_o ~= robot)
                            body_o_s = robot_o.surfaces.head_.key_;
                            
                            if(body_ir_s.precheck_surface(body_o_s))
                                d_min = obj.update_proximity_sensor(ir, body_ir_s, body_o_s, d_min);
                            end
                        end
                    end
                    
                    if(d_min < ir.max_range)
                        ir.update_range(d_min);
                    end
                end
            end
        end
    end
        
    methods (Access = private)

        function d_min = update_proximity_sensor(obj, sensor, sensor_surface, obstacle_surface, d_min)
            pts = sensor_surface.intersection_with_surface(obstacle_surface, false);
            if ~isempty(pts)
                d = sqrt((pts(:,1)-sensor_surface.geometry_(1,1)).^2+(pts(:,2)-sensor_surface.geometry_(1,2)).^2);
                d = sensor.limit_to_sensor(d);
%                 if any(d < d_min)
%                     d_min = min(d);
%                 end
                d_min = min(d);
            end
        end
    end
    
end

