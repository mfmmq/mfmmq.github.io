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

% 1. Construct the Camera model
[KMatrix, CameraHeight, CameraWidth] = buildCamera();

% 2. Construct a 1m by 1m grid with 10mm tiles in the grid frame
% The grid is a set of 4-element vectors [x y 0 1]'
GridWidth = 1000;
GridIncrement = 10;
CalibrationGrid = buildGrid(GridIncrement, GridWidth);

% 3. Choose somewhere in space for the grid
% T_ow is the 4x4 transformation matrix from grid to world
T_ow = positionGrid();

% Define the scaling to use
if CameraHeight > CameraWidth 
    CameraScale = 2.0 / CameraHeight;
else
    CameraScale = 2.0 / CameraWidth;
end
GridScale = 2.0 / GridWidth;

% Generate the calibration images and the homographies
% Store homographies and consensus sets in matlab cell array called
% HomogData
HomogData = cell(nImages,2);
for CalImage = 1:nImages
    % Keep looking for homographies until non-zero result
    % Estimating is a toggle
    Estimating = 1;
    while Estimating == 1
        % The default is 'Success' i.e. Estimating == 0
        Estimating = 0;
        
        % 4. Choose a quasi random location for the camera that fills the
        % image
        
        % T_cw is the 4x4 transformation matrix from camera to world
        T_cw = fillImage(T_ow,KMatrix,GridWidth,CameraHeight,CameraWidth);
        
        
        % 5. Now fill camera with noisy image of the grid and generate the
        % point correspondences
        % Correspond is a set of pairs of vectors of the form 
        % [[u v]' [x y]'] for each grid corner that lies inside the image
        Correspond = buildNoisyCorrespondence(T_ow, T_cw, ...
            CalibrationGrid, KMatrix, CameraHeight, CameraWidth);
        
        
        % 6. Add in some outliers by replacing [u v]' with a point
        % somewhere else in the image
        % Define the outlier probability
        pOutlier = 0.05;
        for j = 1:length(Correspond)
            r = rand;
            if r < pOutlier 
                Correspond(1,j) = rand * (CameraWidth-1);
                Correspond(2,j) = rand * (CameraHeight-1);
            end
        end
        
        % Now scale grid and camera to [-1,1] to imrpove the conditioning
        % of the Homography estimation
        Correspond(1:2,:) = Correspond(1:2,:)*CameraScale - 1.0;
        Correspond(3:4,:) = Correspond(3:4,:)*GridScale;
        
        
        % 7. Perform the RANSAC estimation and output the result for
        % inspection
        % If RANSAC fails return a zero Homography
        
        MaxError = 3.0; % Maximum error allowed before rejecting a pt (px)
        % Error from variance of 0.5 pixels so sigma is sqrt(.5), 3 pixels
        % in the norm is 3 sigma because there are two errors involved in
        % the norm (u and v)
        % In pixels so needs to be scaled before RANSAC
                
        RansacRuns = 500; % Runs when creating the consensus set
        [Homog, BestConsensus] = ...
            ransacHomog(Correspond,MaxError*CameraScale,RansacRuns);
        
        if Homog(3,3) > 0
            % This image worked, record homography and consensus set
            HomogData{CalImage,1} = Homog;
            HomogData{CalImage,2} = Correspond;
            HomogData{CalImage,3} = BestConsensus;
        else
            % Estimate failed, try again
            Estimating = 1;
        end
        
    end % End of the Estimating loop
end % End of the nImages loop

% 8. Build the regressor for estimating the Cholesky product
Regressor = zeros(2*nImages,6);
for CalImage = 1:nImages
    r1 = 2*CalImage - 1;
    r2 = 2*CalImage;
    Regressor(r1:r2,:) = KMatrixRowPair(HomogData{CalImage,1});
end

% Find the kernel
[U,D,V] = svd(Regressor,'econ');
D = diag(D);
[M,I] = min(D);
% K is the estimate of the kernel
K = V(:,I);

% The matrix to be constructed needs to be positive definite
% It is necessary that K(1) be positive
if K(1)<0
    K = -K;
end


% Construct the matrix Phi from the kernel
Phi = zeros(3);

Phi(1,1) = K(1);
Phi(1,2) = K(2);
Phi(1,3) = K(3);
Phi(2,2) = K(4);
Phi(2,3) = K(5);
Phi(3,3) = K(6);

% Add in the symmetric components
Phi(2,1) = Phi(1,2);
Phi(3,1) = Phi(1,3);
Phi(3,2) = Phi(2,3);
Phi
% Check if matrix is positive definite
e = eig(Phi);
e
for j = 1:3
    if e(j) <= 0
        error('The Cholesky product is not positive definite')
    end
end


% 9. Carry out the Cholesky factorization
KMatEstimated = chol(Phi);

% Invert the factor 
KMatEstimated = KMatEstimated \ eye(3);

% The scaling of the grid has no impact on the scaling of the K-Matrix as
% the vector 't' takes no part in the estimate of Phi. Only the image
% scaling has an impact

% First normalise the KMatrix
% Check bottom right element to make sure it isn't too small
if KMatEstimated(3,3) < eps
    error('Could not normalise estimated KMatrix properly');
end
KMatEstimated = KMatEstimated / KMatEstimated(3,3);

% Add 1.0 to the translation part of the image
KMatEstimated(1,3) = KMatEstimated(1,3) + 1;
KMatEstimated(2,3) = KMatEstimated(2,3) + 1;

% Rescale back to pixels
KMatEstimated(1:2,1:3) = KMatEstimated(1:2,1:3) / CameraScale;
KMatrix
KMatEstimated
        