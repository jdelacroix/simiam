classdef World < handle
    
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software

    properties
        robots
        obstacles
        parent
        apps
    end
    
    methods
        function obj = World(parent)
            obj.parent = parent;
            obj.robots = mcodekit.list.dl_list(); %struct('robot', {}, 'pose', {});
            obj.obstacles = mcodekit.list.dl_list(); %struct('obstacle', {}, 'pose', {});
            obj.apps = mcodekit.list.dl_list();
        end
        
        function build_from_file(obj, file, islinked)
            
            % Read in XML file
            blueprint = xmlread(file);
            
            % Parse XML file for robot configurations
            app_list = blueprint.getElementsByTagName('app').item(0);
            app = char(app_list.getAttribute('type'));
            
            r = str2func(strcat('simiam.app.', app));
            obj.apps.append_key(r());
            
            robot_list = blueprint.getElementsByTagName('robot');
            
            for k = 0:(robot_list.getLength-1)
               robot = robot_list.item(k);
               
               type = char(robot.getAttribute('type'));
               
               s = robot.getElementsByTagName('supervisor').item(0);
               spv = char(s.getAttribute('type'));
               
               pose = robot.getElementsByTagName('pose').item(0);
               x = str2double(pose.getAttribute('x'));
               y = str2double(pose.getAttribute('y'));
               theta = str2double(pose.getAttribute('theta'));
               
               r = obj.add_robot(type, spv, x, y, theta);
               
               driver = robot.getElementsByTagName('driver').item(0);
               if(~isempty(driver) && islinked)
                   hostname = char(driver.getAttribute('ip'));
                   port = str2double(driver.getAttribute('port'));
                   r.add_hardware_link(hostname,port);
                   r.open_hardware_link();
               end

               
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
        
        function robot = add_robot(obj, type, spv, x, y, theta)
           pose = simiam.ui.Pose2D(x, y, theta);
           
           r = str2func(strcat('simiam.robot.', type));
           robot = r(obj.parent, pose);
           
           r = str2func(strcat('simiam.controller.', spv));
           supervisor = r();
           
           supervisor.attach_robot(robot, pose);
           
           s = struct('robot', robot, 'supervisor', supervisor, 'pose', pose);
           obj.robots.append_key(s);
           obj.apps.head_.key_.supervisors.append_key(supervisor);
        end
        
        function add_obstacle(obj, x, y, theta, geometry)
           pose = simiam.ui.Pose2D(x, y, theta);
           obj.obstacles.append_key(struct('obstacle', simiam.simulator.Obstacle(obj.parent, pose, geometry), 'pose', pose));
        end
           
    end
    
end
