mf = 0.5;
W45 = 0;
W23 = 0;
T4 = 1400;
while T4 < 1700
    
     
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
    27/11/16 - Added intial burner, turbine characteristic equations, built gas
    tables
    %}

    % TODO
    %{
    Determine what temperature, flow rate ammonia needs to be injected at
    Determine preburner operation, calculations
    Determine how the injection of ammonia affects the specific heat
    Find and save gas properties for ammonia, air as matlab variable
    Find and save water properties too
    Determine how much oxygen required to be added to air flow
    Get compressor , turbine, burner efficiency maps/characteristic variables
    Decide on some method of post-processing exhaust, using heat (cogen)?
    Account for changes in cp, gamma using table
    Include incomplete combustion , nitrous oxide generation
    %}


    % INITIAL CONDITIONS
    %--------------------------------------------------------------------------

    % Import gas table structures
    load('NH3.mat');
    load('O2.mat');
    load('N2.mat');
    load('H2O.mat');
    load('NO.mat');

    % Physical constants
    gamma = 1.4;    % Specific heat ratio
    cp = 1.005;     % Specific heat at constant pressure, kJ/kgK


    % Design parameters
    CPR = 30;       % Compressor pressure ratio
    TPR = 1/30;     % Turbine pressure ratio
    BPR = 0.99;     % Burner pressure ratio, accounting for slight loss
    % T4 = T4 + 200;      % Guess at redline temperature in Kelvin
    W = 200 * 10^3; % Maximum power required, 200MW in kW

    % Efficiencies
    Nu_c = 0.85;    % Isentropic compressor efficiency
    Nu_t = 0.85;    % Isentropic turbine efficiency
    Nu_b = 0.98;    % Adiabatic burner efficiency

    % Inlet conditions
    P1 = 1;         % Inlet pressure, bar
    T1 = 300;       % Inlet temperature, Kelvin
    ma = 1;         % Air flow rate, kmol/s
    mf = ma;        % Fuel flow rate, kmol/s
    f = mf/ma;      % Fuel to air flow rate ratio

    


    % INLET
    %--------------------------------------------------------------------------

    P2 = P1;        % No inlet changes or drops in pressure yet
    T2 = T1;



    % COMPRESSOR
    %--------------------------------------------------------------------------

    % For isentropic compression
    P3 = P2*CPR;     % Pressure in bar 

    % Calculate work done by compressor (negative number)
    W23 = ma * cp * T2 * (1-CPR^((gamma-1)/gamma))/Nu_c;

    % Calculate new temperature by using work done equals change in enthalpy
    T3 = T2 - W23 / cp;



    % BURNER
    %--------------------------------------------------------------------------

    % PREBURNER
    % Preburner energy used, fuel temperature change should be added here


    % Energy added from combustion
    % Uses findProperty function to get enthalpy/kg at that temperature
    h_NH3 = findProperty(NH3, T3, 'Dh') / NH3.MW * mf;
    h_O2 = findProperty(O2, T3, 'Dh') / NH3.MW * mf ;
    h_N2 = findProperty(N2, T4, 'Dh') / NH3.MW * mf;
    h_H2O = findProperty(H2O, T4, 'Dh') / NH3.MW * mf;
    
   % Q34 = (T4 / T3 * (1+f) -1)/f/Nu_b * (cp*T3);

    % Reaction given by 2 NH3 + 3/2 O2 -> N2 + 3 H2O
    %mf = (2*h_NH3 + 3/2*h_O2 - h_N2 - 3*h_H2O)/2/Q34;
    Q34 = (2*h_NH3 + 3/2*h_O2 - h_N2 - 3*h_H2O)/2 ;
    
    T4 = Q34 / cp / (ma+mf) + T3;
    
    %mf = Q34/ (Dh3);
    % Pressure losses from combustion, design
    P4 = P3 * BPR;

    % Calculate the temperature
    %T4 = T3*(1 + f*Nu_b*Q34/(cp*T3))/(1+ f);


    % TURBINE
    %--------------------------------------------------------------------------

    % For isentropic compression
    P5 = P4*TPR;     % Pressure in bar 

    % Calculate specific work done by compressor (negative number)
    W45 = (ma + mf) * cp * T4 * Nu_t * (1-TPR^((gamma-1)/gamma));

    % Calculate new temperature by using work done equals change in enthalpy
    T5 = T4 - W45 / cp / (ma+mf);


    % POST PROCESSING
    %--------------------------------------------------------------------------
    % Possibly using exhaust gas to generate more energy


    % TOTAL CHANGE
    %--------------------------------------------------------------------------
    W = [W23 W45 W45+W23]
    T = [T1 T2 T3 T4 T5]
    P = [P1 P2 P3 P4 P5]
    mf


end