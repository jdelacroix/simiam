classdef ProximitySensor < simiam.ui.Drawable
    
% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        type
        
        range       % measured range to detected object
        spread      % view angle of proximity sensor
        location    % placement location on robot
        
        map         % if sensor is not natively [m], convert to [raw]
    end
    
    properties (Access = private)
        value
    end
    
    properties (Dependent = true)
        state
    end
    
    methods
        function obj = ProximitySensor(parent, type, x, y, theta, r, phi, varargin)
            obj = obj@simiam.ui.Drawable(parent, 0, 0, 0);
            
            obj.type = type;
            obj.location = simiam.ui.Pose2D(x, y, theta);
            T = obj.location.transformationMatrix();
            r1 = r*tan(phi/4); r2 = r*tan(phi/2);
            sensorCone =  [              0     0   1;
                            sqrt(r^2-r2^2)    r2   1;
                            sqrt(r^2-r1^2)    r1   1;
                                         r     0   1;
                            sqrt(r^2-r1^2)   -r1   1;
                            sqrt(r^2-r2^2)   -r2   1];
            obj.addSurface(sensorCone*T', [ 0.8 0.8 1 ]);
            set(obj.surfaces.get_iterator().next().handle, 'EdgeColor', 'b');
            
            obj.range = r;
            obj.spread = phi;
            obj.value = r;
            
            if nargin == 1 && isa(varargin{1}, 'function_handle')
                obj.map = varargin{1};
            end
        end
               
        function set.state(obj,val)
            obj.value = val;
            
            r1 = val*tan(obj.spread/4); r2 = val*tan(obj.spread/2);
            sensorCone =  [                0    0   1;
                            sqrt(val^2-r2^2)   r2   1;
                            sqrt(val^2-r1^2)   r1   1;
                                         val    0   1;
                            sqrt(val^2-r1^2)  -r1   1;
                            sqrt(val^2-r2^2)  -r2   1];
            T = obj.location.transformationMatrix();
            obj.surfaces.get_iterator().next().geometry = sensorCone*T';
            obj.drawSurfaces();
        end
        
        function val = get.state(obj)
            % convert IR sensor value from [mm] to raw units
            if(isa(obj.map, 'function_handle'))
                val = obj.map(obj.value);
            else
                val = obj.value;
            end
        end
        
    end
end