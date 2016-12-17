function [ RegressorRows, DataVecRows] = HomogRowPair(CorrespondPoints)
%HomogRowPair
% Takes [[u v]';[x y]'] point pair from Correspond and outputs a matrices
% to solve for homography matrix H where u,v are in camera frame and x,y 
% are in object coordinates
%
% CorrespondPoints is a pair of points in camera and object coordinates
% 
% RegressorRows is 2x8 matrix of the form 
% [ x y 1 0 0 0 -ux -uy ; 0 0 0 x y 1 -vx -vy]
% DataVecRows is 2x1 matrix of the form [u;v]

% Get u,v and x,y values from CorrespondPoints
u = CorrespondPoints(1,1);
v = CorrespondPoints(2,1);
x = CorrespondPoints(3,1);
y = CorrespondPoints(4,1);

% Build RegressorRows with points
RegressorRows = [ x y 1 0 0 0 -u*x -u*y ;
    0 0 0 x y 1 -v*x -v*y];

% Build DataVecRows with points
DataVecRows = [u;v];