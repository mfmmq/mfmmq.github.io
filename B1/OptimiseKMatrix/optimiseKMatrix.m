function [ KMatrix ] = optimiseKMatrix( InitialKMatrix, Data )
%optimiseKMatrix Optimises a K-Matrix using Levenberg-Marquardt
%
% InitialKMAtrix is the 'seed' K-matrix to start the optimisation
% Data is a Matlab cell structure containing homographies, corresponding
% points in the form [[u v]' [x y]'], and the indices of the consensus sets
% generated during the Ransac estimation of the homographies
%
% The algorithm Levenberg-Marquadt
% 1. Compute a shifted angle-axis representation of the rotation matrix.
% Store this with the initial translation vector
% 2. Compute the error vector, e, and total error. Compute the Jacobian, J,
% and J'J. Find the maximum element of J'J, multiply by, say 0.1 and set mu
% to this value
% 3. Solve (J'J + muI)dp = -J'e
% 4. If e'J is small, eq has converged and then terminate
% 5. Compute predicted change in the error as e'Jdp
% 6. Save current parameters and compute the error with new parameters
% 7. Find change in error divided by predicted change in error = gain
% 8. a) if the error went up, recompute mu using equation from notes and
% restore temporary parameters and repeat
% b) If the error went down, accept the new parameters and recompute mu
% using the equation from notes
% 9. Go to step 3
%
% A note of the Jacobian:
% The Jacobian is expensive to compute, thus I keep the same Jacobian until
% it becomes a poor predictor of the change in error, then recompute

% Input checks
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Check KMatrix size, values
if size(InitialKMatrix) ~= [3,3]
    error('KMatrix size is incorrect');
end
if abs(InitialKMatrix(2,1))+abs(InitialKMatrix(3,1))+abs(InitialKMatrix(3,2)) ~= 0
    error('Nonzero in bottom triangular of KMatrix');
end
% Check data size, make sure everything is there
[~,s] = size(Data);
if s ~= 3
    error('Wrong number of data cell types');
end
    



% Initialise the KMatrix
KMatrix = InitialKMatrix;

% Normalise the K-Matrix
KMatrix = KMatrix / KMatrix(3,3);

% Define numbers to acces the Datacell
NHOMOGRAPHY = 1;
NCORRESPOND = 2;
NCONSENSUS = 3;

% Extract the number of images used in the estimation
s = size(Data);
nImages = s(1);

% Preallocate rotation matrix to be constructed
RotMat = zeros(3);

% 1. First need to use initial KMatrix to generate a perspectivity for each
% image and hence the parameterization of the grid's frame in the camera
% frame
FrameParameters = cell(nImages,2);
% Labels for accessing the cell
NANGLE = 1;
NTRANSLATION = 2;

