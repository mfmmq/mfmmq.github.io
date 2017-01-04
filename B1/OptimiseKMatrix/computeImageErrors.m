function [ErrorVector] = computeImageErrors(KMatrix, RotAxis, Translation, ...
    Correspond, BestConsensus)
%computeImageErrors calculates the error vector e using the current set of
%
% KMatrix is the camera model
% RotAxis is the axis angle representation
% Translation is the location vector in mm
% Correspond is the set of point pairs
% BestConsensus is the best match for the data
%
% 1. Build transformation matrix from axis Angle and Translation T_oc
% 2. Multiply original points in Correspond to calculate predicted image
% positions


% Some input checks
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

% First unencode the shifted angle-axis representation of the rotation
% The angle-axis representation is a scalar angle multiplied by the
% directional unit vector

Angle = norm(RotAxis)-4*pi; % Find the magnitude/angle or the angle-axis rep.
Axis = RotAxis/Angle; % Divide by angle to get unit axis vector

% Use rodriguesRotation to build 3x3 rotation matrix from Angle
Rotation = rodriguesRotation(Axis, Angle);

% Next build the transformation matrix using the Rotation and Translation
Transformation = [Rotation Translation];
Transformation = [Transformation; 0 0 0 1]; % Add the bottom row




% Build two sets of points to calculate the image error vector from points
% found in the best consensus
% OriginalPoints is a 4xn matrix of original grid points to be transformed
% into predicted points with Transformation
% ActualPoints is a 2xn matrix of points from the camera in the Consensus 


s = size(BestConsensus);
OriginalPoints = zeros(size(Correspond));
ActualPoints = zeros(2,s(2));
c = 1;
% Go through Correspond points and see if it matches with Consensus
% If points match, set OriginalPoints. else, leave value at 0
for i = 1:s(2)
    %if BestConsensus(i) ~= 0
        % if a consensus point, add it to points for comparison to actual
        % points
        OriginalPoints(:,c) = [ ...
            Correspond(3,BestConsensus(i))
            Correspond(4,BestConsensus(i))
            0
            1
            ];
        ActualPoints(:,c) = [ ...
            Correspond(1,BestConsensus(i))
            Correspond(2,BestConsensus(i))
            ];
        c = c+1;
    %end
end

% Cut off extra zeros
s(2) = c-1;
OriginalPoints = OriginalPoints(:,1:s(2));
ActualPoints = ActualPoints(:,1:s(2));

% Transform the OriginalPoints from grid coordinates to find their 
% predicted position in 

PredictedPoints = Transformation * OriginalPoints;
PredictedPoints = KMatrix * PredictedPoints(1:3,:);
for i = 1:s(2)
    PredictedPoints(1:2,i) = PredictedPoints(1:2,i)/PredictedPoints(3,i);
end
PredictedPoints = PredictedPoints(1:2,:); % Get rid of normalising


% Calculate error vector 
ErrorVector = zeros(2*s(2),1); % Initialise error vector
% Add all the u components 
for i = 1:s(2)
    ErrorVector(i) = PredictedPoints(1,i)-ActualPoints(1,i);
end
% Add all the v components
for i = 1:s(2)
    ErrorVector(i+s(2)) = PredictedPoints(2,i)-ActualPoints(2,i);
end

