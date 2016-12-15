

% Physical constants
Parameters.gamma = 1.4;    % Specific heat ratio
Parameters.cp = 1.005;     % Specific heat at constant pressure, kJ/kgK


% Design 
Parameters.CPR = 30;       % Compressor pressure ratio
Parameters.TPR = 1/30;     % Turbine pressure ratio
Parameters.BPR = 0.99;     % Burner pressure ratio, accounting for slight loss
W = 200 * 10^3; % Maximum power required, 200MW in kW

% Efficiencies
Parameters.Nu_c = 0.85;    % Isentropic compressor efficiency
Parameters.Nu_t = 0.85;    % Isentropic turbine efficiency
Parameters.Nu_b = 0.98;    % Adiabatic burner efficiency

% Inlet conditions
Stage.P1 = 1;         % Inlet pressure, bar
Stage.T1 = 300;       % Inlet temperature, Kelvin
Stream.ma = 1;         % Air flow rate, kmol/s
Stream.mf = Stream.ma;        % Fuel flow rate, kmol/s
      % Fuel to air flow rate ratio




% INLET
%--------------------------------------------------------------------------

Stage.P2 = Stage.P1;        % No inlet changes or drops in pressure yet
Stage.T2 = Stage.T1;


Stage = runCompressor(Stage,Stream,Parameters);

Stage.T4 = 1700;
Stage.P4 = Stage.P3 * Parameters.BPR;

Stage = runTurbine(Stage,Stream,Parameters);





% To get 200 MW of power, required total mass flow rate:
m = 200 * 10^3 / (Stage.W23 + Stage.W45); % in kg/s

% Converting to volumetric flow, pv = RT
v = 287 * 293 / 10^5 ;
V = m*v ;

