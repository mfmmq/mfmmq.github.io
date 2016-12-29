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
% 1. Build transformation matrix from axis Angle and Translation
% 2. Multiply original points in Correspond to calculate predicted image
% positions


% Some input checks
% Correspond and Consensus should be the same size
if size(Correspond) ~= size(BestConsensus)
    error('Correspond and Consensus wrong size');
end
%~~~~~~~~~~~~~~~~~~~!)#(!)#()!@*$)#@*%(#@*$%(@#*$%_(#@*$_(%!*@_($#*!_%(*


% First unencode the angle-axis representation of the rotation
% The angle-axis representation is a scalar angle multiplied by the
% directional unit vector

Angle = norm(RotAxis); % Find the magnitude/angle or the angle-axis rep.
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

% Go through Correspond points and see if it matches with Consensus
% If points match, set OriginalPoints. else, leave value at 0
for i = 1:s(2)
    if BestConsensus(i) ~= 0
        % if a consensus point, add it to points for comparison to actual
        % points
        OriginalPoints(:,BestConsensus(i)) = [ ...
            Correspond(3,BestConsensus(i))
            Correspond(4,BestConsensus(i))
            0
            1
            ];
        ActualPoints(:,BestConsensus(i)) = [ ...
            Correspond(1,BestConsensus(i))
            Correspond(2,BestConsensus(i))
            ];
    end
end

% Transform the OriginalPoints to find where they 'should be'
PredictedPoints = Transformation * OriginalPoints;
PredictedPoints = PredictedPoints(1:2,:); % Get rid of normalising


% Use predicted points to calculate the error vector
PointErrorVector = ActualPoints - PredictedPoints;
ErrorVector = zeros(1,s(2));
for i = 1:s(2)
    ErrorVector(i) = norm(PointErrorVector(:,i));
end

