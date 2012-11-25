classdef ProximitySensor < simiam.ui.Drawable
    
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        type
        
        min_range   % minimum range of proximity sensor
        max_range   % maximum range of proximity sensor
        spread      % view angle of proximity sensor
        location    % placement location on robot
        
        map         % if sensor is not natively [m], convert to [raw]
    end
    
    properties (Access = private)
        range       % measured range to detected object
    end
    
    methods
        
        function obj = ProximitySensor(parent, type, r_pose, pose, r_min, r_max, phi, varargin)
            obj = obj@simiam.ui.Drawable(parent, r_pose);
            
            obj.type = type;
            obj.location = pose;
            
            T = obj.location.get_transformation_matrix();
            r = r_max;
            r1 = r*tan(phi/4);
            r2 = r*tan(phi/2);
            sensor_cone =  [              0     0   1;
                             sqrt(r^2-r2^2)    r2   1;
                             sqrt(r^2-r1^2)    r1   1;
                                          r     0   1;
                             sqrt(r^2-r1^2)   -r1   1;
                             sqrt(r^2-r2^2)   -r2   1];
            obj.add_surface(sensor_cone*T', [ 0.8 0.8 1 ]);
            set(obj.surfaces.get_iterator().next().handle, 'EdgeColor', 'b');
            
            obj.range = r;
            obj.spread = phi;
            
            obj.max_range = r_max;
            obj.min_range = r_min;
            
            if nargin == 1 && isa(varargin{1}, 'function_handle')
                obj.map = varargin{1};
            end
        end
               
        function update_range(obj, distance)
            obj.range = obj.limit_to_sensor(distance);
            
            r1 = distance*tan(obj.spread/4);
            r2 = distance*tan(obj.spread/2);
            sensor_cone =  [                0    0   1;
                             sqrt(val^2-r2^2)   r2   1;
                             sqrt(val^2-r1^2)   r1   1;
                                     distance   0   1;
                             sqrt(val^2-r1^2)  -r1   1;
                             sqrt(val^2-r2^2)  -r2   1];
            T = obj.location.get_transformation_matrix();
            surface = obj.surfaces.get_iterator().next();
            surface.geometry = sensor_cone*T';
            if (distance < obj.r_max)
                set(surface.handle, 'EdgeColor', 'r');
                set(surface.handle, 'FaceColor', [1 0.8 0.8]);
            else
                set(surface.handle, 'EdgeColor', 'b')
                set(surface.handle, 'FaceColor', [0.8 0.8 1]);
            end
            obj.draw_surfaces();
        end
        
        function raw = get_range(obj)
            if(isa(obj.map, 'function_handle'))
                % convert IR sensor value from [mm] to raw units
                raw = obj.map(obj.range);
            else
                raw = obj.range;
            end
        end
        
        function distance = limit_to_sensor(obj, distance)
            distance = min(max(distance, obj.min_range), obj.max_range);
        end
        
    end
end