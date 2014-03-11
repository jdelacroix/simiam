classdef QuickBotDriver < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties (Hidden = true, SetAccess = private)
        java_handle
    end

    properties
        hostname
        port
        
        is_connected
        
        clock
        update_dt
    end
    
    properties (Access = private)
        mutex_
        
        encoder_ticks_
        ir_raw_values_
        wheel_speeds_
    end
    
    methods
        function obj = QuickBotDriver(hostname, port)
            obj.java_handle = javaObject('edu.gatech.gritslab.QuickBotConnector', hostname, port);
            
            obj.hostname = hostname;
            obj.port = port;
            
            obj.update_dt = 0.2;
            obj.clock = timer('Period', obj.update_dt, ...
                              'TimerFcn', @obj.update, ...
                              'ExecutionMode', 'fixedRate', ...
                              'StartDelay', obj.update_dt);
            obj.mutex_ = simiam.util.Mutex();
            
            obj.wheel_speeds_ = [0,0];
        end
        
        function init(obj)
            fprintf('Initializing network connection to robot.\n');
            status = obj.java_handle.initialize();
            if status
                fprintf('Network connection is live.\n');
                obj.is_connected = true;
                obj.java_handle.reset();
                start(obj.clock);
            else
                fprintf('Network connection failed.\n');
            end
        end
        
        function update(obj, src, event)
            if obj.is_connected
                tstart = tic;
                obj.update_encoder_ticks();
                obj.update_ir_raw_values();
                obj.update_speeds();
                fprintf('TIMING: (hw) @ %0.3fs\n', toc(tstart));
            end
        end
        
        function set_speeds(obj, vel_r, vel_l)
            obj.mutex_.acquire(obj);
            obj.wheel_speeds_ = [vel_r, vel_l];
            obj.mutex_.release(obj);
        end
        
        function encoder_ticks = get_encoder_ticks(obj)
            obj.mutex_.acquire(obj);
            encoder_ticks = obj.encoder_ticks_;
            obj.mutex_.release(obj);
        end
        
        function ir_raw_values = get_ir_raw_values(obj)
            obj.mutex_.acquire(obj);
            ir_raw_values = obj.ir_raw_values_;
            obj.mutex_.release(obj);
        end
        
        function obj = close(obj)
            if obj.is_connected
                if strcmp(get(obj.clock, 'Running'), 'on')
                    stop(obj.clock);
                end
                obj.mutex_.release(obj);
                obj.set_speeds(0,0);
                obj.update_speeds();
                fprintf('Closing network connection to robot.\n');
                obj.java_handle.close();
                obj.is_connected = false;
            end
        end
    end
    
    methods (Access = private)
        
        function update_speeds(obj)
            if obj.is_connected
                obj.mutex_.acquire(obj);
                obj.java_handle.setMotorPWM(obj.wheel_speeds_(1), obj.wheel_speeds_(2));
                obj.mutex_.release(obj);
            end
        end
        
        function update_encoder_ticks(obj)
           if obj.is_connected
               obj.mutex_.acquire(obj);
               obj.encoder_ticks_ = obj.java_handle.getEncoderTicks();
               obj.mutex_.release(obj);
           end
        end
        
        function update_ir_raw_values(obj)
            if obj.is_connected
                obj.mutex_.acquire(obj);
                obj.ir_raw_values_ = obj.java_handle.getIREncodedValues();
                obj.mutex_.release(obj);
            end
        end
    end
    
end

