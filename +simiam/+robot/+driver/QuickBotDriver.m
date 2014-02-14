classdef QuickBotDriver < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        hostname
        port
        socket
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
            obj.hostname = hostname;
            obj.port = port;
            obj.socket = udp(hostname, port, 'LocalPort', port);
            set(obj.socket, 'Timeout', 0.5);
            obj.is_connected = false;
            
            obj.update_dt = 0.2;
            obj.clock = timer('Period', obj.update_dt, ...
                              'TimerFcn', @obj.update, ...
                              'ExecutionMode', 'fixedRate', ...
                              'StartDelay', obj.update_dt);
            obj.mutex_ = simiam.util.Mutex();
            
            obj.wheel_speeds_ = [0,0];
        end
        
        function init(obj)
            if strcmp(get(obj.socket, 'Status'), 'closed')
                fprintf('Initializing network connection to robot.\n');
                fopen(obj.socket);

                command = '$CHECK*\n';
                fprintf(obj.socket, command);
                [reply, count] = fscanf(obj.socket);

                if (count > 0 && strcmp(reply, sprintf('Hello from QuickBot\n')))
                    fprintf('Network connection is live.\n');
                    obj.is_connected = true;
                    obj.reset();
                    start(obj.clock);
                else
                    fprintf('Network connection failed.\n');
                end
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
        
        function reset(obj)
            if strcmp(get(obj.socket, 'Status'), 'open')
                fprintf('Reset state of the QuickBot.\n');

                command = '$RESET*\n';
                fprintf(obj.socket, command);
            end
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
            if strcmp(get(obj.socket, 'Status'), 'open')
                if strcmp(get(obj.clock, 'Running'), 'on')
                    stop(obj.clock);
                end
                obj.mutex_.release(obj);
                obj.set_speeds(0,0);
                obj.update_speeds();
                fprintf('Closing network connection to robot.\n');
                fclose(obj.socket);
                obj.is_connected = false;
            end
        end
    end
    
    methods (Access = private)
        
        function update_speeds(obj)
            if obj.is_connected
                obj.mutex_.acquire(obj);
                command = ['$PWM=' num2str(obj.wheel_speeds_(2)) ',' num2str(obj.wheel_speeds_(1)) '*\n'];
                obj.mutex_.release(obj);
                fprintf(obj.socket, command);
            end
        end
        
        function update_encoder_ticks(obj)
           if obj.is_connected
               command = '$ENVAL=?*\n';
               fprintf(obj.socket, command);
               [reply, count] = fscanf(obj.socket);
               
               if (count > 0)
%                    fprintf('Received reply: %s\n', reply);

                   reply_array = regexp(reply,'(-?[0-9]*\.[0-9]*|nan)', 'match');
                    
                   encoder_ticks = zeros(numel(reply_array),1);
                   
                   for i = 1:numel(encoder_ticks)
                       encoder_ticks(i) = str2double(reply_array{i});
                   end
               else   
                   fprintf('Received no reply.\n');
                   encoder_ticks = [];
               end
               
               obj.mutex_.acquire(obj);
               obj.encoder_ticks_ = encoder_ticks;
               obj.mutex_.release(obj);
           end
        end
        
        function update_ir_raw_values(obj)
            if obj.is_connected
                command = '$IRVAL=?*\n';
                fprintf(obj.socket, command);
                [reply, count] = fscanf(obj.socket);
                
                if (count > 0)
%                     fprintf('Received reply: %s\n', reply);
                    
                    reply_array = regexp(reply,'(-?[0-9]*\.[0-9]*|nan)', 'match');
                    
                    ir_raw_values = zeros(numel(reply_array),1);
                    
                    for i = 1:numel(ir_raw_values)
                        ir_raw_values(i) = str2double(reply_array{i});
                    end
                else
                    fprintf('Received no reply.\n');
                    ir_raw_values = [];
                end
                
                obj.mutex_.acquire(obj);
                obj.ir_raw_values_ = ir_raw_values;
                obj.mutex_.release(obj);
            end
        end
    end
    
end

