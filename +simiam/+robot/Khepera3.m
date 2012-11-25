classdef Khepera3 < simiam.robot.Robot

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
        wheel_radius
        wheel_base_length
        ticks_per_rev
        speed_factor
        
        encoders = simiam.robot.sensor.WheelEncoder.empty(1,0);
        ir_array = simiam.robot.sensor.ProximitySensor.empty(1,0);
    end
    
    properties (Dependent = true)
        state
    end
    
    methods
        function obj = Khepera3(parent)
           obj = obj@simiam.robot.Robot(parent);
           
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
            
            obj.addSurface(k3_base, [ 0.8 0.8 0.8 ]);
            obj.addSurface(k3_top_plate, [ 0.0 0.0 0.0 ]);
            
            % Add parts to the Khepera3 robot
            obj.wheel_radius = 0.021;           % 42mm
            obj.wheel_base_length = 0.0885;     % 88.5mm
            obj.ticks_per_rev = 2765;
            obj.speed_factor = 6.2953e-6;
            
            obj.encoders(1) = simiam.robot.sensor.WheelEncoder('right_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            obj.encoders(2) = simiam.robot.sensor.WheelEncoder('left_wheel', obj.wheel_radius, obj.wheel_base_length, obj.ticks_per_rev);
            
            import simiam.robot.sensor.ProximitySensor;
            import simiam.ui.Drawable;
            import simiam.robot.Khepera3;
            
            obj.ir_array(1) = ProximitySensor(parent, 'IR', -0.038,  0.048,  Drawable.deg2rad(128),  0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(2) = ProximitySensor(parent, 'IR',  0.019,  0.064,  Drawable.deg2rad(75),   0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(3) = ProximitySensor(parent, 'IR',  0.050,  0.050,  Drawable.deg2rad(42),   0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(4) = ProximitySensor(parent, 'IR',  0.070,  0.017,  Drawable.deg2rad(13),   0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(5) = ProximitySensor(parent, 'IR',  0.070, -0.017,  Drawable.deg2rad(-13),  0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(6) = ProximitySensor(parent, 'IR',  0.050, -0.050,  Drawable.deg2rad(-42),  0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(7) = ProximitySensor(parent, 'IR',  0.019, -0.064,  Drawable.deg2rad(-75),  0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(8) = ProximitySensor(parent, 'IR', -0.038, -0.048,  Drawable.deg2rad(-128), 0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
            obj.ir_array(9) = ProximitySensor(parent, 'IR', -0.048,      0,  Drawable.deg2rad(180),  0.2, Drawable.deg2rad(20), @Khepera3.ir_distance_to_raw);
        end
        
        function val = get.state(obj)
            error('The state of the robot is not directly observable. Check the sensors instead!');
        end
    end
    
    methods (Static)
        function raw = ir_distance_to_raw(distance)
            if(distance < 0.02)
                raw = 3960;
            else
                raw = ceil(3960*exp(-30*(distance-0.02)));
            end
        end
    end
    
end

