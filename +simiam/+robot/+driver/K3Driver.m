classdef K3Driver < handle
    properties (Hidden = true, SetAccess = private)
        java_handle
    end
    
    properties
        hostname
        port 
    end
    
    methods   
        function obj = K3Driver(hostname, port)
            obj.java_handle = javaObject('matlab.simulator.k3.K3Driver', hostname, port);
            obj.port = port;
            obj.hostname = hostname;
        end
        
        function init(obj)
            fprintf('Initializing hardware link to robot.\n');
            obj.java_handle.mSendInit();
        end
        
        function set_speed(obj, vel_r, vel_l)
            obj.java_handle.mSendControl(vel_r, vel_l);
        end
        
        function val = update(obj)
            val = obj.java_handle.mRecvData();
        end
        
        function close(obj)
            fprintf('Closing hardware link to robot.\n');
            obj.java_handle.mClose();
        end
        
    end
end

