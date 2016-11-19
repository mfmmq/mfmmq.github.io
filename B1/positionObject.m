function [ T_ow] = positionObject()
%positionObject
% Defines a 4x4 homogeneous transformation that places an object in space
% at a random location in world cordinates and at a random orientation.
% T_ow means T:0 -> W, i.e. the transformation of points in object
% coordinates into points in world coordinates. 

T_ow = zeros(4,4);

% The bottom row is [0 0 0 1]
T_ow(4,:) = [0 0 0 1];

% Put object at random location
T_ow(1:3,4) = 2000*rand(3,1);

% Rotate to random orientation
T_ow(1:3, 1:3) = randomMatrix;

end;