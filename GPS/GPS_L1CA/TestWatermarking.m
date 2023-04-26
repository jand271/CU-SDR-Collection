classdef TestWatermarking < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function testSimpleCase(testCase)
            seed = uint8('jason is amazing');
            salt = uint8('jason is salty');
            sections_to_flip_correct_hmac = [1, 2, 7, 9];

            testCase.assertEqual(Watermarking.pseudorandom_combination(uint32(10), uint32(4), seed, salt), sections_to_flip_correct_hmac)
            testCase.assertEqual(Watermarking.pseudorandom_combination(uint32(10), uint32(4), seed, salt), sections_to_flip_correct_hmac)
            testCase.assertNotEqual(Watermarking.pseudorandom_combination(uint32(10), uint32(4), salt, seed), sections_to_flip_correct_hmac)
        end
    end
    
end