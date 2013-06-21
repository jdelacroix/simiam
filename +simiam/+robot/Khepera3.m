classdef Khepera3 < simiam.robot.Robot

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        wheel_radius
        wheel_base_length
        ticks_per_rev
        speed_factor
        
        encoders = simiam.robot.sensor.WheelEncoder.empty(1,0);
        ir_array = simiam.robot.sensor.ProximitySensor.empty(1,0);
        
        dynamics
        
        prev_ticks
    end
    
    properties (SetAccess = private)
        right_wheel_speed
        left_wheel_speed
    end
    
    methods
        function obj = Khepera3(parent, pose)
           obj = obj@simiam.robot.Robot(parent, pose);
           
           % Add surfaces: Khepera3 in top-down 2D view
           k3_top_plate =  [ -0.031   0.043    1;
                             -0.031  -0.043    1;
                              0.033  -0.043    1;
                              0.052  -0.021    1;
                              0.057       0    1;
                              0.052   0.021    1;
                              0.033   0.043    1];
                          
           k3_base =  [ -0.024   0.064    1;
                         0.033   0.064    1;
                         0.057   0.043    1;
                         0.074   0.010    1;
                         0.074  -0.010    1;
                         0.057  -0.043    1;
                         0.033  -0.064    1;
                        -0.025  -0.064    1;
                        -0.042  -0.043    1;
                        -0.048  -0.010    1;
                        -0.048   0.010    1;
                        -0.042   0.043    1];
            
            obj.add_surface(k3_base, [ 0.8 0.8 0.8 ]);
            obj.add_surface(k3_top_plate, [ 0.0 0.0 0.0 ]);
            
            % Add sensors: wheel encoders and IR proximity sensors
            obj.wheel_radius = 0.021;           % 42mm
            obj.wheel_base_length = 0.0885;     % 88.5mm
            obj.ticks_per_rev = 2765;
            obj.speed_factor = 6.2953e-6;
            
            obj.encoders(1) = simiam.robot.sensor.WheelEncoder('right_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            obj.encoders(2) = simiam.robot.sensor.WheelEncoder('left_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            
            import simiam.robot.sensor.ProximitySensor;
            import simiam.robot.Khepera3;
            import simiam.ui.Pose2D;
            
            ir_pose = Pose2D(-0.038, 0.048, Pose2D.deg2rad(128));
            obj.ir_array(1) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.019, 0.064, Pose2D.deg2rad(75));
            obj.ir_array(2) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.050, 0.050, Pose2D.deg2rad(42));
            obj.ir_array(3) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.070, 0.017, Pose2D.deg2rad(13));
            obj.ir_array(4) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.070, -0.017, Pose2D.deg2rad(-13));
            obj.ir_array(5) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.050, -0.050, Pose2D.deg2rad(-42));
            obj.ir_array(6) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(0.019, -0.064, Pose2D.deg2rad(-75));
            obj.ir_array(7) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(-0.038, -0.048, Pose2D.deg2rad(-128));
            obj.ir_array(8) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            ir_pose = Pose2D(-0.048, 0.000, Pose2D.deg2rad(180));
            obj.ir_array(9) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw');
            
            % Add dynamics: two-wheel differential drive
            obj.dynamics = simiam.robot.dynamics.DifferentialDrive(obj.wheel_radius, obj.wheel_base_length);
            obj.prev_ticks = struct('left', 0, 'right', 0);
            
            obj.right_wheel_speed = 0;
            obj.left_wheel_speed = 0;
        end
        
        
        function pose = update_state(obj, pose, dt)
            if (~obj.islinked)
                sf = obj.speed_factor;
                R = obj.wheel_radius;

                vel_r = obj.right_wheel_speed*(sf/R);     % mm/s
                vel_l = obj.left_wheel_speed*(sf/R);      % mm/s

                pose = obj.dynamics.apply_dynamics(pose, dt, vel_r, vel_l);
                obj.update_pose(pose);

                for k=1:length(obj.ir_array)
                    obj.ir_array(k).update_pose(pose);
                end

                % update wheel encoders
                sf = obj.speed_factor;
                R = obj.wheel_radius;

                vel_r = obj.right_wheel_speed*(sf/R); %% mm/s
                vel_l = obj.left_wheel_speed*(sf/R); %% mm/s

                obj.encoders(1).update_ticks(vel_r, dt);
                obj.encoders(2).update_ticks(vel_l, dt);
            else
                obj.update_state_from_hardware(pose, dt);
            end
        end
        
        function set_wheel_speeds(obj, vel_r, vel_l)
            [vel_r, vel_l] = obj.limit_speeds(vel_r, vel_l);
            
            sf = obj.speed_factor;
            R = obj.wheel_radius;
            
            obj.right_wheel_speed = floor(vel_r*(R/sf));
            obj.left_wheel_speed = floor(vel_l*(R/sf));
        end
        
        function [vel_r, vel_l] = limit_speeds(obj, vel_r, vel_l)
            % actuator hardware limits
            [v,w] = obj.dynamics.diff_to_uni(vel_r, vel_l);
            v = max(min(v,0.314),-0.3148);
            w = max(min(w,2.276),-2.2763);
            [vel_r, vel_l] = obj.dynamics.uni_to_diff(v,w);
        end
        
        function ir_distances = get_ir_distances(obj)
            ir_array_values = obj.ir_array.get_range()
            ir_distances = 0.02-log(ir_array_values/3960)/30;
        end
        
        function pose = get_optitrack_pose(obj)
            if(~isempty(obj.optitrack))
                data = obj.optitrack.update();
                pose = simiam.ui.Pose2D(data(1),data(2),data(3));
            else
                pose = simiam.ui.Pose2D(Inf,Inf,Inf);
            end
        end
        
        % Hardware connectivty related functions
        function add_hardware_link(obj, hostname, port)
            obj.driver = simiam.robot.driver.K3Driver(hostname, port);
        end
        
        function add_optitrack_link(obj, hostname, port, id)
            obj.optitrack = simiam.robot.driver.OptiTrackDriver(hostname, port, id);
        end
        
        function open_hardware_link(obj)
            obj.driver.init();
            obj.islinked = true;
        end
        
        function close_hardware_link(obj)
            obj.islinked = false;
            obj.driver.close();
            obj.optitrack.close();
        end
        
        function pose = update_state_from_hardware(obj, pose, dt)
            data = obj.driver.update();
            
            % data structure
            %    battery  -> data(1)
            %    ir1-ir11 -> data(2:12)
            %    enc1-2   -> data(13:14)
            
            if(~isempty(data))                
                obj.encoders(1).ticks = double(data(12));
                obj.encoders(2).ticks = double(data(13));
                
                pose = obj.update_pose_from_hardware(pose);
                obj.update_pose(pose);
                
                for i=1:9
                    obj.ir_array(i).update_pose(pose);
                    double(data(i))
                    obj.ir_array(i).update_range(log(double(data(i))/3960)/(-30)+0.02);
                end
                
                obj.driver.set_speed(obj.right_wheel_speed, obj.left_wheel_speed);
            end
        end
        
        function pose_k_1 = update_pose_from_hardware(obj, pose)
            right_ticks = obj.encoders(1).ticks;
            left_ticks = obj.encoders(2).ticks;
            
            prev_right_ticks = obj.prev_ticks.right;
            prev_left_ticks = obj.prev_ticks.left;
            
            obj.prev_ticks.right = right_ticks;
            obj.prev_ticks.left = left_ticks;
            
            % Previous estimate
            [x, y, theta] = pose.unpack();
            
            % Compute odometry here
            
            m_per_tick = (2*pi*obj.wheel_radius)/obj.encoders(1).ticks_per_rev;
            
            d_right = (right_ticks-prev_right_ticks)*m_per_tick;
            d_left = (left_ticks-prev_left_ticks)*m_per_tick;
            
            d_center = (d_right + d_left)/2;
            phi = (d_right - d_left)/obj.wheel_base_length;
            
            theta_new = theta + phi;
            x_new = x + d_center*cos(theta);
            y_new = y + d_center*sin(theta);
                           
%             fprintf('Estimated pose (x,y,theta): (%0.3g,%0.3g,%0.3g)\n', x_new, y_new, theta_new);
            
            % Update your estimate of (x,y,theta)
            pose_k_1 = simiam.ui.Pose2D(x_new, y_new, theta_new);
        end
        
    end
    
    methods (Static)
        function raw = ir_distance_to_raw(varargin)
            distance = cell2mat(varargin);
            if(distance < 0.02)
                raw = 3960;
            else
                raw = ceil(3960*exp(-30*(distance-0.02)));
            end
        end
    end
    
end

