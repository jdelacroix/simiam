classdef AppWindow < handle

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

    properties
        parent_
        layout_
        view_
        
        ui_colors_
        ui_size_
        ui_buttons_
        
        click_src_
        center_
        
        zoom_level_
        boundary_
        ratio_
    end
    
    methods
        
        function obj = AppWindow()
            obj.ui_colors_ = struct('gray',  [220 220 220]/255, ...
                                    'green', [ 57 200  67]/255, ...
                                    'red',   [221  23  31]/255, ...
                                    'lgray', [193 193 193]/255, ...
                                    'dgray', [242 242 242]/255, ...
                                    'black', [ 48  48  48]/255);
            
            obj.ui_size_ = [1 600 800 600];
        end
        
        function load_ui(obj)
            obj.create_layout();
            obj.create_callbacks();
        end
        
        function create_layout(obj)
            
            % Create MATLAB figure
            obj.parent_ = figure('MenuBar', 'none', ...
                                 'NumberTitle', 'off', ...
                                 'Name', 'SimI.m', ...
                                 'Position', obj.ui_size_, ...
                                 'Color', obj.ui_colors_.gray);
                                  
%             set(obj.parent_, 'Renderer', 'OpenGL');

            % Create user interface (ui) layout
            obj.layout_ = GridLayout(obj.parent_, 'RowHeight', {32,'*','*', 32}, 'ColWidth', {32,'*','*','*','*','*',32}, 'Margin', 5, 'Gap', 5, 'CellColor', obj.ui_colors_.gray);

            set(obj.layout_.Container, 'BackgroundColor', obj.ui_colors_.gray);
            
            MergeCells(obj.layout_, [2 3], [1 7]);            
            FormatCells(obj.layout_, 2, 1, 'Margin', 2);
            Update(obj.layout_);
            
            % Create ui main view
            obj.view_ = axes('Parent',obj.layout_.Cell(2,1), ...
                        'ActivePositionProperty','Position', ...
                        'Box', 'on');
                    
            set(obj.view_, 'XGrid', 'on');
            set(obj.view_, 'YGrid', 'on');
            set(obj.view_, 'XTickMode', 'manual');
            set(obj.view_, 'YTickMode', 'manual');
            set(obj.view_, 'Units', 'pixels');
            view_quad = get(obj.view_, 'Position');
            set(obj.view_, 'Units', 'normal');
            
            width = view_quad(3); 
            height = view_quad(4);
            
            obj.ratio_ = width/height;          
            obj.zoom_level_ = 0.5*obj.ratio_;
            obj.boundary_ = 5;

            % Create UI buttons
            ui_args = {'Style','pushbutton', 'String','Play', 'ForegroundColor', 'w', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors_.green, 'Callback', @obj.ui_button_play};
            ui_parent = obj.layout_.Cell(4,4);
            play = uicontrol(ui_parent, ui_args{:});
            
            obj.ui_buttons_ = struct('play', play, 'play_state', false);
            
            Update(obj.layout_);
        end
        
        function create_callbacks(obj)
            
            obj.click_src_ = [0;0];
            obj.center_ = obj.click_src_; 

            % Create UI callbacks
            set(obj.view_, 'ButtonDownFcn', @obj.ui_press_mouse);
            
            jFrame = get(handle(obj.parent_), 'JavaFrame');
            jClient = jFrame.fHG1Client;
            drawnow;
            jWindow = jClient.getWindow;
            jWindow.setMinimumSize(java.awt.Dimension(640, 480));
                        
            set(obj.parent_,'ResizeFcn', @obj.ui_resize_view);
            set(obj.parent_,'WindowScrollWheelFcn', @obj.ui_zoom_view);
            set(obj.parent_,'KeyPressFcn', @obj.ui_press_key);
            set(obj.parent_, 'CloseRequestFcn', @obj.ui_close);
            
            obj.ui_set_axes();
        end
        
        
        % UI functions
        
        function ui_focus_view(obj, src, event, obj_id)
            disp('clicked robot');
            obj.center_(1) = obj.sim_.env.robots(obj_id).state.x;
            obj.center_(2) = obj.sim_.env.robots(obj_id).state.y;
            obj.ui_set_axes();
        end
        
        function ui_button_play(obj, src, event)
            obj.ui_buttons_.play_state = ~obj.ui_buttons_.play_state;
            if(obj.ui_buttons_.play_state)
                set(src, 'String', 'Pause');
                set(src, 'BackgroundColor', obj.ui_colors_.red);
            else
                set(src, 'String', 'Play');
                set(src, 'BackgroundColor', obj.ui_colors_.green);
            end
        end
        
        function ui_close(obj, src, event)
            delete(src);
        end
        
        function ui_set_axes(obj)
            set(obj.view_, 'XLim', [-1 1]*obj.zoom_level_+obj.center_(1));
            set(obj.view_, 'YLim', ([-1 1]*obj.zoom_level_/obj.ratio_)+obj.center_(2));
             
            tickd = obj.zoom_level_*0.1;
            ticks = [-fliplr(0:tickd:obj.boundary_) tickd:tickd:obj.boundary_];
            
            set(obj.view_, 'XTick', ticks);
            set(obj.view_, 'YTick', ticks);
            set(obj.view_, 'XTickLabel', []);
            set(obj.view_, 'YTickLabel', []);
        end
        
        function ui_zoom_view(obj, src, event, varargin)
            zoom_level_factor = 0.25;
            obj.zoom_level_ = obj.zoom_level_+zoom_level_factor*event.VerticalScrollCount;
            obj.zoom_level_ = min(max(obj.zoom_level_,0.1), obj.boundary_);
            obj.ui_set_axes();
        end
        
        function ui_press_mouse(obj, src, event, handles)
            click = get(obj.view_, 'CurrentPoint');
            obj.click_src_ = click(1,1:2)';
            switch(get(obj.parent_, 'SelectionType'))
                case 'extend'
