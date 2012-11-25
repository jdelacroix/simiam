classdef Robot < simiam.ui.Drawable

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software
    
    properties
    end
    
    methods
        function obj = Robot(parent, start_pose)
            obj = obj@simiam.ui.Drawable(parent, start_pose);
        end
    end
    
end

