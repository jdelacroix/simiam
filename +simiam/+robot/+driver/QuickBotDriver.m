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
                else
                    fprintf('Network connection failed.\n');
                end
            end
        end
        
        function set_speeds(obj, vel_l, vel_r)
            if obj.is_connected
                command = ['$PWM=' num2str(vel_l) ',' num2str(vel_r) '*\n'];
                fprintf(obj.socket, command);
            end
        end
        
        function encoder_distance = get_encoder_distance(obj)
           if obj.is_connected
               command = '$ENVAL=?*\n';
               fprintf(obj.socket, command);
               [reply, count] = fscanf(obj.socket);

               if (count > 0)
                   fprintf('Received reply: %s\n', reply);

                   reply_l = regexp(reply,'\[-?([0-9]*|nan),', 'match');
                   reply_l = regexprep(reply_l, '[\[,]', '');

                   reply_r = regexp(reply,', (-?[0-9]*|nan)\]', 'match');
                   reply_r = regexprep(reply_r, '[, \]]', '');

                   encoder_distance = [str2double(reply_l); str2double(reply_r)]; 
               else   
                   fprintf('Received no reply.\n');
                   encoder_distance = [NaN; NaN];
               end
           end
        end
        
        function ir_voltages = get_ir_voltages(obj)
            if obj.is_connected
                command = '$IRVAL=?*\n';
                fprintf(obj.socket, command);
                [reply, count] = fscanf(obj.socket);
                
                if (count > 0)
                    fprintf('Received reply: %s\n', reply);
                    
                    reply_1 = regexp(reply,'\[-?([0-9]*|nan),', 'match');
                    reply_1 = regexprep(reply_1, '[\[,]', '');
                    
                    reply_2 = regexp(reply,', (-?[0-9]*|nan)', 'match');
                    reply_2 = regexprep(reply_2, '[, \]]', '');
                    
                    reply_3 = regexp(reply,', (-?[0-9]*|nan)', 'match');
                    reply_3 = regexprep(reply_3, '[, \]]', '');
                    
                    reply_4 = regexp(reply,', (-?[0-9]*|nan)', 'match');
                    reply_4 = regexprep(reply_4, '[, \]]', '');
                    
                    reply_5 = regexp(reply,', (-?[0-9]*|nan)\]', 'match');
                    reply_5 = regexprep(reply_5, '[, \]]', '');
                    
                    ir_voltages = [reply_1; reply_2; reply_3; reply_4; reply_5];
                else
                    fprintf('Received no reply.\n');
                    ir_voltages = [NaN; NaN; NaN; NaN; NaN];
                end
            end
        end
        
        function encoder_velocity = get_encoder_velocity(obj)
            if obj.is_connected
                command = '$ENVEL=?*\n';
                fprintf(obj.socket, command);
                [reply, count] = fscanf(obj.socket);

                if (count > 0)
                    fprintf('Received reply: %s\n', reply);

                    reply_l = regexp(reply,'\[-?([0-9]*|nan),', 'match');
                    reply_l = regexprep(reply_l, '[\[,]', '');

                    reply_r = regexp(reply,', (-?[0-9]*|nan)\]', 'match');
                    reply_r = regexprep(reply_r, '[, \]]', '');

                    encoder_velocity = [str2double(reply_l); str2double(reply_r)];
                else
                    fprintf('Received no reply.\n');
                    encoder_velocity = [NaN; NaN];
                end
            end
        end
        
        function obj = close(obj)
            if strcmp(get(obj.socket, 'Status'), 'open')
                fprintf('Closing network connection to robot.\n');
                fclose(obj.socket);
                obj.is_connected = false;
            end
        end
    end
    
end

