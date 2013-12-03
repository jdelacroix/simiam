classdef SecureHashAlgorithm < handle
    
    % Copyright (C) 2013, Georgia Tech Research Corporation
    % see the LICENSE file included with this software
    
    % Copied and modified from Coursera's assignments-api-examples.zip
    
    properties
        
    end
    
    methods (Static)

        function hash = generate_sha1_hash(str)
            
            % Initialize variables
            h0 = uint32(1732584193);
            h1 = uint32(4023233417);
            h2 = uint32(2562383102);
            h3 = uint32(271733878);
            h4 = uint32(3285377520);
            
            % Convert to word array
            strlen = numel(str);
            
            % Break string into chars and append the bit 1 to the message
            mC = [double(str) 128];
            mC = [mC zeros(1, 4-mod(numel(mC), 4), 'uint8')];
            
            numB = strlen * 8;
            if exist('idivide')
                numC = idivide(uint32(numB + 65), 512, 'ceil');
            else
                numC = ceil(double(numB + 65)/512);
            end
            numW = numC * 16;
            mW = zeros(numW, 1, 'uint32');
            
            idx = 1;
            for i = 1:4:strlen + 1
                mW(idx) = bitor(bitor(bitor( ...
                    bitshift(uint32(mC(i)), 24), ...
                    bitshift(uint32(mC(i+1)), 16)), ...
                    bitshift(uint32(mC(i+2)), 8)), ...
                    uint32(mC(i+3)));
                idx = idx + 1;
            end
            
            % Append length of message
            mW(numW - 1) = uint32(bitshift(uint64(numB), -32));
            mW(numW) = uint32(bitshift(bitshift(uint64(numB), 32), -32));
            
            % Process the message in successive 512-bit chs
            for cId = 1 : double(numC)
                cSt = (cId - 1) * 16 + 1;
                cEnd = cId * 16;
                ch = mW(cSt : cEnd);
                
                % Extend the sixteen 32-bit words into eighty 32-bit words
                for j = 17 : 80
                    ch(j) = ch(j - 3);
                    ch(j) = bitxor(ch(j), ch(j - 8));
                    ch(j) = bitxor(ch(j), ch(j - 14));
                    ch(j) = bitxor(ch(j), ch(j - 16));
                    ch(j) = simiam.util.SecureHashAlgorithm.bitrotate(ch(j), 1);
                end
                
                % Initialize hash value for this ch
                a = h0;
                b = h1;
                c = h2;
                d = h3;
                e = h4;
                
                % Main loop
                for i = 1 : 80
                    if(i >= 1 && i <= 20)
                        f = bitor(bitand(b, c), bitand(bitcmp(b), d));
                        k = uint32(1518500249);
                    elseif(i >= 21 && i <= 40)
                        f = bitxor(bitxor(b, c), d);
                        k = uint32(1859775393);
                    elseif(i >= 41 && i <= 60)
                        f = bitor(bitor(bitand(b, c), bitand(b, d)), bitand(c, d));
                        k = uint32(2400959708);
                    elseif(i >= 61 && i <= 80)
                        f = bitxor(bitxor(b, c), d);
                        k = uint32(3395469782);
                    end
                    
                    t = simiam.util.SecureHashAlgorithm.bitrotate(a, 5);
                    t = simiam.util.SecureHashAlgorithm.bitadd(t, f);
                    t = simiam.util.SecureHashAlgorithm.bitadd(t, e);
                    t = simiam.util.SecureHashAlgorithm.bitadd(t, k);
                    t = simiam.util.SecureHashAlgorithm.bitadd(t, ch(i));
                    e = d;
                    d = c;
                    c = simiam.util.SecureHashAlgorithm.bitrotate(b, 30);
                    b = a;
                    a = t;
                    
                end
                h0 = simiam.util.SecureHashAlgorithm.bitadd(h0, a);
                h1 = simiam.util.SecureHashAlgorithm.bitadd(h1, b);
                h2 = simiam.util.SecureHashAlgorithm.bitadd(h2, c);
                h3 = simiam.util.SecureHashAlgorithm.bitadd(h3, d);
                h4 = simiam.util.SecureHashAlgorithm.bitadd(h4, e);
                
            end
            
            hash = reshape(dec2hex(double([h0 h1 h2 h3 h4]), 8)', [1 40]);
            
            hash = lower(hash);
            
        end
        
        function ret = bitadd(iA, iB)
            ret = double(iA) + double(iB);
            ret = bitset(ret, 33, 0);
            ret = uint32(ret);
        end
        
        function ret = bitrotate(iA, places)
            t = bitshift(iA, places - 32);
            ret = bitshift(iA, places);
            ret = bitor(ret, t);
        end
        
    end
    
end