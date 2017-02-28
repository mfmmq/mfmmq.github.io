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

ER_min = 0.765;
ER_max = 1.0125;
ammonia_min = 4/3*4*0.2*ER_min;
ammonia_max = 4/3*4*0.2*ER_max;
ammonia = linspace(ammonia_min,ammonia_max,20);
power_out = zeros(1,20);

for i = 1:20
    power_out(i) = findPower(ammonia(i));
end

plot(ammonia,power_out);
xlabel('ammonia flow rate');
ylabel('power out kJ');