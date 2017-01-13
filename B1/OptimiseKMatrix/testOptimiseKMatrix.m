function [KMatrix,KMatEstimated,OptKMatrix] = testOptimiseKMatrix(arg_in)
%testOptimiseKMatrix
% This script is a test handle of the original RunOptimiseKMatrix. It is
% meant for testing the speed and accuracy of the function by making it
% easier to change values in the original script
% var_in is a temporary catch-all for all input variables. It will be
% changed once important variables are set


RansacRuns = arg_in(1); % Number of runs when creating consensus set


% Notes for the original RunOptimiseKMatrix script
% It performs a full estimation and optimisation of a camera K-Matrix. 
%
% 1. Construct a camera model loosely based on an iPhone6
% 2. Construct a calibration grid 1m on a side iwth 10mm grid spacing
% 3. Position the grid somewhere in sapce
%
% Perform the following actions on each image, repeating an image if the
% homogrpahy estimation failed. 
% 
% 4. Place the camera somewhere in space to generate a full image of the
% tile square corner locations
% 5. Generate the noisy image of the grid
% 6. Add in some outliers
% 7. Perform a Ransac estimate of the homography
%
% Once the homographies have been estimated
% 8. Build the regressor for estimating the K-matrix
% 9. Carry out the Cholesky factorization and invert. This generates an
% initial model of the K-Matrix

% The number of calibration images to use
nImages = 6;

% 1. Construct the camera model
[KMatrix, CameraHeight, CameraWidth] = buildCamera();

% 2. Construct a 1m by 1m grid with 10mm tiles in the grid frame
% The grid is a set of 4-element vectors [x y 0 1]'
GridWidth = 1000;
GridIncrement = 10;
CalibrationGrid = buildGrid(GridIncrement, GridWidth);

% 3. Choose somewhere in space for the grid
% T_ow is the 4x4 transformation matrix from grid to world
T_ow = positionGrid;

% Define the scaling to use
if CameraHeight > CameraWidth 
    CameraScale = 2.0/CameraHeight;
else
    CameraScale = 2.0/CameraWidth;
end
GridScale = 2.0/GridWidth;

% Generate the calibration images and the homographies
% Store homographies and consensus sets in a matlab cell array HomogData
HomogData = cell(nImages,2);
% Define the numbers to access the DataCel
NHOMOGRPAHY = 1;
NCORRESPOND = 2;
NCONSENSUS = 3;

for CalImage = 1:nImages
    
    % Keep looking for homographies until non-zero result
    % Estimating is a toggle
    Estimating = 1;
    
    while Estimating == 1 
        % Default is success when estimating is 0
        Estimating = 0;
        
        % 4. Choose a random location for the camera that fills the image
        % T_cw is the 4x4 transformation matrix from camera to world
        T_cw = fillImage(T_ow, KMatrix, GridWidth, ...
            CameraHeight, CameraWidth);
        
        % 5. Now fill camera with a noisy image of the grid and generate
        % the point correspondences
        % Correspond is a set of pairs of vectors of the form [[u v]' [x
        % y]'] for each grid corner that lies inside the image
        Correspond = buildNoisyCorrespondence(T_ow,T_cw, ...
            CalibrationGrid, KMatrix, CameraHeight,CameraWidth);
        
        % 6. Add in some outliers by replacing [u v]' with a point
        % somewhere else in teh image
        pOutlier = 0.05; % Defining outlier probability
        for j = 1:length(Correspond)
            r = rand;
            if r < pOutlier
                Correspond(1,j) = rand*(CameraWidth-1);
                Correspond(2,j) = rand*(CameraHeight-1);
            end
        end
        
        
        
        % Now scale grid and camera to [-1,1] to improve the conditioning
        % of the Homography estimation
        Correspond(1:2,:) = Correspond(1:2,:)*CameraScale - 1.0;
        Correspond(3:4,:) = Correspond(3:4,:)*GridScale;
        
        % 7. Perform the RANSAC estimation
        % If the Ransac fails it returns a zero homography
        
        % The maximum error allowed before rejecting a point
        MaxError = 3.0;
        % Using a variance of 0.5 pixels, so sigma is sqrt(.5)
        % 3 pixels in the norm is 3 sigma because there are two errors
        % involved in the norm (u and v)
        %
        % Note: the above is in pixels, needs to be scaled before RANSAC
        
        [Homog, BestConsensus] = ...
            ransacHomog(Correspond,MaxError*CameraScale,RansacRuns);
        
        if Homog(3,3) > 0
            % This image worked, record homography and consensus set
            HomogData{CalImage,NHOMOGRPAHY} = Homog;
            HomogData{CalImage,NCORRESPOND} = Correspond;
            HomogData{CalImage,NCONSENSUS} = BestConsensus;

        else
            % Estimate failed, try again
            Estimating = 1;
        end
        
    end % End of Estimating loop
end % End of nImages loop

% 8. Build the regressor for estimating the Cholesky product
Regressor = zeros(2*nImages,6);
for CalImage = 1:nImages
    r1 = 2*CalImage-1;
    r2 = 2*CalImage;
    Regressor(r1:r2,:) = kMatrixRowPair(HomogData{CalImage,1});
end

% Find the kernel
[U,D,V] = svd(Regressor,'econ');
D = diag(D);
[M,I] = min(D);
% K is the estimate of the kernel
K = V(:,I);

% The matrix to be constructed needs to be positive deifnite
% It is necessary that K(1) be positive 
if K(1) < 0
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

% Add in symmetric components
Phi(2,1) = Phi(1,2);
Phi(3,1) = Phi(1,3);
Phi(3,2) = Phi(2,3);

% Check if matrix is positive definite
e = eig(Phi); 
for j = 1:3
    if e(j) <= 0
        error('The Cholesky product is not positive definite')
    end
end


% 9. Carry out the Cholesky factorization
KMatEstimated = chol(Phi);

% Invert the factor
KMatEstimated = KMatEstimated \ eye(3);

% The scaling of the grid has no impact on the scaling of the K-matrix as
% the vector 't takes no part in the estimate of Phi. Only the image
% scaling has an impact

% First normalise the K-matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CHcke for eps here?
if KMatEstimated(3,3) < eps
    error('Could not normalise the estimated K-matrix');
end
KMatEstimated = KMatEstimated / KMatEstimated(3,3);

% Optimise the K-matrix
OptKMatrix = optimiseKMatrix(KMatEstimated,HomogData);
% Add 1.0 to the translation part of the image
KMatEstimated(1,3) = KMatEstimated(1,3) + 1;
KMatEstimated(2,3) = KMatEstimated(2,3) + 1;

% Rescale back to pixels
KMatEstimated(1:2,1:3) = KMatEstimated(1:2,1:3) / CameraScale;
OptKMatrix(1,3) = OptKMatrix(1,3)+1;
OptKMatrix(2,3) = OptKMatrix(2,3)+1;
OptKMatrix(1:2,1:3) = OptKMatrix(1:2,1:3)/CameraScale;

end
    
