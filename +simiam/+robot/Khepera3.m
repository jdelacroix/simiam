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

