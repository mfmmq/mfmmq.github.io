%HeatExchanger.m

p = 1.013; % atm pressure in bar
R = 8315; % gas constant

n_NH3 = Parameter.n_NH3;
n_N2 = Parameter.n_N2;
n_O2 = Parameter.n_O2;
n_H2O = Parameter.n_H2O;
n_H2 = Parameter.n_H2;

% Calculate exit exhaust temperature
t_e1 = 615; % Exhuast inlet temperature i Kelvin
t_a1 = -33+273; % Inlet ammonia temperature
t_a2 = 440; % Exit dissociated ammonia temperature
n_e = 4.75;%23.75; Exhaust flow rate
n_a = 1; %5 Ammonia flow rate

% Specific heat of ammonia
cp_a1 = findProperty(NH3,t_a1,'cp');

% Specific heat of exhaust at inlet
cp1_NH3 = findProperty(NH3,t_e1,'cp');
cp1_H2 = findProperty(H2,t_e1,'cp');
cp1_N2 = findProperty(N2, t_e1,'cp');
cp1_O2 = findProperty(O2, t_e1,'cp');
cp1_H2O = findProperty(H2O, t_e1,'cp');
Cp_e1 = cp1_NH3*n_NH3 + n_H2*cp1_H2 + n_N2*cp1_N2 + n_O2*cp1_O2 + n_H2O*cp1_H2O;
Cp_e1 = Cp_e1/5;

t_e2 = n_a*cp_a1*(t_a1-t_a2)/Cp_e1 + t_e1;
t_e2


% Log mean temperature difference
LMTD = ((t_e2-t_a2) - (t_e1-t_a1))/log((t_e2-t_a2)/(t_e1-t_a1))




% Reynolds number calculations
% For ammonia
Re_a = p/R*NH3.MW/t_a1*20*;