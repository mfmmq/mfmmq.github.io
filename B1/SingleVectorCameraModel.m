function [KMatrix] = SingleVectorCameraModel (arg_in)
%SingleVectorCameraModel
% Generates a camera model with a single vector and
% returns the resulting matrix in KMatrix


% Variables (8)
%
% x_chip = chip width in pixels, range [200,4000]
% y_chip = chip height in pixels, range [300, 5000]
% focal_length = focal length in mm, range [1.0, 100.0]
% x_eff = effective width of pixel in x in mm, range [0.0001, 0.1]
% y_eff = effective height of pixel in y in mm, range [0.0001, 0.1]
% skew = skewness in range [-0.1, 0.1] x pixels
% x_offset = principle pt offset in x dir, fraction of the width of the
%            chip, range [0.25, 0.75]
% y_offset = principle pt offset in y dir, fraction of the height of the
%            chip, range [0.25, 0.75]



% Check number of inputs
if (length(arg_in) ~= 8)
    error('Number of inputs must be 8');
end


% Pass variables
x_chip = arg_in(1);
y_chip = arg_in(2);
focal_length = arg_in(3);
x_eff = arg_in(4);
y_eff = arg_in(5);
skew = arg_in(6);
x_offset = arg_in(7);
y_offset = arg_in(8);


% Check if chip width, height are integers
if (x_chip ~= fix(x_chip))
    error('Chip width not an integer');
end
if (y_chip ~= fix(y_chip))
    error ('Chip height not an integer');
end


% Test ranges
testRange(x_chip, 200, 4000, 'Chip width');
testRange(y_chip, 300, 5000, 'Chip height');
testRange(focal_length, 1.0, 100.0, 'Focal height');
testRange(x_eff, 0.0001, 0.1, 'Effective x pixel width');
testRange(y_eff, 0.001, 0.1, 'Effective y pixel height');
testRange(skew, -0.1, 0.1, 'Skewness in range of x pixels');
testRange(x_offset, 0.25, 0.75, 'Principle point x offset');
testRange(y_offset, 0.25, 0.75, 'Principle point y offset');

% Get focal length in x pixels (width)
x_focal = focal_length / x_eff; % Focal width (length/ effective width)

% Get focal length in y pixels (height)
y_focal = focal_length / y_eff; % Focal height (length/effective height) 

% Construct K-Matrix
KMatrix = [ 
    x_focal     skew        x_offset*x_chip;
    0           y_focal     y_offset*y_chip;
    0           0           1               ];

return;










