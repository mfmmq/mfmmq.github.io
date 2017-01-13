%PlotTest.m

% Plot the number of runs vs time
%load('ransac.mat');
Runs = (1:10)*10;
Time = cell2mat(ransac.Time);
figure(1)
plot(Runs,Time,'o--')
xlabel('Number of RANSAC Runs');
ylabel('ransacHomog Runtime (s)');
title('RANSAC Runs vs Time');

% Plot the error between estimated K-matrix and actual K-matrix vs runs
% Calculate the error
Error = zeros(1,10);
for i = 1:10
    ErrorMatrix = ransac.ErrorMatrix{i};
    for j = 1:9
        Error(i) = Error(i) + ErrorMatrix(j)^2;
    end
end
figure(2)
plot(Runs,Error,'o--')
xlabel('Number of RANSAC Runs');
ylabel('KMatrix Error');
title('RANSAC Runs vs Error');

% Plot the cost (Error*time)
Cost = cell2mat(ransac.Cost).*Time.*Time;
figure(3)
plot(Runs,Cost)
xlabel('Number of RANSAC Runs');
ylabel('KMatrix Cost');
title('RANSAC Runs vs Cost');

figure(4)
subplot(1,2,1);

plot(Runs,Time,'o')
xlabel('Number of RANSAC Runs');
ylabel('ransacHomog Runtime (s)');
title('RANSAC Runs vs Time');
xlim([0 110])

subplot(1,2,2);
plot(Runs,Error,'o')
xlabel('Number of RANSAC Runs');
ylabel('KMatrix Error');
title('RANSAC Runs vs Error');
xlim([0 110])
