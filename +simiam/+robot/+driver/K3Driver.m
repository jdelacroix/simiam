classdef K3Driver < handle
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
        function obj = K3Driver(hostname, port)
            obj.java_handle = javaObject('edu.gatech.gritslab.Khepera3Connector', hostname, port);
            obj.port = port;
            obj.hostname = hostname;
            
            obj.update_dt = 0.05;
            obj.clock = timer('Period', obj.update_dt, ...
                              'TimerFcn', @obj.update, ...
                              'ExecutionMode', 'fixedRate', ...
                              'StartDelay', obj.update_dt);
            obj.mutex_ = simiam.util.Mutex();
            
            obj.wheel_speeds_ = [0,0];
        end
        
        function init(obj)
            fprintf('Initializing network connection to robot.\n');
            obj.java_handle.mSendInit();
            
            fprintf('Network connection is live.\n');
            obj.is_connected = true;
            start(obj.clock);
        end
        
        function update(obj, src, event)
            if obj.is_connected
                tstart = tic;
                obj.update_data();
                obj.update_speeds();
                fprintf('TIMING: (hw) @ %0.3fs\n', toc(tstart));
            end
        end
        
        function set_speed(obj, vel_r, vel_l)
            obj.mutex_.acquire(obj);
            obj.wheel_speeds = [vel_r, vel_l];
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
                obj.set_speed(0,0);
                obj.update_speeds();
                fprintf('Closing network connection to robot.\n');
                obj.java_handle.mClose();
                obj.is_connected = false;
            end
        end
        
    end
    
    methods (Access = private)
        function update_speeds(obj)
            obj.mutex_.acquire(obj);
            obj.java_handle.mSendControl(vel_r, vel_l);
            obj.mutex_.release(obj);
        end
        
        function update_data(obj)
            obj.mutex_.acquire(obj);
            data = obj.java_handle.mRecvData();
            obj.encoder_ticks_ = [double(data(12)), double(data(13))];
            obj.ir_raw_values_ = double(data(1:9));
            obj.mutex_.release(obj);
        end
        
    end
end

