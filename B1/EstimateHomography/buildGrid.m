function [ CalibrationGrid ] = buildGrid(GridIncrement, GridWidth)
%bulidGrid 
% Function constructs an object represented as lists of Points, which are 4
% -vectors. Function returns a list of point that correspond to the corners
% of the grid. 
%
% GridIncrement is the length of the square tile in the Grid in mm
% GridWidth is the size of the grid in mm


% Check inputs
if GridIncrement <= 0
    error('Grid increment is non-positive')
end
if GridWidth <= 0
    error('Grid width is non-positive')
end
if GridWidth < GridIncrement
    error('Grid increment is greater than grid width')
end


% Preallocate grid size
s = GridWidth/GridIncrement;    % Points per side in grid
CalibrationGrid = zeros(4,s);       % Set up 4-vector space



% Anchor grid center at origin (0,0)
% Use GridWidth to build limiting corner points, populate with increments
% from x direction to y direction
% Count current point with c
c = 1;
for i = 0:s
    for j = 0:s
        CalibrationGrid(:,c) = [
            i*GridIncrement
            j*GridIncrement
            0
            1
            ];
        c = c + 1;
    end
end

% Center grid at origin
CalibrationGrid = CalibrationGrid - GridWidth/2;




