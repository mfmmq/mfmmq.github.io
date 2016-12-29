function [ KMatJacob, FrameJacob ] = singleImageJacobian( ...
    OrigKMatrix, OrigRotAxis, OrigTranslation, Correspond, BestConsensus)
%singleImageJacobian computes the Jacobian
%The Jacobian is calculated for the group of 6 parameters for the image,
%the 3 rotations and translations per image
%
% Jacobian is calculated by using the forward difference approximation by
% changing each variable by a small amount, computing the new position
% error, and dividing by the change in parameter
% 
% KMatJacob is a 5x5 matrix of the change in error over the change in
% parameter
% 
% 



dp = 0.0001;                    % Small amount to scale each parameter by
KMatrix = OrigKMatrix;          % Initalise KMatrix
RotAxis = OrigRotAxis;          % Initialise angle-axis representation
Translation = OrigTranslation;  % Initialise translation
s = size(Correspond);           % For preallocating matrices
KMatJacob = zeros(5,s(2));      % Initialise KMatJacob
FrameJacob = zeros(6,s(2));     % Initialise FrameJacob



% 1. First calculate the initial error vector
ErrorVector = computeImageErrors(KMatrix, RotAxis, Translation, ...
    Correspond, BestConsensus);




% 2. Calculate KMatJacob

% Perturb each element of the KMatrix and calculate the change in the error
% vector. Reset and perturb the next element

KMatIndex = [1 2 3 5 6]; % Locations of elements to perturb
for i = 1:5
    KMatrix(KMatIndex(i)) = KMatrix(KMatIndex(i)) * (1+dp);
    % Find new image error from perturbation
    NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation, ...
        Correspond, BestConsensus);
    
    % Find the partial derivative approximation and add to KMatJacob by
    % calculating the change in error vector and dividing by the change
    size(NewErrorVector);
   
    KMatJacob(i,:) = (NewErrorVector - ErrorVector)/...
        (dp*KMatrix(KMatIndex(i)));
    
    % Reset the perturbed value
     KMatrix(KMatIndex(i)) =  OrigKMatrix(KMatIndex(i));
    
end





% 3. Calculate FrameJacobian by perturbing the angle, axis of rotation, and
% the three translation coordinates

% Unenconde the angle axis representation to find the original angle
% and axis
OrigAngle = norm(OrigRotAxis); 
OrigAxis = OrigRotAxis/OrigAngle; % Divide by angle to get unit axis vector


% Calculate the jacobian component for angle perturbation
%{
RotAxis = OrigRotAxis*(1+dp); % Perturb the angle by scalar dp
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(1,:) = (NewErrorVector - ErrorVector)/dp/Angle;
%}

% Add the axis perturbation jacobian component
Axis = [1+dp;1;1].*OrigAxis;
RotAxis = OrigAngle*Axis/norm(Axis); % Create angle-axis representation
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(1,:) = (NewErrorVector - ErrorVector)/dp/Axis(1);

Axis = [1;1+dp;1].*OrigAxis;
RotAxis = OrigAngle*Axis/norm(Axis); % Create angle-axis representation
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(2,:) = (NewErrorVector - ErrorVector)/dp/Axis(2);

Axis = [1;1;1+dp].*OrigAxis;
RotAxis = OrigAngle*Axis/norm(Axis); % Create angle-axis representation
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(3,:) = (NewErrorVector - ErrorVector)/dp/Axis(3);

% Now create the three jacobian components from the translation coordinates
% For x-coordinate
Translation(1) = OrigTranslation(1)*(1+dp);
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(4,:) = (NewErrorVector - ErrorVector)/dp/Translation(1);
Translation = OrigTranslation;
% For y-coordinate
Translation(2) = OrigTranslation(2)*(1+dp);
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(5,:) = (NewErrorVector - ErrorVector)/dp/Translation(2);
Translation = OrigTranslation;
% For z-coordinate
Translation(3) = OrigTranslation(3)*(1+dp);
NewErrorVector = computeImageErrors(KMatrix, RotAxis, Translation,...
    Correspond, BestConsensus); 
FrameJacob(6,:) = (NewErrorVector - ErrorVector)/dp/Translation(3);
Translation = OrigTranslation;



% Transpose matrices for output
KMatJacob = KMatJacob';
FrameJacob = FrameJacob';
size(FrameJacob)

%{
Change each element of kmatrix, angle axis and translation by some small amount
Use compute image errors function to find the new error vector
Subtract from the old error vector and divide by the change
Put the 5 vectors from kmatrix.elements in Kmatjacob
And the 6 vectors from angleaxis and translation in FrameJacobian
%}
