classdef Watermarking
    
    methods (Static)
        function output = pseudorandom_combination(n, r, seed, salt)
            arguments
                n uint32
                r uint32
                seed uint8
                salt uint8
            end

            output = zeros(1, r);
            intGenerator = RandIntHMAC(seed, salt);

            i = 1;
            for j = n-r+1:n
                rand_int = intGenerator.randInt(1, j);
                if ~ismember(rand_int, output)
                    output(i) = rand_int;
                    i = i+1;
                else
                    output(i) = j;
                    i = i+1;
                end

            end

            output = sort(output);

        end

    end
end

