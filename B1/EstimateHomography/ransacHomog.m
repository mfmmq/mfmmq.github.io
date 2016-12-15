function [Homog , BestConsensus] = ransacHomog(Correspond, MaxError, NRuns)
%RansacHomog Runs a Ransac estimation of the homography 
% passed as pairs of points in Correspond where Correspond is a set of
% 4-vectors of the form [[u v]';[x y]']
%
% MaxError is the maximum error for a point to be rejected in the consensus
% set
% NRuns is the number of times to run the estimator
%
% Homog is the homography that has been identified. If no homography can be
% computed, then a 3x3 zero matrix is returned
%
% 1. For each of NRuns, choose a set of 4 points
% 2. Use the 4 points to generate a regression matrix and a data vector
% 3. If the regressor is full rank, estimate this homography
% 4. Go through the points and accept those whose error norm is less that
% that set by MaxError
% 5. Record the set of points in the largest consensus set
% 6. If the consensus set is not empty, carry out a least squares estimate
% of the homography using svd

% The number of points available
n = length(Correspond);

% Allocate space for the homogrpahy 
Homog = zeros(3);
% The number of points in the best consensus
nBest = 0;

for Runs = 1:NRuns
    
    RankTest = 1;
    while RankTest == 1
        % RankTest is set to 1 if the 4 points do not give a full rank
        % matrix in the estimator
        RankTest = 0;
        
        % 1. Choose a sample set
        SamplePoints = zeros(1,4);
        
        % First point is a random integer between 1 and n inclusive
        SamplePoints(1) = 1 + fix(n*rand);
        if SamplePoints(1) > n 
            SamplePoints(1) = 1;
        end
        
        % Choose the next three points ensuring there are no repeats
        for j = 2:4 
            % Searching is a toggle that is triggered if there is repeat
            Searching = 1;
            while Searching == 1
                Searching = 0; 
                % Initial sample point
                SamplePoints(j) = 1 + fix(n*rand);
                if SamplePoints(j) > n
                    SamplePoints(j) = n;
                end
                
                % If new point is a repeat, go around again
                for k = 1:j-1
                    if SamplePoints(k) == SamplePoints(j) 
                        Searching = 1;
                    end
                end
            end
        end
        
        
        % 2. Allocate space for the regressor and the data
        Regressor = zeros(8);
        DataVec = zeros(8,1);
        
        % Fill in the regressor and data vector given the samples to take
        for j = 1:4
            % Row indices into the matrix and vector for this data point
            r1 = j*2 -1;
            r2 = j*2;
            [Regressor(r1:r2,:), DataVec(r1:r2)] = ... 
                HomogRowPair(Correspond(:,SamplePoints(j)));
        end
        
        
        % 3. Check if the regressor is full rank
        if rank(Regressor) > 7
            HomogVec = Regressor \ DataVec;
            
            % The homography for this sample 
            Homog(1,1) = HomogVec(1);
            Homog(1,2) = HomogVec(2);
            Homog(1,3) = HomogVec(3);
            Homog(2,1) = HomogVec(4);
            Homog(2,2) = HomogVec(5);
            Homog(2,3) = HomogVec(6);
            Homog(3,1) = HomogVec(7);
            Homog(3,2) = HomogVec(8);
            Homog(3,3) = 1;
            
            % The number of points in the current consensus set and the set
            % itself
            nCurrent = 0;
            CurrentConsensus = zeros(1,n);
            
            % 4. Go through all the points and see how large the error is 
            for j = 1:n 
                HomogenousPoint = Homog * [Correspond(3,j);Correspond(4,j);
                    1];
                HomogenousPoint(1) = HomogenousPoint(1) / ...
                    HomogenousPoint(3);
                HomogenousPoint(2) = HomogenousPoint(2) / ...
                    HomogenousPoint(3);
                
                ThisError = norm(HomogenousPoint(1:2) ... 
                    - [Correspond(1,j);Correspond(2,j)]);
                
                if ThisError < MaxError
                    nCurrent = nCurrent + 1;
                    CurrentConsensus(nCurrent) = j;
                end    
            end
            
            
            % 5. check how well sample did
            if nCurrent > nBest 
                nBest = nCurrent;
                BestConsensus = CurrentConsensus;
            end
            
        else
            RankTest = 1;
        end
    end
end


% 6. BestConsensus now contains the largeset set of consistent estimates
% Use this set to estimate the homography using a robust inverse
if nBest > 0 
    % The number of measurements in the consensus set
    Regressor = zeros(2*nBest,8);
    DataVec = zeros(2*nBest,1);
    
    % Construct the regressor
    for j = 1:nBest
        r1 = j*2 - 1;
        r2 = j*2;
        % HomogRowPair generates 2 rows of the 8 column matrix that
        % multiplies the unknown vector of homography elements to get the
        % vector of measurements
        [Regressor(r1:r2,:),DataVec(r1:r2)] = ...
            HomogRowPair(Correspond(:,BestConsensus(j)));
    end
    
    % Find the singular value decomposition in order to compute the robust
    % pseudo-inverse
    [U,D,V] = svd(Regressor,'econ');
    
    % The condition number of the computation - a measure of how reliable
    % the inversion is
    if D(8,8) < eps 
        Condition = 1.0E16;     % very big number
    else
        Condition = D(1,1) / D(8,8);
    end
    
    if Condition > 1.0E8
        % A very poor condition number, signal that there is no homography
        Homog = zeros(3);
    else
        % Conditioning is good
        % Invert the diagonal matrix of singular values
        for j = 1:8
            D(j,j) = 1.0 / D(j,j);
        end
        
        HomogVec = V*(D*U'*DataVac);
        
        % Construct the homography
        Homog(1,1) = HomogVec(1);
        Homog(1,2) = HomogVec(2);
        Homog(1,3) = HomogVec(3);
        Homog(2,1) = HomogVec(4);
        Homog(2,2) = HomogVec(5);
        Homog(2,3) = HomogVec(6);
        Homog(3,1) = HomogVec(7);
        Homog(3,2) = HomogVec(8);
        Homog(3,3) = 1;

    end
    
else
    % Signal that no homography could be found
    Homog = zeros(3);
    BestConsensus = 0;
end
        
               
            
        
            
            
                
                
                
                
            
            
            
            
            
            
            
            
            
                
                
                
                