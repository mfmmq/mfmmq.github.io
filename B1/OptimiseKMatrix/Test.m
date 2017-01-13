% This script is a harness assess the speed and accuracy of the
% OptimiseKMatrix code

% Things to test for:
% RANSAC Runs
% mu/nu scaling for Levenberg-Marquadt algorithm in optimiseKMatrix
% Stopping condition


Num = 10;            % Number of function runs to average out values
Ransac = 9*10;        % Ransac runs to start at


arg_in(1) = Ransac;
KM = zeros(3);
KME = KM;
OKM = KM;
% Function is random, so take averages to account for differences
% Run a loop to take averages
time = 0;
for nLoop = 1:Num
    profile on
    % Run the function

    [KMatrix, KMatEstimated, ~] = testOptimiseKMatrix(arg_in);

    KM = KM + KMatrix;
    KME = KME + KMatEstimated;
    %OKM = OKM + OptKMatrix;
    

    
    profile off
    %RANSAC_Info = fprintf('ransac_%i_%i',arg_in(1),nLoop);
    p = profile('info');
    s = size(p.FunctionTable);
    for i = 1:s(1)
        if strcmp(p.FunctionTable(i).FunctionName,'ransacHomog')
            time = time + p.FunctionTable(i).TotalTime;
        end
    end
    %profsave(p,RANSAC_Info);
end

% Average the matrices for the amount of loops
KM = KM ./ Num;
KME = KME ./ Num;
%OKM = OKM ./ Num;

% Average the time it took
time = time/Num;

% Add up errors between the K-matrix and estimated K-matrix by taking
% squares of the differences
ErrorMatrix = KME - KM;
Cost = 0; % Initialise error

% Define the cost as Error over time
CostMatrix = ErrorMatrix./time;


% Find a scalar that describes the cost
for i = 1:9
    Cost = Cost + ErrorMatrix(i)^2;
end


ransac.ErrorMatrix{Ransac/10} = ErrorMatrix;
ransac.Time{Ransac/10} = time;
ransac.CostMatrix{Ransac/10} = CostMatrix;
ransac.Cost{Ransac/10} = Cost;
