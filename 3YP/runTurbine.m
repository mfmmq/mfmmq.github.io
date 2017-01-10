function [State] = runTurbine(State,Parameter,Constant)
%runTurbine



p_atm = 1.013; %bar



% TURBINE MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_t = 0.85;    % Isentropic efficiency
p5 = p_atm;         % Gas should be expanded to atmospheric pressure



% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
m4 = State(4,2); % Flow rate in kg/s
p4 = State(4,3);
t4 = State(4,4);
h4 = State(4,5);
gamma = Constant.gamma;
cp = Constant.cp;



% TURBINE CALCULATIONS
%--------------------------------------------------------------------------
m5 = m4; % No change in flow rate

TPR = p5/p4;

% Specific work done by turbine is defined by atmospheric pressure and 
% isentropic efficiency
w45 = cp * t4 * (1-TPR^((gamma-1)/gamma))*Nu_t
h5 = w45 + h4;
% Calculate new temperature by using work done equals change in enthalpy
t5 = t4 - w45/cp;


State(5,1) = 5;
State(5,2) = m5;
State(5,3) = p5;
State(5,4) = t5;
State(5,5) = h5;



end