%                     set(obj.parent_, 'WindowButtonMotionFcn', @obj.ui_zoom_view);
                case 'normal'
                    setptr(obj.parent_, 'closedhand');
                    set(obj.parent_, 'WindowButtonMotionFcn', @obj.ui_pan_view);
                otherwise
                    % noop
            end
            set(obj.parent_, 'WindowButtonUpFcn', @obj.ui_release_mouse);
        end
        
        function ui_press_key(obj, src, event, handles)
            disp(event.Key);
        end
        
        function ui_release_mouse(obj, src, event, handles)
            disp('released')
            setptr(obj.parent_, 'arrow');
            set(obj.parent_, 'WindowButtonMotionFcn', @obj.ui_no_op);
        end
        
        function ui_pan_view(obj, src, event, handles)
            click = get(obj.view_, 'CurrentPoint');
            click_pose = click(1,1:2)';
            diff = (obj.click_src_-click_pose);
            obj.center_ = obj.center_ + diff;
            
            % don't pan out of view
            
            if(obj.zoom_level_+obj.center_(1) > obj.boundary_)
                obj.center_(1) = obj.boundary_-obj.zoom_level_;
            elseif(-obj.zoom_level_+obj.center_(1) < -obj.boundary_)
                obj.center_(1) = -obj.boundary_+obj.zoom_level_;
            end
            
            if(obj.zoom_level_/obj.ratio_+obj.center_(2) > obj.boundary_)
                obj.center_(2) = obj.boundary_-obj.zoom_level_/obj.ratio_;
            elseif(-obj.zoom_level_/obj.ratio_+obj.center_(2) < -obj.boundary_)
                obj.center_(2) = -obj.boundary_+obj.zoom_level_/obj.ratio_;
            end
            
            obj.ui_set_axes();
        end
        
        function ui_no_op(obj, src, event, handles)
            % do nothing
        end
        
        function ui_resize_view(obj, src, event, handles)
            set(obj.view_, 'Units', 'pixels');
            view_quad = get(obj.view_, 'Position');
            set(obj.view_, 'Units', 'normal');
            width = view_quad(3);
            height = view_quad(4);
            obj.ratio_ = width/height;
            obj.ui_set_axes();
        end
    end
end
