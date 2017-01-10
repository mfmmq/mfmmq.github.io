function [w_out] = RunModel()
%RunModel.m


% INITIAL CONDITIONS
%--------------------------------------------------------------------------

% Physical constants
% Define some physical constants which we have assumed to be constant.
% These should be replaced later with more accurate representations that
% vary with temperature, etc
Constant = struct;       % Define a structure for constants
Constant.gamma = 1.4;    % Specific heat ratio
Constant.cp = 1.005;     % Specific heat at constant pressure, kJ/kgK
Parameter = struct;

% Initialise a matrix to carry state information
% The matrix is structured with each row representing a different stage
% [StageNumber FlowRate StagePressure StageTemp Enthalpy]
% All pressures should be in bar, all temperature should be in K, specific
% volume should be in m3/kg, enthalpy is kJ/kg, entropy is kJ/kgK
% Missing values should be flagged with -999
State = zeros(7,5);



% Define atmospheric conditions
p_atm = 1.013;          % Atmospheric pressure in bar
t_atm = 298;            % Atmospheric pressure in Kelvin
State(1,:) = [1 1 p_atm t_atm 0]; % Add to stage

%{
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
%}



% Run a 1:1 mix of fuel and air for simplicity


% INLET CONDITIONS (1-2)
%--------------------------------------------------------------------------
State(2,:) = State(1,:);
State(2,1) = 2;


% COMPRESSION (2-3)
%--------------------------------------------------------------------------
% Run the compressor
State = runCompressor(State,Parameter,Constant);


% COMBUSTION (3-4)
%--------------------------------------------------------------------------
% Burner
State = runBurner(State,Parameter,Constant);



% EXPANSION (4-5)
%--------------------------------------------------------------------------
% Run the turbine
State = runTurbine(State,Parameter,Constant);


% POST-PROCESSING
%--------------------------------------------------------------------------
% Something about checking NOx emissions and doing some cogen



% POWER GENERATION 
%--------------------------------------------------------------------------
% Run the generator
%runGenerator();


w_out = State(5,5)-State(4,5) + State(3,5)-State(2,5) 