for nHomog = 1:nImages
    % Extract the homography from the data and convert to a perspectivity 
    Perspectivity = KMatrix \ Data{nHomog,NHOMOGRAPHY};
    
    % The perspectivity is scaled so that its bottom right hand value is
    % a unit vector, first column needs to have a norm of 1 (a column of a
    % rotation matrix)
    Perspectivity = Perspectivity / norm(Perspectivity(:,1));
    
    % The translation part of the perspectivity in the camera frame
    Translation = Perspectivity(:,3);
    
    % Start building the rotation matrix
    RotMat(:,1:2) = Perspectivity(:,1:2);
    % Project out the first column from the second
    RotMat(:,2) = RotMat(:,2) - (RotMat(:,1)'*RotMat(:,2))*RotMat(:,1);
    RotMat(:,2) = RotMat(:,2) / norm(RotMat(:,2));
    % And complete with a cross product
    RotMat(:,3) = cross(RotMat(:,1),RotMat(:,2));
    
    % Find the angle of rotation using the trace identity
    CosTheta = (trace(RotMat)-1)/2;
    
    % Make sure answer is valid
    if CosTheta > 1
        CosTheta = 1;
    end
    if CosTheta < -1
        CosTheta = -1;
    end
    
    % Theta is angle of rotation
    Theta = acos(CosTheta);
    
    % Find the axis of rotation by finding the real eigenvector
    [V,D] = eig(RotMat);
    D = diag(D);
    % I will be the real vector
    [~,I] = max(real(D));
    RotAxis = real(V(:,I));
    RotAxis = RotAxis / norm(RotAxis);
    
    % Need to check if the axis is pointing in the 'right' direction
    % consistent with Theta using Rodrigues' formula
    Rplus = rodriguesRotation(RotAxis,Theta);
    Rminus = rodriguesRotation(-RotAxis,Theta);
    
    % Reverse the axis if minus Theta is the best match
    if norm(RotMat-Rminus) < norm(RotMat-Rplus)
        RotAxis = -RotAxis;
    end
    
    % Now shift the angle by 4pi so that we have negative as well as
    % positive angles
    Theta = Theta + 4*pi;
    % Generate a shifted angle-axis representation of the rotation
    RotAxis = RotAxis * Theta;
    
    % Record the initial position of the grid
    FrameParameters{nHomog, NANGLE} = RotAxis;
    FrameParameters{nHomog, NTRANSLATION} = Translation;
    
end

% Now go through the LM steps. There are a variable number of measurements,
% so use another Matlab cell structure to store components
% The components are: 
% 1. Error vector
% 2. KMatrixJacobian
% 3. FrameParametersJacobian
% The above correspond to the following cell entries:
NERRORVECTOR = 1;
NKMATJACOB = 2;
NFRAMEJACOB = 3;

OptComponents = cell(nImages,3);

% Allocate space for J'J
ProblemSize = 5+6*nImages;
JTransposeJ = zeros(ProblemSize);

% Initialise the total error
CurrentError = 0.0;

% Initialise the Gradient as a column vector
Gradient = zeros(ProblemSize,1);

% 2. Compute the initial error vector, Jacobians, and inner product
for j = 1:nImages
    % The error vector for each image
    OptComponents{j,NERRORVECTOR} = computeImageErrors( KMatrix, ...
        FrameParameters{j,NANGLE}, FrameParameters{j,NTRANSLATION}, ...
        Data{j,NCORRESPOND}, Data{j,NCONSENSUS});
    
    % Compute the initial error
    CurrentError = CurrentError + 0.5 * ...
        OptComponents{j,NERRORVECTOR}'*OptComponents{j,NERRORVECTOR};
    
    % The Jacobian for each image
    [OptComponents{j,NKMATJACOB}, OptComponents{j,NFRAMEJACOB}] = ...
        singleImageJacobian( KMatrix, ...
        FrameParameters{j,NANGLE}, FrameParameters{j,NTRANSLATION},...
        Data{j,NCORRESPOND}, Data{j,NCONSENSUS});
    
    
    % The top 5x5 block is the sum of all the inner products of the
    % K-matrix Jacobian blocks
    JTransposeJ(1:5,1:5) = JTransposeJ(1:5,1:5) + ...
        OptComponents{j,NKMATJACOB}'*OptComponents{j,NKMATJACOB};
    
    % The diagonal image block associated with the frame parameters
    StartRow = 6 + (j-1)*6;
    EndRow = StartRow + 5;
    JTransposeJ(StartRow:EndRow, StartRow:EndRow) = ...
        OptComponents{j,NFRAMEJACOB}'*OptComponents{j,NFRAMEJACOB};
    
    JTransposeJ(1:5,StartRow:EndRow) = ...
        OptComponents{j,NKMATJACOB}'*OptComponents{j,NFRAMEJACOB};
    
    % Make matrix symmetrical
    JTransposeJ(StartRow:EndRow,1:5) = JTransposeJ(1:5,StartRow:EndRow)';
    
    
    % Compute the gradient vector
    Gradient(1:5) = Gradient(1:5) + ...
        OptComponents{j,NKMATJACOB}'*OptComponents{j,NERRORVECTOR};
    Gradient(StartRow:EndRow) = OptComponents{j,NFRAMEJACOB}'*...
        OptComponents{j,NERRORVECTOR};

end

% The inital value of mu
mu = max(diag(JTransposeJ)) * 0.1;

% The initial value of th eexponential growth factor nu
% This variable is used to increase mu if the error goes up
nu = 2;

% Now perform the optimisation
Searching = 1; % Toggle for searching, 1 is keep searching
Iterations = 0; % Initialise Iterations counter
MaxIterations = 150;
while Searching == 1
    
    Iterations = Iterations + 1;
    
    if Iterations > MaxIterations
        error('Number of iterations greater than maximum allowed');
    end
    
    % 3. Test for convergence - choose a size for the gradient
    % Weigh the elements of the derivative before computing the norm
    WeightedGradient = Gradient;
    if norm(WeightedGradient)/ProblemSize < 0.01
        break; % Leave the loop
    end
    
    % 4. Solve for the change to parameters
    dp = -(JTransposeJ + mu*eye(ProblemSize)) \ Gradient;
    
    % 5.
    PredictedChange = Gradient' * dp;
    
    
    % 6. Define the new test parameters
    KMatPerturbed = KMatrix;
    FrameParametersPerturbed = FrameParameters;
    
    % Pass on changes to parameters to KMat
    KMatPerturbed(1,1) = KMatPerturbed(1,1) + dp(1);
    KMatPerturbed(1,2) = KMatPerturbed(1,2) + dp(2);
    KMatPerturbed(1,3) = KMatPerturbed(1,3) + dp(3);
    KMatPerturbed(2,2) = KMatPerturbed(2,2) + dp(4);
    KMatPerturbed(2,3) = KMatPerturbed(2,3) + dp(5);
    
    % Initialise the error for the latest test
    NewError = 0;
    
    for j = 1:nImages
        
        % Perturb the image location
        StartRow = 6 + (j-1)*6;
        FrameParametersPerturbed{j,NANGLE} = ...
            FrameParametersPerturbed{j,NANGLE} + dp(StartRow:StartRow+2);
        
        FrameParametersPerturbed{j,NTRANSLATION} = ...
            FrameParametersPerturbed{j,NTRANSLATION} + ...
            dp(StartRow+3:StartRow+5);
        
        % And compute the error vector for this image
        OptComponents{j,NERRORVECTOR} = ...
            computeImageErrors( KMatPerturbed, ...
            FrameParametersPerturbed{j,NANGLE}, ...
            FrameParametersPerturbed{j,NTRANSLATION}, ...
            Data{j,NCORRESPOND}, Data{j,NCONSENSUS});
        
        % Compute the error
        NewError = NewError + 0.5* ...
            OptComponents{j,NERRORVECTOR}'*OptComponents{j,NERRORVECTOR};
        
    end
    
    ChangeInError = NewError - CurrentError;
    
    % 7.
    Gain = ChangeInError / PredictedChange;
    
    % 8. Check the change in error
    if ChangeInError > 0
        % Error has gone up, increase factor mu
        mu = mu*nu;
        nu = nu*2;
    else
        % Error has gone down, update mu
        nu = 2; % Reset to default start value of nu
        mu = mu * max([1/3,(1-(2*Gain-1)^3)]);
        
        % Update the parameters
        KMatrix = KMatPerturbed;
        FrameParameters = FrameParametersPerturbed;
        
        % Update the error
        CurrentError = NewError;
        
        % The Jacobian is expensive to compute, therefore only recompute if
        % the gain is low, i.e. the Jacobian is not accurate
        if Gain < 1/3 
            % The gain is poor - recompute the Jacobian and the Gradient 
            JTransposeJ = zeros(ProblemSize);
            for j = 1:nImages
                % The Jacobian
                [OptComponents{j,NKMATJACOB},...
                    OptComponents{j,NFRAMEJACOB}] = ...
                    singleImageJacobian(KMatrix, ...
                    FrameParameters{j,NANGLE}, ...
                    FrameParameters{j,NANGLE}, ...
                    Data{j,NCORRESPOND}, Data{j,NCONSENSUS});
                
                % The top 5x5 block is the sum of all the inner products of
                % the K-matrix Jacobian blocks
                JTransposeJ(1:5,1:5) = JTransposeJ(1:5,1:5) + ...
                    OptComponents{j,NKMATJACOB}' * ...
                    OptComponents{j,NKMATJACOB};
                
                % The diagnoal image block associated with the frame
                % parameters
                StartRow = 6 + (j-1)*6;
                EndRow = StartRow + 5;
                JTransposeJ(StartRow:EndRow,StartRow:EndRow) = ...
                    OptComponents{j,NFRAMEJACOB}' * ...
                    OptComponents{j,NFRAMEJACOB};
                
                JTransposeJ(1:5,StartRow:EndRow) = ...
                    OptComponents{j,NKMATJACOB}' * ...
                    OptComponents{j,NFRAMEJACOB};
                
                JTransposeJ(StartRow:EndRow,1:5) = ...
                    JTransposeJ(1:5,StartRow:EndRow)';
                
            end
        end
        
        % Compute the new gradient
        Gradient = zeros(ProblemSize,1);
        for j = 1:nImages
            Gradient(1:5) = Gradient(1:5) + ...
                OptComponents{j,NKMATJACOB}'*OptComponents{j,NERRORVECTOR};
            Gradient(StartRow:EndRow) = OptComponents{j,NFRAMEJACOB}'* ...
                OptComponents{j,NERRORVECTOR};
        end
        
    end
    
end


end

                
                
                
        


    
    
