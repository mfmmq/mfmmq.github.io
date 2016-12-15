% This script runs the estimation of the KMatrix
%
% 1. Constructs a camera model loosely based on an iPhone6
% 2. Constructs a calibration grid 1m on a side with 10mm grid spacing.
% 3. Positions the grid somewhere in space.
%
% Performs the following actions on each image, repeating an image if the
% homography estimation failed.
% 4. Places the camera somewhere in space to generate a full image of tile
% square corner locations.
% 5. Generates the noisy image of the grid.
% 6. Add in some outliers.
% 7. Perform a Ransac estimate of the homography
% 
% Once the homographies have been estimated
% 8. Build the regressor for estimating the K-matrix
% 9. Carry out the Cholesky factorization and invert.

% The number of calibration images to use
nImages = 6;