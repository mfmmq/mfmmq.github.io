% Script for estimation task 1
%
% The script performs the following actions:
% 1. Constructs a camera model loosely based on an iPhone 6
% 2. Constructs a calibration grid 1m on a side with 10mm grid spacing
% 3. Positions the grid somehwere in space
% 4. Places the camera in a 'random' location so that the grid fills the
% camera image. check this location to see if the grid outline is outside
% the image; if not, move the camera nearer to the grid. This is NOT a
% smart way of positioning things, but it models the likely behaviour of a
% human user. 
% 5. Compute the image of the grid and constructs a set of grid - image
% correspondences and add 'noise' to the image
% 6. Convert some of the correspondences to outliers
% 7. Carry out a RANSAC estimation of the homography

% 1. Construct the camera model
% Using code from previous project
[KMatrix, CameraHeight, CameraWidth, arg_in] = buildCamera;

% 2. Construct a 1m by 1m grid with 10mm tiles in the grid frame
% The grid is a set of 4 element vectors [x y 0 1]'
GridWidth = 1000;
GridIncrement = 10;
CalibrationGrid = buildGrid(GridIncrement, GridWidth);

% 3. Choose somewhere in space for the grid
% T_ow is the 4x4 transformation matrix from grid to world
T_ow = positionGrid();

% 4. Place camera in random location so that grid fills the camera images
% T_cw is the 4x4 tranformation matrix from camera to world
T_cw = fillImage(T_ow,KMatrix,GridWidth,CameraHeight,CameraWidth);

% 5. Fill camera with noisy image of grid and generate the point
% correspondences 
% Correspond is a set of pairs of vectors of the form [[u v]' [x y ]']
% for each grid corner that lies inside the image
Correspond = buildNoisyCorrespondence(T_ow,T_cw,CalibrationGrid, ...
    KMatrix,CameraHeight,CameraWidth);

% 6. Add in outliers by replacing [u v]' with a point somewhere in the
% image
% Define the outlier probability
pOutlier = 0.05;
for j=1:length(Correspond)
    if rand < pOutlier
        % Putting outlier anywhere in the image
        Correspond(1,j) = rand * (CameraWidth - 1);
        Correspond(2,j) = rand * (CameraHeight - 1);
    end
end


figure(1)
plot(Correspond(1,:),Correspond(2,:),'.')
title('The noisy measurements of the tile corners')
axis ij
xlim([0 CameraWidth]);
ylim([0 CameraHeight]);

% 7. Perform the RANSAC estimation - output the result for inspection. If
% test fails, it returns a zero Homography
MaxError = 3;       % The maximum error allowed before rejecting a point
RansacRuns = 50;    % The number of runs when reating the consensus set
[Homog, BestConsensus] = ransacHomog(Correspond, MaxError, RansacRuns);
Homog
%NRuns = RansacRuns;



% Test result by constructing the homography for the system from its
% definition
% First find object grame in camera frame
T_oc = T_cw \ T_ow;
% Construct the non-normalised homography from K*[x y t]
OrigHomog = KMatrix * [T_oc(1:3,1) T_oc(1:3,2) T_oc(1:3,4)];
% And normalise so that (3,3) is 1.0 - output for inspection
OrigHomog = OrigHomog / OrigHomog(3,3)




