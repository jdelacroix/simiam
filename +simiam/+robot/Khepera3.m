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
        
        firmware_3_0_plus
    end
    
    properties (SetAccess = private)
        right_wheel_speed
        left_wheel_speed
    end
    
    methods
        function obj = Khepera3(parent, pose)
           obj = obj@simiam.robot.Robot(parent, pose);
           
           % Add surfaces: Khepera3 in top-down 2D view
           k3_top_plate =  [ -0.038   0.043    1;
                             -0.038  -0.043    1;
                              0.033  -0.043    1;
                              0.052  -0.021    1;
                              0.057       0    1;
                              0.052   0.021    1;
                              0.033   0.043    1];
                          
           k3_base =  [ -0.025   0.063    1;
                         0.030   0.063    1;
                         0.053   0.043    1;
                         0.070   0.010    1;
                         0.070  -0.010    1;
                         0.053  -0.043    1;
                         0.030  -0.063    1;
                        -0.025  -0.063    1;
                        -0.044  -0.043    1;
                        -0.052  -0.010    1;
                        -0.052   0.010    1;
                        -0.044   0.043    1];
            
            obj.add_surface(k3_base, [ 0.8 0.8 0.8 ]);
            obj.add_surface(k3_top_plate, [ 0.0 0.0 0.0 ]);
            
            % Add sensors: wheel encoders and IR proximity sensors
            obj.wheel_radius = 0.0205;              % 41mm
            obj.wheel_base_length = 0.08841;        % 88.41mm
            
            obj.firmware_3_0_plus = false;
            
            if (obj.firmware_3_0_plus)
                obj.ticks_per_rev = 4198;
                obj.speed_factor = 1/218.72/1000;
            else
                obj.ticks_per_rev = 2764;               
                obj.speed_factor = 1/144.01/1000;       
            end
            
            obj.encoders(1) = simiam.robot.sensor.WheelEncoder('right_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            obj.encoders(2) = simiam.robot.sensor.WheelEncoder('left_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            
            import simiam.robot.sensor.ProximitySensor;
            import simiam.robot.Khepera3;
            import simiam.ui.Pose2D;
            
            noise_model = simiam.robot.sensor.noise.GaussianNoise(0,0);
            
            ir_pose = Pose2D(-0.038, 0.049, Pose2D.deg2rad(128));
            obj.ir_array(1) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.017, 0.063, Pose2D.deg2rad(75));
            obj.ir_array(2) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.051, 0.045, Pose2D.deg2rad(42));
            obj.ir_array(3) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.067, 0.015, Pose2D.deg2rad(13));
            obj.ir_array(4) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.067, -0.015, Pose2D.deg2rad(-13));
            obj.ir_array(5) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.051, -0.045, Pose2D.deg2rad(-42));
            obj.ir_array(6) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(0.017, -0.063, Pose2D.deg2rad(-75));
            obj.ir_array(7) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(-0.038, -0.049, Pose2D.deg2rad(-128));
            obj.ir_array(8) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            ir_pose = Pose2D(-0.052, 0.000, Pose2D.deg2rad(180));
            obj.ir_array(9) = ProximitySensor(parent, 'IR', pose, ir_pose, 0.02, 0.2, Pose2D.deg2rad(20), 'simiam.robot.Khepera3.ir_distance_to_raw', noise_model);
            
            % Add dynamics: two-wheel differential drive
            obj.dynamics = simiam.robot.dynamics.DifferentialDrive(obj.wheel_radius, obj.wheel_base_length);
            
            obj.right_wheel_speed = 0;
            obj.left_wheel_speed = 0;
        end
        
        function ir_distances = get_ir_distances(obj)
            ir_array_values = obj.ir_array.get_range();
            ir_distances = 0.02-log(ir_array_values/3960)/30;
        end
        
        % Hardware connectivty related functions
        function add_hardware_link(obj, hostname, port)
            obj.driver = simiam.robot.driver.K3Driver(hostname, port);
        end
        
        function pose_new = update_state_from_hardware(obj, pose, dt)
            
            encoder_ticks = obj.driver.get_encoder_ticks();
            
            if (~isempty(encoder_ticks))
                obj.encoders(2).ticks = encoder_ticks(1);
                obj.encoders(1).ticks = encoder_ticks(2);
            end
            
            ir_raw_values = obj.driver.get_ir_raw_values();
            
            if (~isempty(ir_raw_values))
                ir_distances = 0.02-log(ir_raw_values/3960)/30;
                
                for i = 1:numel(obj.ir_array)
                    obj.ir_array(i).update_range(ir_distances(i));
                end
            end
            
            obj.driver.set_speeds(obj.right_wheel_speed, obj.left_wheel_speed);
            
            pose_new = obj.update_pose_from_hardware(pose);
            
            obj.update_pose(pose_new);
            
            for k=1:length(obj.ir_array)
                obj.ir_array(k).update_pose(pose_new);
            end
        end
        
        function pose_k_1 = update_pose_from_hardware(obj, pose)
            right_ticks = obj.encoders(1).ticks;
            left_ticks = obj.encoders(2).ticks;
            
            prev_right_ticks = obj.prev_ticks.right;
            prev_left_ticks = obj.prev_ticks.left;
            
            obj.prev_ticks.right = right_ticks;
            obj.prev_ticks.left = left_ticks;
            
            [x, y, theta] = pose.unpack();
                        
            m_per_tick = (2*pi*obj.wheel_radius)/obj.encoders(1).ticks_per_rev;
            
            d_right = (right_ticks-prev_right_ticks)*m_per_tick;
            d_left = (left_ticks-prev_left_ticks)*m_per_tick;
            
            d_center = (d_right + d_left)/2;
            phi = (d_right - d_left)/obj.wheel_base_length;
            
            theta_new = theta + phi;
            x_new = x + d_center*cos(theta);
            y_new = y + d_center*sin(theta);
                                       
            % Update your estimate of (x,y,theta)
            pose_k_1 = simiam.ui.Pose2D(x_new, y_new, theta_new);
        end
        
        
        function pose = update_state(obj, pose, dt)
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
            
            %[v,w] = obj.dynamics.diff_to_uni(vel_r, vel_l);
%             v = max(min(v,0.314),-0.3148);
%             w = max(min(w,2.276),-2.2763);
%             [vel_r, vel_l] = obj.dynamics.uni_to_diff(v,w);

            sf = obj.speed_factor;
            R = obj.wheel_radius;
            
            max_vel = 48000*(sf/R);
            
            vel_r = max(min(vel_r, max_vel), -max_vel);
            vel_l = max(min(vel_l, max_vel), -max_vel);
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

