classdef RandIntHMAC < handle
    %RANDINTHMAC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        seed
        salt
        counter
        start_bit
        hmac_cache
    end
    
    methods
        function obj = RandIntHMAC(seed, salt)
            arguments
                seed uint8
                salt uint8
            end
            obj.seed = seed;
            obj.salt = salt;
            obj.counter = uint64(0);
            obj.start_bit = 1;
        end
        
        function rand_int = randInt(obj, a, b)
            if isempty(obj.hmac_cache)
                obj.hmac_cache = obj.hmac_sha_256(obj.seed, [obj.salt, typecast(obj.counter,'uint8')]);
            end

            bits_needed = floor(log2(double(b-a))) + 1;
            if bits_needed > 256 - obj.start_bit + 1
                obj.counter = obj.counter + 1;
                obj.start_bit = 0;
                obj.hmac_cache = [];
                rand_int = obj.randInt(a, b);
                return
            end

            rand_int_bin = obj.hmac_cache(obj.start_bit:obj.start_bit+bits_needed-1);
            rand_int = RandIntHMAC.bi2de(rand_int_bin');
            obj.start_bit = obj.start_bit + bits_needed;

            if rand_int > (b-a)
                rand_int = obj.randInt(a, b);
            else
                rand_int = rand_int + a;
            end
        end
        end

    methods(Access=private, Static)
        function output = sha_256(input)
            import javax.crypto.*
            import java.security.MessageDigest
            mDigest = MessageDigest.getInstance("SHA-256");
            output = typecast(mDigest.digest(input), 'uint8');
        end

        function output = hmac_sha_256(key, message)
            import javax.crypto.*
            import javax.crypto.Mac
            import java.security.MessageDigest
            import javax.crypto.spec.SecretKeySpec
            m_a_c = Mac.getInstance("HmacSHA256");
            secretKeySpec = SecretKeySpec(key, "HmacSHA256");
            m_a_c.init(secretKeySpec);
            output = typecast(m_a_c.doFinal(message), 'uint8');
            output = RandIntHMAC.de2bi(output, 8);
            output = output';
            output = output(:);
        end

        function binary_array = de2bi(array, size)
            % DE2BI Convert binary arrays with Left-MSB orientation to decimal arrays.
            %   array - an array of decimal number
            %   size - desired size of binary output for each number
            %   returns - binary array as logical array
            max_elem = max(array);
            min_size = floor(log2(double(max_elem))) + 1;
            if size < min_size
                error('DATACONVERSIONS:numColsToSmall', ...
                      'Specified number of columns in output matrix is too small');
            else
                binary_array = logical(rem(floor(double(array(:)) * pow2(1 - size:0)), 2));
            end
        end

        function dec_number = bi2de(binary_num)
            % BI2DE Converts a binary number into its decimal equivelent
            % using left msb
            %   binary_num - a logical array for a binary number
            %   returns - a decimal number as double
            pow2vector = 2.^((size(binary_num, 2) - 1):-1:0)';
            dec_number = binary_num * pow2vector;

        end
    end
end

