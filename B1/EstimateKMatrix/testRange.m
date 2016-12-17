function [] = testRange(Parameter, MinVal, MaxVal, Name)
%testRange
% Tests the range of parameter against minval and maxval
% If the test fails, it returns an error quoting the parameter

if Parameter < MinVal || Parameter > MaxVal
    error('Input parameter %s, value %d was out of range', ...
        Name, Parameter);
end


end
