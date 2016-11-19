% Simulate viewing a 3D object (a cube) to demonstrate the structure built
% up to calibrate a camera

% Construct a camera
[KMatrix, CameraHeight, CameraWidth] = buildCamera;
    
% Contruct an object in its own frame
Cube = buildCube;

% Position the object in space
T_ow = positionObject;

% Position the camera so that it is likely that the object can be seen
T_cw = positionCamera(T_ow);

% Look at what we have 
viewCamera(Cube, T_ow, KMatrix, CameraHeight, CameraWidth, T_cw);