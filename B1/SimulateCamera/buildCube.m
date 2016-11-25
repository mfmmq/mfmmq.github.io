function [ Cube ] = buildCube()
%buildCube
% Builds a 1m x 1m cube

Cube = [    0   1   0   0   0   0   0   1   0   0   1   1   1   1
            0   0   0   1   0   0   0   0   0   1   0   0   0   1
            0   0   0   0   0   1   1   1   1   1   0   1   0   0
            1   1   1   1   1   1   1   1   1   1   1   1   1   1 
            ];
        
Matrix = [  0   1   0   0   1   1   0   1   1   1   
            1   1   1   1   0   1   1   1   1   1
            0   0   0   1   1   1   1   1   0   1
            1   1   1   1   1   1   1   1   1   1
            ];
        
% Concat matrices        
Cube = [Cube Matrix];

% Give cube size of 1m x 1m x 1m
Cube(1:3,:) = Cube(1:3,:) .* 1000;

