classdef AvoidObstacles < simiam.controller.Controller
    %AVOID_OBSTACLES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        R
        RT
        sensor_angles
        D
    end
    
    properties (Constant)
        inputs = struct('v', 0);
        outputs = struct('v', 0, 'w', 0)
    end
    
    methods
        
        function obj = AvoidObstacles()
            obj = obj@simiam.controller.Controller('avoid_obstacles');
            
            obj.R = @(theta)([cos(theta) -sin(theta); sin(theta) cos(theta)]);
            obj.RT = @(x,y,theta)([cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1]);
            
            import simiam.ui.Pose2D;
            obj.sensor_angles = [Pose2D.deg2rad(128); Pose2D.deg2rad(75); Pose2D.deg2rad(42); ...
                                 Pose2D.deg2rad(13); Pose2D.deg2rad(-13); Pose2D.deg2rad(-42);
                                 Pose2D.deg2rad(-75); Pose2D.deg2rad(-128); Pose2D.deg2rad(180)];
                                 
            obj.D = @(raw)(log(raw./3960)./(-30)+0.02);
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            
            % Poll the current IR sensor values 1-9
            ir_array_values = [robot.ir_array.get_range()];
            ir_array_values = max(real(ir_array_values),18);
            
            % Update the odometry
            [x, y, theta] = state_estimate.unpack();
            
            % Interpret the IR sensor measurements geometrically
           
            ir_vectors = [obj.D(ir_array_values); zeros(1,9)];
            for i=1:9
                ir_vectors(:,i) = obj.R(obj.sensor_angles(i))*ir_vectors(:,i);
            end

            ir_vectors_rt = obj.RT(x,y,theta)*[ir_vectors; ones(1,9)];
            
            ir_vectors = ir_vectors_rt(1:2,:);
            
            % Compute the heading vector
            
            gains = -[0 1 4 5 5 4 1 0 0]*2;
            
            u_i = (repmat([x;y],1,9)-ir_vectors)*diag(gains);
            u = sum(u_i,2);
            
            theta_d = atan2(u(2),u(1));
            
            % Compute the control
            
            Kv = 0.025;
            Kw = 1.75;
            
            v = Kv*norm(u)*cos(theta_d-theta);
            w = Kw*norm(u)*sin(theta_d-theta);
            
            fprintf('(v,w) = (%0.4g,%0.4g)\n', v,w);
            
            % Transform from v,w to v_r,v_l and set the speed of the robot
%             [vel_r, vel_l] = obj.uni_to_diff(robot,v,w);
%             robot.set_speed(vel_r, vel_l);
            outputs.v = v;
            outputs.w = w;
        end
        
        
    end
    
end

