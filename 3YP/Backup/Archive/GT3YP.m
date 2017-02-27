%GT3YP.m
% Gas turbine matlab model
% Muyi Maya Qiu 23/11/2016
% The gas turbine matlab model uses basic thermodynamic equations and
% properties to calculate the work done through ammonia combustion in the
% gas turbine

% All work done is per unit mass currently
% Stage 1 is inlet
% Stage 2 is compressor entrace
% Stage 3 is compressor exit, burner entrance
% Stage 4 is burner exit, turbine entrance
% Stage 5 is turbine exit, exhaust gas

% CHANGELOG
%{
27/11/16 - Added intial burner, turbine characteristic equations
asfasdf
%}

% TODO
% Determine what temperature, flow rate ammonia needs to be injected at
% Determine preburner operation, calculations
% Determine how the injection of ammonia affects the specific heat
% Find and save gas properties for ammonia, air as matlab variable
% Find and save water properties too
% Determine how much oxygen required to be added to air flow
% Get compressor , turbine, burner efficiency maps/characteristic variables
% Decide on some method of post-processing exhaust, using heat (cogen)?


% INITIAL CONDITIONS
%--------------------------------------------------------------------------

% Physical constants
gamma = 1.4;    % Specific heat ratio
cp = 1.005;     % Specific heat at constant pressure, kJ/kgK

% Design parameters
CPR = 20;       % Compressor pressure ratio
%TPR = 10;      % Turbine pressure ratio
BPR = 0.99;     % Burner pressure ratio, accounting for slight loss
Nu_c = 0.85;    % Isentropic compressor efficiency
Nu_t = 0.85;    % Isentropic turbine efficiency
Nu_b = 0.98;    % Adiabatic burner efficiency

% Inlet conditions
P1 = 1;         % Inlet pressure, bar
T1 = 300;       % Inlet temperature, Kelvin
ma = 1;         % Air mass flow rate, kg/s
mo = ma/5;      % Oxygen mass flow rate kg/s
mf = 1;         % Fuel mass flow rate, kg/s
f = mf/ma;      % Fuel to air flow rate ratio
m = mf+ma;      % Total mass flow rate 



% INLET
%--------------------------------------------------------------------------

P2 = P1;        % No inlet changes or drops in pressure yet
T2 = T1;



% COMPRESSOR
%--------------------------------------------------------------------------

% For isentropic compression
P3 = P2*CPR;     % Pressure in bar 

% Calculate specific work done by compressor (negative number)
W23 = cp * T2 * (1-CPR^((gamma-1)/gamma))/Nu_c;

% Calculate new temperature by using work done equals change in enthalpy
T3 = T2 - W23 / cp;



% BURNER
%--------------------------------------------------------------------------

% PREBURNER
% Preburner energy used, fuel temperature change should be added here

% Energy added from combustion
% Use table to look up enthalpy of reactants and products for the
% temperature and pressure at stage 3,4
% Import tables ?


% Reaction given by NH3 + O2 -> N2 + H2O

Q34 = 1000;     % Total fuel heating value, heat released from reaction

% Pressure losses from combustion, design
P4 = P3 * BPR;

% Calculate the temperature
T4 = T3 + Q34/cp;



% TURBINE
%--------------------------------------------------------------------------

% For isentropic compression
P5 = P4/TPR;     % Pressure in bar 

% Calculate specific work done by compressor (negative number)
W45 = cp * T4 * Nu_t * (1-TPR^((gamma-1)/gamma));

% Calculate new temperature by using work done equals change in enthalpy
T5 = T4 - W45 / cp;


% POST PROCESSING
%--------------------------------------------------------------------------
% Possibly using exhaust gas to generate more energy


% TOTAL CHANGE
%--------------------------------------------------------------------------








