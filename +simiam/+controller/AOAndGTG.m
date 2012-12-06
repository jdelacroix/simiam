classdef AOAndGTG < simiam.controller.Controller
    %AO_AND_GTG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % define any persistent variables (memory)
        R
        RT
        sensor_angles
        sensor_positions
        D
        
        % memory banks
        E_k
        e_k_1
        
        % gains
        Kp
        Ki
        Kd
    end
    
    properties (Constant)
        % I/O
        inputs = struct('x_g', 0, 'y_g', 0, 'v', 0, 'd_c', 0.02, 'd_s', 0.2);
        outputs = struct('v', 0, 'w', 0);
    end
    
    methods
        
        function obj = AOAndGTG()
            obj = obj@simiam.controller.Controller('ao_and_gtg');
            
            % initialize all variables from the properties section above
            obj.R = @(theta)([cos(theta) -sin(theta); sin(theta) cos(theta)]);
            obj.RT = @(x,y,theta)([cos(theta) -sin(theta) x; sin(theta) cos(theta) y; 0 0 1]);
            
            import simiam.ui.Pose2D;
            obj.sensor_angles = [Pose2D.deg2rad(128); Pose2D.deg2rad(75); Pose2D.deg2rad(42); ...
                                 Pose2D.deg2rad(13); Pose2D.deg2rad(-13); Pose2D.deg2rad(-42);
                                 Pose2D.deg2rad(-75); Pose2D.deg2rad(-128); Pose2D.deg2rad(180)];
                             
            obj.sensor_positions =  [ -0.038,  0.048;
                                       0.019,  0.064;
                                       0.050,  0.050;
                                       0.070,  0.017;
                                       0.070, -0.017;
                                       0.050, -0.050;
                                       0.019, -0.064;
                                      -0.038, -0.048;
                                      -0.048,      0]';
                                  
            obj.D = @(raw)(log(raw./3960)./(-30)+0.02);
            
            % initialize memory banks
            obj.Kp = 10;
            obj.Ki = 0;
            obj.Kd = 0;
            
            obj.E_k = 0;
            obj.e_k_1 = 0;
        end
        
        function outputs = execute(obj, robot, state_estimate, inputs, dt)
            % Set the goal location
            x_g = inputs.x_g;
            y_g = inputs.y_g;
            
            d_c = inputs.d_c;
            d_s = inputs.d_s;
            
            v = inputs.v;
            
            % Update the odometry
            [x, y, theta] = state_estimate.unpack();
            
            [d_obs, theta_obs] = obj.closest_obstacle(robot,x,y,theta);
                
            % Avoid obstacle controller
            
            % Compute the heading theta_d_ao that steers
            % the robot away from the obstacles
            
            theta_d_ao = theta_obs;
            theta_d_ao = atan2(sin(theta_d_ao),cos(theta_d_ao));
            
            % Compute the heading theta_d_gtg that steers
            % the robot towards the goal
            
            dx = x_g-x;
            dy = y_g-y;
            theta_d_gtg = atan2(dy,dx); % Hint: x_g, and y_g can be useful here.
            
            % Blend the two heading vectors
                        
            if (d_obs >= d_s)
                alpha = 0;
            elseif (d_obs <= d_c)
                alpha = 1;
            else
                m = -1/(d_s-d_c);
                b = 1-m*d_c;
                alpha = m*d_obs+b;
            end
                        
            theta_d = alpha*theta_d_ao + (1-alpha)*theta_d_gtg;
            
            % Compute the control
            
            % heading error
            e_k = theta_d-theta;
            e_k = atan2(sin(e_k), cos(e_k));
            
            % PID for heading
            w = obj.Kp*e_k + obj.Ki*(obj.E_k+e_k*dt) + obj.Kd*(e_k-obj.e_k_1)/dt;
            
            % save errors
            obj.E_k = obj.E_k+e_k*dt;
            obj.e_k_1 = e_k;
            
            outputs = obj.outputs;
            outputs.v = v;
            outputs.w = w;
        end
        
        function [d_obs, theta_obs] = closest_obstacle(obj,robot,x,y,theta)

            % Interpret the IR sensor measurements geometrically
            
            ir_array_values = [robot.ir_array.get_range()];
            ir_array_values = max(real(ir_array_values),18);
            ir_vectors = [obj.D(ir_array_values); zeros(1,9)];
            ir_vectors(1,[1 8 9]) = 0.3; % make sure that the rear IRs are ignored.
            
            ir_vectors = real(ir_vectors);
            for i=1:9
                ir_vectors(:,i) = obj.R(obj.sensor_angles(i))*ir_vectors(:,i);
            end

            ir_vectors_rt = obj.RT(x,y,theta)*[ir_vectors; ones(1,9)];
            
            ir_vectors = ir_vectors_rt(1:2,:);
            
            % Compute the vector to the closest obstacle
            
%             M = (repmat([x;y],1,9)-ir_vectors);
            v = [x;y];
            M = v(:,ones(9,1))-ir_vectors;
            n = sqrt(sum(abs(M).^2,1));
            [m,i] = min(n);
            
            d_obs = m;            
            % Compute the heading vector
            
%             gains = -[0 1 1 1 1 1 1 0 0];
            gains = -[0 1 4 5 5 4 1 0 0]*2;
            
            u_i = M*diag(gains);
            u = sum(u_i,2);
            
            theta_obs = atan2(u(2),u(1));
            
%             fprintf('closest obstacle: %0.3g,%0.3g\n', d_obs, simiam.ui.Pose2D.rad2deg(theta_obs));
                     
        end

          
    end
    
end

