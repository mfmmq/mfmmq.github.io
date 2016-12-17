function [ T_cw ] = fillImage(T_ow, KMatrix,GridWidth, CameraHeight, ...
    CameraWidth)
%fillImage Takes in a Calibration grid definition and positions the camera
%so that the image of the grid fills the camera image.
%
% T_ow is the Calibration Grid frame
% KMatrix is the intrinsic camera model
% Gridwidth is the length of a size of the whole grid in mm
% CameraHeight and CameraWidth are the sizes of the image in pixels

% Define the Left Top, Left Bottom, Right Top, and Right Bottom of the grid

GridCorners = [-GridWidth/2 -GridWidth/2 GridWidth/2 GridWidth/2; ...
    GridWidth/2 -GridWidth/2 GridWidth/2  -GridWidth/2;
    0 0 0 0;
    1 1 1 1];

GridCorners1 = [0 0 GridWidth GridWidth; ...
    GridWidth 0 GridWidth 0;
    0 0 0 0;
    1 1 1 1 ];

% Compute the positions of the GridCorners in the world 
GridCorners = T_ow * GridCorners;

% We have a 1m by 1m grid somewhere in space and we need to view the grid
% from the camera. We view from a random location based on a 'distance'
% called CameraBaseDistance. This is an initial estimate
CameraBaseDistance = 2000;

% Keep reducing the distance until all 4 corners are outside the image
% InsideImage is a flag that records the failure, triggering a move towards
% the object and a retry
InsideImage = 1;
while InsideImage == 1
    
    InsideImage = 0;
    
    % PostionCamera makes camera 'almost' point at the object but
    % introduces randomness so we hav ea range of angles between the grid's
    % normal and the camera z-axis
    T_cw = positionCamera(T_ow,CameraBaseDistance);
    
    % Compute where corners are in the unit camera frame
    UnitCorners = (T_cw \ GridCorners);
    % Project into the unit camera
    UnitCorners = UnitCorners(1:3, :);
    % And convert to camera pixels and label them as homogeous
    HomogeneousCorners = KMatrix * UnitCorners;
    % Dehomogenise the image of the corners of the grid
    Corners = zeros(2,4);
    for j = 1:4
        Corners(1:2, j) = ...
            HomogeneousCorners(1:2,j) / HomogeneousCorners(3,j);
        if Corners(1,j) > 0 && Corners(1,j) < CameraWidth - 1
            InsideImage = 1;
            % The u component is not outside the image, keep searching
        end
        if Corners(2,j) > 0 && Corners(2,j) < CameraHeight - 1
            InsideImage = 1;
        end
        if isnan(Corners(1,j)) || isnan(Corners(2,j))
            InsideImage = 1;
        end
        if isinf(abs(Corners(1,j))) || isinf(abs(Corners(2,j)))
            InsideImage = 1;
        end
    end
    
    % Move the camera nearer to the object if any of the corners are inside
    % the image, loop again
    if InsideImage == 1
        CameraBaseDistance = CameraBaseDistance * 0.9;
    end
    
end
CameraBaseDistance
%{
Corners
UnitCorners
HomogeneousCorners
figure(2)
clf
plot(Corners(1,:),Corners(2,:),'r+');
hold on;
plot(.5*CameraWidth,.5*CameraHeight,'k*');
axis ij
%}

end