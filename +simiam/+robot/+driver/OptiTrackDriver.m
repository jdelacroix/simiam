classdef OptiTrackDriver < handle
    properties (Hidden = true, SetAccess = private)
        java_handle
    end
    
    properties
        hostname
        port 
        id
    end
    
    methods   
        function obj = OptiTrackDriver(hostname, port, id)
            obj.java_handle = javaObject('matlab.simulator.optitrack.OptiTrackDriver', hostname, port);
            obj.port = port;
            obj.hostname = hostname;
            obj.id = id;
        end
        
        function val = update(obj)
            val = obj.java_handle.mRecvData(obj.id);
        end
        
        function close(obj)
            fprintf('Closing hardware link to optitrack.\n');
            obj.java_handle.mClose();
        end
        
    end
end

