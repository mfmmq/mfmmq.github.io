function [] = runHeatExchanger(State, Parameter, Constant,Data)
%runHeatExchanger.m
% Function acts as a shell tube heat exchanger to partially dissociate
% Input of ammonia end labeled as A, exit to combustor labeled as B


% HEAT EXCHANGER MODEL DEFINITION
%--------------------------------------------------------------------------
% Heat exchanger final temperature is set from the dissociation percentage
% required and data from literature
% Temperature of ammonia stream entering combustion chamber
ta_b = 170+273;

% Minimum temperature difference between two countercurrent streams at the
% entrace to the combustor. This is to avoid a very long heat exchanger
delta_t = 20;





% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass exhaust conditions from the State variable
ne = State(5,2); % Flow rate in kmol/s
p5 = State(5,3);
t5 = State(5,4);

h5 = State(5,5);
cp = Constant.cp;

% Use naming conventions for the initial exhaust temperature
te_b = t5;

% Ammonia conditions set
pa_a = 1.7;
ta_a = 273-33;
ha_a = findProperty(Data.NH3,ta_a,'Dh');
ha_b = 0.28*findProperty(Data.H2,ta_b,'Dh') + ...
    0.18667*findProperty(Data.N2,ta_b,'Dh') + ...
    0.53333*findProperty(Data.NH3,ta_b,'Dh');


% Get ammonia flow rate required retrospectively from the State array
na = State(4,2) - State(3,2);




% HEAT EXCHANGER CALCULATIONS
%--------------------------------------------------------------------------

% Calculate the energy required to raise the temperature of the ammonia
Q = na*(ha_b - ha_a);%na * cp * (ta_b-ta_a);


% Calculate the final temperature of the exhaust afterwards
% Check to make sure temperature significantly greater than the ambient
% temperature (plausibility)
te_a = te_b + Q/cp/29/ne;

if ((te_a-ta_a) < delta_t) || (te_a < delta_t+State(1,4))
    error('Temperature difference in the heat exchanger was too small, check exit exhaust temperature')
end
if (te_b - ta_b) < delta_t
    error('Temperature difference in the heat exchanger was too small, check inlet exhaust temperature');
end

fprintf('Heat exchanger converges\r');
fprintf('\tTemperature difference at burner inlet %.0f K\r',te_b - ta_b);

end


