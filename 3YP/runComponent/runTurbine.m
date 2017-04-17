function [State] = runTurbine(State,Parameter,Constant,Data)
%runTurbine



% TURBINE MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_t = 0.86;             % Isentropic efficiency
p5 = State(1,3);        % Exit pressure will be atmospheric, need to calculate flow rate



% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n4 = State(4,2);        % Flow rate in kmol/s
p4 = State(4,3);
t4 = State(4,4);
h4 = State(4,5);
gamma = Constant.gamma;
cp = Constant.cp;

% Load individual component flow rates
n_NH3 = Parameter.n_NH3;
n_N2 = Parameter.n_N2;
n_O2 = Parameter.n_O2;
n_H2O = Parameter.n_H2O;



% TURBINE CALCULATIONS
%--------------------------------------------------------------------------
n5 = n4; % No change in flow rate
TPR = p5/p4;

% Calculate specific heat at constant pressure per kmol of stream flow
cp4_NH3 = findProperty(Data.NH3,t4,'cp');
cp4_N2 = findProperty(Data.N2, t4,'cp');
cp4_O2 = findProperty(Data.O2, t4,'cp');
cp4_H2O = findProperty(Data.H2O, t4,'cp');
cp_n = n_NH3*cp4_NH3 + n_N2*cp4_N2 + n_O2*cp4_O2 + n_H2O*cp4_H2O;


% Specific work done by turbine is defined by atmospheric pressure and 
% isentropic efficiency
w45 = cp_n * t4 * (1-TPR^((gamma-1)/gamma))*Nu_t;
h5 = h4 - w45;

% Calculate new temperature by using work done equals change in enthalpy
t5 = t4 - w45/cp_n;



%CHECKS
%--------------------------------------------------------------------------
% Use findProperties to see if enthalpy is reasonable
h5_NH3 = findProperty(Data.NH3,t5,'Dh');
h5_N2 = findProperty(Data.N2, t5,'Dh');
h5_O2 = findProperty(Data.O2, t5,'Dh');
h5_H2O = findProperty(Data.H2O, t5,'Dh');
h5_meas = n_NH3*h5_NH3 + n_N2*h5_N2 + n_O2*h5_O2 + n_H2O*h5_H2O;

Margin = h5-h5_meas;
if abs(Margin) < abs(w45*0.2)
    fprintf('Turbine successful\r');
    fprintf('\tCalculated and tabulated enthalpy margin is %.3f MJ\r', Margin/1000');
    fprintf('\tTurbine work done %.3f MJ\r\n',w45/1000);
else
    fprintf('Turbine calculated and tabulated enthalpy at Stage5 inconsistent, margin %d\r\n',Margin);
end
%}


State(5,1) = 5;
State(5,2) = n5;
State(5,3) = p5;
State(5,4) = t5;
State(5,5) = h5;
State(5,6) = 8315*t5*n5/p5/10^5;


end



