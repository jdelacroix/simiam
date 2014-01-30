classdef QuickBotDriver < handle

% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        hostname
        port
        socket
        is_connected
    end
    
    methods
        function obj = QuickBotDriver(hostname, port)
            obj.hostname = hostname;
            obj.port = port;
            obj.socket = udp(hostname, port, 'LocalPort', port);
            obj.is_connected = false;
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
                else
                    fprintf('Network connection failed.\n');
                end
            end
        end
        
        function set_speeds(obj, vel_r, vel_l)
            if obj.is_connected
                command = ['$PWM=' num2str(vel_l) ',' num2str(vel_r) '*\n'];
                fprintf(obj.socket, command);
            end
        end
        
        function reset(obj)
            if strcmp(get(obj.socket, 'Status'), 'open')
                fprintf('Reset state of the QuickBot.\n');

                command = '$RESET*\n';
                fprintf(obj.socket, command);
            end
        end
        
        function encoder_ticks = get_encoder_ticks(obj)
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
           end
        end
        
        function ir_raw_values = get_ir_raw_values(obj)
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
            end
        end
        
        function encoder_velocity = get_encoder_velocity(obj)
            if obj.is_connected
                command = '$ENVEL=?*\n';
                fprintf(obj.socket, command);
                [reply, count] = fscanf(obj.socket);

                if (count > 0)
%                     fprintf('Received reply: %s\n', reply);

                    reply_array = regexp(reply,'(-?[0-9]*\.[0-9]*|nan)', 'match');
                    
                    encoder_velocity = zeros(numel(reply_array),1);
                    
                    for i = 1:numel(encoder_velocity)
                        encoder_velocity(i) = str2double(reply_array{i});
                    end
                else
                    fprintf('Received no reply.\n');
                    encoder_velocity = [];
                end
            end
        end
        
        function obj = close(obj)
            if strcmp(get(obj.socket, 'Status'), 'open')
                obj.set_speeds(0,0);
                fprintf('Closing network connection to robot.\n');
                fclose(obj.socket);
                obj.is_connected = false;
            end
        end
    end
    
end

