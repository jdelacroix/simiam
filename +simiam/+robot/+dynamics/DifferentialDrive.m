classdef DifferentialDrive < simiam.robot.dynamics.Dynamics

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        wheel_radius
        wheel_base_length
    end
    
    methods
        function obj = DifferentialDrive(wheel_radius, wheel_base_length)
            obj = obj@simiam.robot.dynamics.Dynamics();
            obj.wheel_radius = wheel_radius;
            obj.wheel_base_length = wheel_base_length;
        end
        
        function pose_t_1 = apply_dynamics(obj, pose_t, dt, vel_r, vel_l)
            R = obj.wheel_radius;
            L = obj.wheel_base_length;
            
            fprintf('(vel_r,vel_l) = (%0.6g,%0.6g)\n', vel_r,vel_l);
            
            v = R/2*(vel_r+vel_l);
            w = R/L*(vel_r-vel_l);
            
            fprintf('Calculated velocities (v,w): (%0.3g,%0.3g)\n', v, w);

            [x_k, y_k, theta_k] = pose_t.get_pose();

            x_k_1 = x_k + dt*(v*cos(theta_k));
            y_k_1 = y_k + dt*(v*sin(theta_k));
            theta_k_1 = theta_k + dt*w;
            
            pose_t_1 = simiam.ui.Pose2D(x_k_1, y_k_1, theta_k_1);
        end
        
        function [r,l] = uni_to_diff(obj,v,w)
            R = obj.wheel_radius;
            L = obj.wheel_base_length;
            
            r = v/R + (w*L)/(2*R);
            l = v/R - (w*L)/(2*R);
        end
        
        function [v,w] = diff_to_uni(obj,r,l)
            R = obj.wheel_radius;
            L = obj.wheel_base_length;
            
            v = R/2*(r+l);
            w = R/L*(r-l);
        end
    end
    
end

