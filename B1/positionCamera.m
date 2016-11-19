function [ T_cw ] = positionCamera(T_ow)
%positionCamera
% Generates a random camera frame that has a good chance of the object
% being visible in the camera when the object is a 1m cube
% 
% Input T_ow is the 4x4 object frame in world coordinates
% T_cw is the 4x4 camera frame in world coordinates

% Assign space for the camera frame
T_cw = zeros(4);

% Set the homogeneous multiplier to 1
T_cw(4,4) = 1;

% Extract the object origin
ObjectOrigin = T_ow(1:3,4);

% View the camera from about 10 metres (unrelated to the object frame).
InitialViewVector = 10000 * rand(3,1);

% Define the origin of the camera frame
T_cw(1:3,4) = ObjectOrigin - InitialViewVector;

% Define the camera z-axis as pointing at the object origin
Normz = norm(InitialViewVewctor);
if Normz < eps
    error('Unable to normalise the camera z-axis');
end

% Define a unit vector
InitialCameraz = InitialViewVector / Normz;

% Normalise again
CameraZ = CameraZ / norm(CameraZ);

% Define a random camera x-axis
CameraX = rand(3,1);
% Project out the z-axis
CameraX = CameraX - (CameraZ'*CameraX)*CameraZ;
% normalise the x-axis
Normx = norm(CameraX0;
if Normx < eps
    error('Unable to normalise the camera x-axis');
end
CameraX = CameraX/Normx;

% Define the y-axis
CameraY = cross(CameraZ,CameraX);

% Complete the transformation matrix
T_cw(1:3,1:3) = [CameraX CameraY CameraZ];

end