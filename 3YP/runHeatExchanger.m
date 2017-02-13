function [] = runHeatExchanger(State, Parameter, Constant)
%runHeatExchanger.m
% Function acts as a shell tube heat exchanger to partially dissociate
% Input of ammonia end labeled as A, exit to combustor labeled as B


% HEAT EXCHANGER MODEL DEFINITION
%--------------------------------------------------------------------------
% Heat exchanger final temperature is set from the dissociation percentage
% required and data from literature
% Temperature of ammonia stream entering combustion chamber
ta_b = 170;

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
gamma = Constant.gamma;
cp = Constant.cp;

% Use naming conventions for the initial exhaust temperature
te_b = t5;


% Get input ammonia conditions from the Parameter variable
% Input ammonia conditions are stored in a row vector in the same order as
% the State array
State_Ammonia = Parameter.ammonia_input;
pa_a = State_Ammonia(3);
ta_a = State_Ammonia(4);
ha_a = State_Ammonia(5);

% Get ammonia flow rate required retrospectively from the State array
na = State(4,2) - State(3,2);



% HEAT EXCHANGER CALCULATIONS
%--------------------------------------------------------------------------

% Calculate the energy required to raise the temperature of the ammonia
Q = na * cp * (ta_b-ta_a);

% Calculate the final temperature of the exhaust afterwards
% Check to make sure temperature significantly greater than the ambient
% temperature (plausibility)
te_a = te_b + Q/cp/29/ne;
if ((te_a-ta_a) < delta_t) || (te_a < delta_t+State(1,4))
    error('Temperature difference in the heat exchanger was too small, check exit exhaust temperature')
end


if (ta_b - te_b) < delta_t
    error('Temperature difference in the heat exchanger was too small, check inlet exhaust temperature');
end



end


