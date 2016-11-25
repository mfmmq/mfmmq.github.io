function [ KMatrix ] = singleVectorCameraModel( Parameters )
%singleVectorCameraModel
% Builds a camera model using a single vector of Parameters and returns the
% resulting K-Matrix in KMatrix
% 
% There must be 8 parameters passed ordered as
% (1) ChipWidth, an integer describing the number of horizontal pixels
% (2) ChipHeight, an integer describing the number of vertical pixels
% (3) FocalLength, the camera focal length between 1.0 to 100.0 mm
% (4) PixelWidth, the pixel width between 0.001 and 0.1 mm
% (5) PixelHeight, the pixel height between 0.001 and 0.1 mm
% (6) Skewness, the skewness in u-pixels between -0.1 and 0.1
% (7) P_u, the offset to the principal point as a fraction of the width
% (8) P_v, the offset to the principal point as a fraction of the height


% Check if 8 parameters
if length(Parameters) ~= 8
    error('There must be 8 parameters passed');
end


ChipWidth = Parameters(1);
ChipHeight = Parameters(2);
FocalLength = Parameters(3);
PixelWidth = Parameters(4);
PixelHeight = Parameters(5);
Skewness = Parameters(6);
P_u = Parameters(7);
P_v = Parameters(8);

% Test inputs
Frac = ChipWidth - fix(ChipWidth);
if Frac ~= 0 
    error('ChipWidth is not integer');
end

Frac = ChipHeight - fix(ChipHeight);
if Frac ~= 0 
    error('ChipHeight is not integer');
end


% Test ranges
testRange(ChipWidth, 200, 4000, 'ChipWidth');
testRange(ChipHeight, 300, 5000, 'ChipHeight');
testRange(FocalLength, 1.0, 100.0, 'FocalLength');
testRange(PixelWidth, 0.001, 0.1, 'PixelWidth');
testRange(PixelHeight, 0.001, 0.1, 'PixelHeight');
testRange(Skewness, -0.1, 0.1, 'Skewness');
testRange(P_u, 0.25, 0.75, 'P_u');
testRange(P_v, -.25, 0.75, 'P_v');

% Focal length in u-pixels
FuPixels = FocalLength / PixelWidth;
PixelHeight
PixelWidth
% Focal length in v-pixels
FvPixels = FocalLength / PixelHeight;
FocalLength
% Construct the K-Matrix for return
KMatrix = ...
    [FuPixels   Skewness    P_u*ChipWidth;
     0          FvPixels    P_v*ChipHeight;
     0          0           1]


    
end

