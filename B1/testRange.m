function [] = testRange(arg_in, min, max, description)
%testRange
% Tests the range of camera variables against their minimum and maximum
% values, if test fails return an error message

if ((arg_in < min) || (arg_in > max))
    error('Input for %s, value %d, is out of range [%f,%f]', description,arg_in, min, max);
end

end
