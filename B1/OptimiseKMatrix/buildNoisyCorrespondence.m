function [ Correspond ] = buildNoisyCorrespondence(T_ow,T_cw, ...
    CalibrationGrid,KMatrix,CameraHeight,CameraWidth)
%buildNoisyCorrespondence
% Function takes sets of 4-vectors in world coordinates and computes where
% they end up in the camera image. The representation is chosen for
% constructing grid-point to image-point correspondences and the output is
% a list of 4-vectors that are not homogeneous points, but pairs of points
% in the form [[u,v]';[xy]']. Normally distributed noise is added before
% the correspondences are returned to the calling function
%
% T_ow is the transformation of points in object coordinates into points 
% in world coordinates 4x4
% T_cw is the 4x4 camera frame in world coordinates
% CalibrationGrid is a list of points that correspond to the corners in the
% grid
% KMatrix is K-Matrix of the camera in pixels
% CameraHeight is the number of vertical pixels
% CameraWidth is the number of horizontal pixels



% Check sizes 

s = size(T_ow);
if s(1) ~= 4 || s(2) ~= 4
    error('T_ow has an invalid size')
end

s = size(KMatrix);
if s(1) ~= 3 || s(2) ~= 3
    error('KMatrix has an invalid size')
end

s = size(T_cw);
if s(1) ~= 4 || s(2) ~= 4
    error('T_cw has an invalid size')
end


% Transform the object into world coordinates
CorrespondencePass = T_ow * CalibrationGrid;
% Pass as point pairs to correspond
Correspond(3:4,:) = CalibrationGrid(1:2,:);

% Transform the object into camera coordinates using the backslash operator
CorrespondencePass = T_cw \ CorrespondencePass;

%
% Project out the 4th coordinate and multiply by the KMatrix
CorrespondencePass = KMatrix * CorrespondencePass(1:3,:);

% Now have a set of homogeneous points representing 3D points
% Need to normalise points to get 2D points
s = size(CorrespondencePass);
for j = 1:s(2) 
    CorrespondencePass(1:2,j) = CorrespondencePass(1:2,j) / CorrespondencePass(3,j);
end

% Throw away normalising components
CorrespondencePass = CorrespondencePass(1:2,:);


% Generate noise with variation of 0.5 pixels and matlab function randn 
CorrespondencePass = CorrespondencePass + 0.5 * randn(size(CorrespondencePass));

Correspond(1:2,:) = CorrespondencePass;


% Throw away points outside the camera frame
%

s = size(Correspond);
i = 1;
while i <= s(2)
   % Camera width
   if Correspond(1,i) < 0 || Correspond(1,i) > CameraWidth
       Correspond(:,i) = [];
       i = i-1;
       s(2) = s(2)-1;
   elseif Correspond(2,i) < 0 || Correspond(2,i) > CameraHeight
       Correspond(:,i) = [];
       i = i-1;
       s(2) = s(2)-1;
   end
   i = i+1;
end


