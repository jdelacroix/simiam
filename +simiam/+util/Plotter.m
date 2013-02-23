classdef Plotter < handle
% PLOTTER supports plotting data in 2D with a reference signal.
%
% Properties:
%   r           - Reference signal
%   x           - Time
%   y           - Output signal
%
% Methods:
%   plot_2d_ref - Plots an output and reference signal over time.
    
    properties
    %% PROPERTIES
    
        t   % Time
        y   % Output signal
        r   % Reference signal
        
        h
        g
        a
    end
    
    methods
        function obj = Plotter()
        % PLOTTER Constructor
        
            obj.t = 0;
            obj.y = 0;
            obj.r = 0;
            obj.h = -1;
            obj.g = -1;
            
            figure;
            obj.a = axes;
            set(obj.a, 'NextPlot', 'add');
            hold(obj.a, 'all');
            obj.t = 0;
        end
        
        function plot_2d_ref(obj, dt, y, r, color)
        %% PLOT_2D_REF Plots an output and reference signal over time
        %   [h,g] = plot_2d_ref(obj, h, g, x, y, r) plots the output signal
        %   (y) and reference signal (r) versus time (t).
        
            if ~ishandle(obj.h)
                obj.h = plot(obj.a, dt, y, 'b');
                obj.g = plot(obj.a, dt, r, '--');
                set(obj.g, 'Color', color);
                obj.t = obj.t(end);
                obj.y = obj.y(end);
                obj.r = obj.r(end);
            end
            
            obj.t = [obj.t obj.t(end)+dt];
            obj.y = [obj.y y];
            obj.r = [obj.r r];
            
            set(obj.h, 'XData', obj.t);
            set(obj.h, 'YData', obj.y);   
            set(obj.g, 'XData', obj.t);
            set(obj.g, 'YData', obj.r);
            
        end
        
        function switch_2d_ref(obj)
            obj.h = -1;
        end
        
    end
    
end
