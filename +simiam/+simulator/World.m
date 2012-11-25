classdef World < handle
    
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        robots
        obstacles
        parent
    end
    
    methods
        function obj = World(parent)
            obj.parent = parent;
            obj.robots = mcodekit.list.dl_list(); %struct('robot', {}, 'pose', {});
            obj.obstacles = mcodekit.list.dl_list(); %struct('obstacle', {}, 'pose', {});
        end
        
        function build_from_file(obj, file)
            
            % Read in XML file
            blueprint = xmlread(file);
            
            % Parse XML file for robot configurations
            robot_list = blueprint.getElementsByTagName('robot');
            
            for k = 0:(robot_list.getLength-1)
               robot = robot_list.item(k);
               
               type = robot.getAttribute('type');
               
               pose = robot.getElementsByTagName('pose').item(0);
               x = str2double(pose.getAttribute('x'));
               y = str2double(pose.getAttribute('y'));
               theta = str2double(pose.getAttribute('theta'));
               

               obj.add_robot(type, x, y, theta);
            end
            
            % Parse XML file for obstacle configurations
            obstacle_list = blueprint.getElementsByTagName('obstacle');
            
            for i = 0:(obstacle_list.getLength-1)
               obstacle = obstacle_list.item(i);
               
               pose = obstacle.getElementsByTagName('pose').item(0);
               x = str2double(pose.getAttribute('x'));
               y = str2double(pose.getAttribute('y'));
               theta = str2double(pose.getAttribute('theta'));
               
               geo = obstacle.getElementsByTagName('geometry').item(0);
               point_list = geo.getElementsByTagName('point');
               
               obstacle_geometry = zeros(point_list.getLength, 2);
               for j=0:(point_list.getLength-1)
                  point = point_list.item(j);
                  obstacle_geometry(j+1,1) = str2double(point.getAttribute('x'));
                  obstacle_geometry(j+1,2) = str2double(point.getAttribute('y'));
               end
               
               obj.add_obstacle(x, y, theta, obstacle_geometry);
            end
        end
        
        function add_robot(obj, type, x, y, theta)
           pose = simiam.ui.Pose2D(x, y, theta);
%            strcat('simiam.robot.', type)
%            r = str2func(strcat('simiam.robot.', type));
           s = struct('robot', simiam.robot.Khepera3(obj.parent, pose), 'pose', pose);
           obj.robots.append_key(s);
        end
        
        function add_obstacle(obj, x, y, theta, geometry)
           pose = simiam.ui.Pose2D(x, y, theta);
           obj.obstacles.append_key(struct('obstacle', simiam.simulator.Obstacle(obj.parent, pose, geometry), 'pose', pose));
        end
           
    end
    
end
