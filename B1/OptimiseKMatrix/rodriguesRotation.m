function [ R ] = rodriguesRotation(RotationAxis, RotationAngle)
%rodriguesRotation
% Generates a rotation matrix given the axis of rotation and the angle of
% rotation in radians (Not an angle-axis representation, where angle is
% encoded as the norm of the axis)
%
% RotationAxis must be a vector with 3 elements and must be non-zero. The
% code normalises the vector and thus it does not matter if the vector is
% not of unit length. 
% RotationAngle is in radians
%
% The algorithm used is Rodrigues Rotation Formula

% Perform tests on correctness of input
if length(RotationAxis) ~= 3
    error('The rotation axis must only have 3 elements');
end

NormAxis = norm(RotationAxis);

if NormAxis < eps
    error('Cannot normalise the axis reliably');
end

% Normalise the axis
RotationAxis = RotationAxis / NormAxis;

% Formulate cross product matrix
K = [   0                   -RotationAxis(3)    RotationAxis(2); ...
        RotationAxis(3)     0                   -RotationAxis(1); ...
        -RotationAxis(2)    RotationAxis(1)     0];

% Compute the rotation matrix using the Rodrigues Rotation Formula
R = eye(3) + sin(RotationAngle)*K + (1 - cos(RotationAngle))*K^2;

end
