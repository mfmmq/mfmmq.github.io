function [ RegressorRows ] = KMatrixRowPair(Homog)
%KMatrixRowPair
% Function builds regressor for estimating Cholesky product
% Homog is 3x3 homography matrix with 

% Check Homog is right size
if size(Homog) ~= [3,3]
    error('Homog input to KMatrixRowPair is incorrect size');
end
% Check Homog is scaled properly ie. bottom corner is 1, not all zeros
if Homog(3,3) ~= 1
    error('Homog not scaled properly, value at bottom right corner is %s'...
        , Homog(3,3));
end

% Pull values from Homog matrix and reassign
h11 = Homog(1,1);
h12 = Homog(1,2);
h13 = Homog(1,3);
h21 = Homog(2,1);
h22 = Homog(2,2);
h23 = Homog(2,3);
h31 = Homog(3,1);
h32 = Homog(3,2);
h33 = Homog(3,3);


% Build 2x6 regressor rows of the form 
% [ h11^2-h12^2  2(h11h21-h12h22) 2(h11h31-h12h32) h21^2-h22^2
% 2(h21h31-h22h32) h31^2-h32^2;
% h11h12 h11h22+h21h12 h11h32+h31h12 h21h22 h21h32+h31h22 h31h32]

RegressorRows(1,1) = h11^2 - h12^2;
RegressorRows(1,2) = 2*(h11*h21 - h12*h22);
RegressorRows(1,3) = 2*(h11*h31-h12*h32);
RegressorRows(1,4) = h21^2 - h22^2;
RegressorRows(1,5) = 2*(h21*h31-h22*h32);
RegressorRows(1,6) = h31^2 - h32^2;

RegressorRows(2,1) = h11*h12;
RegressorRows(2,2) = h11*h22+h21*h12;
RegressorRows(2,3) = h11*h32 + h31*h12;
RegressorRows(2,4) = h21*h22;
RegressorRows(2,5) = h21*h32+h31*h22;
RegressorRows(2,6) = h31*h32;


