function [ R ] = rodriguesRotation ( rotationAxis , rotationAngle)
%rodriguesRotation
% Generates a random matrix given the axis of rotation and angle of
% rotation in randians (not an angle-axis representation, where angle is
% encoded as the norm of the axis).
%
% rotationAxis must be a vector with 3 elements and must be non-zero. The
% code normalises the vector so it does not matter if the vector is not
% unit length.
% rotationAngle is in radians.
%
% The algorithm used is Rodrigues Rotation Formula


% Check input matches conditions above
if length(rotationAxis) ~= 3
    error('The rotation axis must only have 3 elements');
end


% Create unit rotation axis
normAxis = norm(rotationAxis);

if normAxis < eps
    error('Cannot normalise the axis reliably');
end

% Check if rotationAxis is non-zero
if rotationAxis == [0 0 0]
    error('Rotation axis cannot be non-zero');
end

rotationAxis = rotationAxis/normAxis;

% Formulate the cross product matrix
K = [   0                   -rotationAxis(3)    rotationAxis(2)
        rotationAxis(3)     0                   -rotationAxis(1)
        -rotationAxis(2)    rotationAxis(1)     0                   ];
    
% Compute the rotation matrix using Rodrigues Rotation Formula
R = eye(3) + sin(rotationAngle)*K + (1-cos(rotationAngle))*K^2;

end


