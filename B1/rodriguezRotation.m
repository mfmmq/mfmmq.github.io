function [ R ] = rodriguezRotation ( axis , angle)
%rodriguezRotation
% Generates a random matrix given the axis of rotation and angle of
% rotation in randians (not an angle-axis representation, where angle is
% encoded as the norm of the axis)
% axis must be a 