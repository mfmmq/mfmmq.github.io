function [State] = runCompressor(State,Parameter,Constant)
%runCompressor



% COMPRESSOR MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_c = 0.85;    % Isentropic efficiency
CPR = 20;       % Pressure ratio


% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n2 = State(2,2); % Flow rate in kg/s
p2 = State(2,3);
t2 = State(2,4);
h2 = State(2,5);
gamma = Constant.gamma;
cp = Constant.cp;



% COMPRESSOR CALCULATIONS
%--------------------------------------------------------------------------
n3 = n2; % No change in flow rate
p3 = p2 * CPR; % New pressure defined by compressor pressure ratio

% Specific work done by compressor defined by isentropic efficiency
w23 = cp * t2 * (1-CPR^((gamma-1)/gamma))/Nu_c
h3 = w23 + h2;
% Calculate new temperature by using work done equals change in enthalpy
t3 = t2 - w23/cp;


State(3,1) = 3;
State(3,2) = n3;
State(3,3) = p3;
State(3,4) = t3;
State(3,5) = h3;



end