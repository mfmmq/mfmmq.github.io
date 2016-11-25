% Simulates viewing a 3D object (a cube) to demonstrate the structures
% built up to calibrate a camera.

% Include rotation matrix path
%path('./RotationMatrix');

% Construct a camera
[KMatrix, CameraHeight, CameraWidth] = buildCamera;

% Construct an object in its own frame
Cube = buildCube;

% Position the obect in space
T_ow = positionObject;

% Position camera so that it is likely that the object can be seen 
T_cw = positionCamera(T_ow);

% Plot
viewCamera(Cube, T_ow, KMatrix, CameraHeight, CameraWidth, T_cw);