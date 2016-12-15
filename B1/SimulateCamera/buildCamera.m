function [ KMatrix, CameraHeight, CameraWidth ] = buildCamera
%buildCamera
% Function creates a camera using the singleVectorCameraModel

% Defines parameters that describes the camera
% Code calls SingleVectorCameraModel.m to perform construction of the
% K-matrix

% Define parameters 
arg_in(1) = randi([200, 4000]);     % x_chip, chip width in pixels
arg_in(2) = randi([300, 5000]);     % y_chip, chip height in pixels
arg_in(3) = randi([10, 1000])/10;   % focal length in mm
arg_in(4) = randi([1, 100])/1000;    % x_eff, effective x width of pixel in mm
arg_in(5) = randi([1, 100])/1000;    % y_eff, effective y height of pixel in mm
arg_in(6) = randi([-1, 1])/10;      % skew, skewness in xpixels
arg_in(7) = randi([25, 75])/100;    % x_offset, principle pt offset in x frac
arg_in(8) = randi([25, 75])/100;    % y_offset, principle pt offset in y frac

% Define camera size
% How to properly define these?
CameraHeight = arg_in(2);
CameraWidth = arg_in(1);

KMatrix = singleVectorCameraModel(arg_in);



end


