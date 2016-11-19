function [ R ] = randomMatrix()
%randomMatrix
% Generates a random matrix by starting with two random vectors and then
% normalising, projecting out components, and then generating the final
% column by using the cross product

% Make sure matrix is larger than eps
xnorm = 0;
while xnorm < eps
    x = rand(3,1);
    xnorm = norm(x);
end

% Generate normalised random x vector
xhat = x/xnorm;

ynorm = 0;
while ynorm < eps
    y = rand(3,1);
    % project out xhat by finding dot product and removing from y
    y = y-(y'*xhat)*xhat;
    ynorm = norm(y);
end

% Generate normalised random y vector
yhat = y/ynorm;

% Generate third vector with cross product
zhat = cross(xhat, yhat);

% Generate rotation matrix
R = [xhat yhat zhat];

end




