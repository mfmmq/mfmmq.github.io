% This script is a harness assess the speed and accuracy of the 
% OptimiseKMatrix code 

% Things to test for:
% RANSAC Runs
% mu/nu scaling for Levenberg-Marquadt algorithm in optimiseKMatrix 
% Stopping condition


togglePause = 0;    % Turn pauses on/off, 1 is use pauses
Num = 10;            % Number of function runs to average out values
Ransac = 10;        % Ransac runs to start at
nMax = 10;


% Initialise storage variables, use cell storage array
%{
store_t1 = cell(Num,1);
store_t2 = cell(Num,1);
store_te = cell(Num,1);
store_KMatrix = cell(Num,1);
store_KMatEstimated = cell(Num,1);
store_OptKMatrix = cell(Num,1);
store_K_EM = cell(Num,1);
store_K_OM = cell(Num,1);
store_K_OE = cell(Num,1);
store_E_EM = cell(Num,1);
store_E_OM = cell(Num,1);
store_E_OE = cell(Num,1);
avg_E_EM = cell(nMax,1); 
avg_E_OM = cell(nMax,1); 
avg_E_OE = cell(nMax,1); 
avg_te = cell(nMax,1);


%}

% Find a good number of ransac loops
% Automatically adjust the number of loops
Looping = 1; 
%while Looping == 1
    
    arg_in(1) = Ransac;
    
    % Function is random, so take averages to account for differences 
    % Run a loop to take averages 
    for nLoop = 1:Num

        % Run the function
        t1 = clock;                 % Take the time
        fprintf('Running and timing the function (%i)...\r',nLoop);
        [KMatrix, KMatEstimated, OptKMatrix] = testOptimiseKMatrix(arg_in);
        t2 = clock;                 % Take the time
        te =etime(t2,t1);   % Calculate elapsed time

        % Print the time as output
        fprintf('Total elapsed time is %f s\r\n', te);


        % Output the KMat, KMatEstimated, OptKMatrix for viewing
        if togglePause == 1
            % Pause so we can visually examine
            KMatrix
            KMatEstimated
            OptKMatrix
        end


        if togglePause == 1
            % Pause so we can visually examine
            fprintf('Press any key to continue...'); pause;
        end

        % Calculate the difference in values in the two matrices and weigh
        % components accordingly
        KMatIndex = [1 4 5 7 8]; % Index of important matrix values
        K_EM = zeros(3);         % Initialise 3x3 matrix of zeros
        E_EM = 0;                % Initialise error value
        for i = 1:5
            K_EM(KMatIndex(i)) = KMatEstimated(KMatIndex(i)) - ...
                KMatrix(KMatIndex(i));
            E_EM = E_EM + (K_EM(KMatIndex(i))/KMatEstimated(KMatIndex(i)))^2;
        end
        if togglePause == 1
            % Pause so we can visually examine
            fprintf('\rKMatEstimated versus KMatrix:\r');
            K_EM;
            fprintf('Error value is %f\r', E_EM);
            fprintf('Cost value is %f\r\n', E_EM*te);
            fprintf('Press any key to continue...'); pause;
        end


        KMatIndex = [1 4 5 7 8]; % Index of important matrix values
        K_OM = zeros(3);         % Initialise 3x3 matrix of zeros
        E_OM = 0;                % Initialise error value
        for i = 1:5
            K_OM(KMatIndex(i)) = OptKMatrix(KMatIndex(i)) - ...
                KMatrix(KMatIndex(i));
            E_OM = E_OM + (K_OM(KMatIndex(i))/OptKMatrix(KMatIndex(i)))^2;
        end
        if togglePause == 1
            % Pause so we can visually examine
            fprintf('\rOptKMatrix versus KMatrix:\r');
            K_OM;
            fprintf('Error value is %f\r', E_OM);
            fprintf('Cost value is %f\r\n', E_OM*te);
            fprintf('Press any key to continue...'); pause;
        end



        KMatIndex = [1 4 5 7 8]; % Index of important matrix values
        K_OE = zeros(3);         % Initialise 3x3 matrix of zeros
        E_OE = 0;                % Initialise error value
        for i = 1:5
            K_OE(KMatIndex(i)) = OptKMatrix(KMatIndex(i)) - ...
                KMatEstimated(KMatIndex(i));
            E_OE = E_OE + (K_OE(KMatIndex(i))/OptKMatrix(KMatIndex(i)))^2;
        end
        if togglePause == 1
            % Pause so we can visually examine
            fprintf('\rOptKMatrix versus KMatEstimated:\r');
            K_OE;
            fprintf('Error value is %f\r', E_OE);
            fprintf('Cost value is %f\r\n', E_OE*te);
            fprintf('Press any key to continue...'); pause;
        end


        % Store variables, this is not most efficient way to do this

        store_t1{nLoop} = t1;
        store_t2{nLoop} = t2;
        store_te{nLoop} = te;
        store_KMatrix{nLoop} = KMatrix;
        store_KMatEstimated{nLoop} = KMatEstimated;
        store_OptKMatrix{nLoop} = OptKMatrix;
        store_K_EM{nLoop} = K_EM;
        store_K_OM{nLoop} = K_OM;
        store_K_OE{nLoop} = K_OE;
        store_E_EM{nLoop} = E_EM;
        store_E_OM{nLoop} = E_OM;
        store_E_OE{nLoop} = E_OE;
    end

    % Calculate total error, cost values, then average them and output
    avg_E_EM{n} = 0; avg_E_OM{n} = 0; avg_E_OE{n} = 0; avg_te{n} = 0;
    for nLoop = 1:Num
       avg_E_EM{n} = avg_E_EM{n} + store_E_EM{nLoop};
       avg_E_OM{n} = avg_E_OM{n} + store_E_OM{nLoop};
       avg_E_OE{n} = avg_E_OE{n} + store_E_OE{nLoop};
       avg_te{n} = avg_te{n} + store_te{nLoop};
    end

    avg_E_EM{n} = avg_E_EM{n}/Num;
    avg_E_OM{n} = avg_E_OM{n}/Num;
    avg_E_OE{n} = avg_E_OE{n}/Num;

    % Verbose output
    fprintf('KMatEstimate-KMatrix cost value is %f\r', avg_E_EM{n}*te);
    fprintf('OptKMatrix-KMatrix cost value is %f\r', avg_E_OM{n}*te);
    fprintf('OptKMatrix-EstKMatrix cost value is %f\r', avg_E_OE{n}*te);
    fprintf('Average time is %f\r\n', avg_te{n});
    
        
    % Calculate next ransac loop value
    Ransac = n*10;
    n = n+1;
    if n >= nMax
        Looping = 0;
    end
    
    

%end

