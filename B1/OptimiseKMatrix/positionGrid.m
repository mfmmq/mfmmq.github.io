function [ T_ow ] = positionGrid()
%positionGrid
% Defines a 4x4 homogeneous transformation that places an object in space
% at a random location in world coordinates and at a random orientation.
% T_ow means T:O->W, i.e. the transformation of points in object
% coordinates into points in world coordinates.

T_ow = zeros(4,4);

% Fixing botom row
T_ow(4,:) = [0 0 0 1];

% Put at some random location 
T_ow(1:3,4) = 2000*rand(3,1);

% Give random orientation
T_ow(1:3,1:3) = randomRotationMatrix;

end
