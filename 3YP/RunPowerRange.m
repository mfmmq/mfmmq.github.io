%RunPowerRange.m

% Equivalence ratio is the fuel:air/stochiometric fuel:air ratio
% This should fall between 0.765 and 1.1 (from experimental data)
% Ammonia is flow rate of ammonia in kmol/s

% Design point will probably be Eq. Ratio = 0.9 ie inlet air flow of 4kmol
% (currently the designed inlet flow)
% and ammonia_n = 1 kmol/s

% I have yet to decide this because I'm not sure what the average flow rate
% will be/average power requirement

%StochioRatio = 4/3;
%FuelOxidiserRatio = na/(n3*0.2);
%ER = FuelOxidiserRatio/StochioRatio;

addpath('findValue')
addpath('runComponent')
addpath('Data')


% Close all figures
close all;




% First calculate the values for steady state air flow
n_air = 10;
ER_min = 0.65;
ER_max = 1.0125;
ER_range = linspace(ER_min,ER_max,20);
power_out = zeros(20,20);
ammonia = ER_range.*4./3.*n_air.*0.2;
for i = 1:20
    power_out(i) = findPower(n_air,ammonia(i));
end

ammonia_range = ER_range.*4./3.*n_air.*0.2;
for i = 1:20
    % Fix air flow rate and test different ammonia values within allowed
    % equivalence ratio ranges
    n_air_min = ammonia_range(i)/ER_max/4*3/0.2;
    n_air_max = ammonia_range(i)/ER_min/4*3/0.2;
    n_air_range = linspace(n_air_min,n_air_max,20);
    for j = 1:20
        power_out(i,j) = findPower(n_air_range(j),ammonia_range(i));
    end
end


figure(4);
plot(ammonia,power_out);
xlabel('Equivalence ratio');
ylabel('power out kW');
grid on;
title('Ammonia input versus power out for constant inlet flow of 10kmol');










