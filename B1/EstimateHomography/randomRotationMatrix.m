function [ R ] = randomRotationMatrix()
%randomRotationMatrix
% Generates a random rotation matrix by starting with two random vectors
% and then normalising, projecting out components and then generating the
% final column by using the cross-product

% Make sure random matrix is larger than eps
xnorm = 0;
while xnorm < eps
    x = rand(3,1);
    xnorm = norm(x);
end
% Normalising vector
xhat = x/xnorm;

ynorm = 0;
while ynorm < eps
    y = rand(3,1);
    % Projecting out xhat by dot product and removing from y
    y = y - (y'*xhat)*xhat;
    ynorm = norm(y);
end
% Normalising y vector
yhat = y/ynorm;

% Finding third vector by taking cross product of x and y
zhat = cross(xhat,yhat);

% Construct the rotation matrix for return 
R = [xhat yhat zhat];

end