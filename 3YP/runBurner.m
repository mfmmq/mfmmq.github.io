function [State] = runBurner(State,Parameter,Constant)
%runCompressor



% BURNER MODEL DEFINITION
%--------------------------------------------------------------------------
% Preburner needs to be run, that goes here!!!!!!!!!!!!!
% Preburner function needs to define fuel entrance pressure, temperature
% Some mixing happens here, change in pressure, temperature, enthalpy, etc 



ER = 0.8; % High equivalence ratios are typically required ,
% this is an equivalence ratio in terms of mass flows , air:fuel


% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
p3 = State(3,2);
t3 = State(3,3);
h3 = State(3,4);

gamma = Constant.gamma;
cp = Constant.cp;
NH3_MW = 44;
Air_MW = 8315/287;S

% Import gas table structures
load('NH3.mat');
load('O2.mat');
load('N2.mat');
load('H2O.mat');
load('NO.mat');



% BURNER CALCULATIONS
%--------------------------------------------------------------------------
t4i = 1700; % Making an initial guess at what the temperature is
while abs(t41 - t42) > 20
    % Make a guess at what the change in enthalpy is 
    % Use findProperty to find base enthalpy of the  
    hi_NH3 = findProperty(NH3, t3, 'Dh') / NH3.MW;
    hi_O2 = findProperty(O2, t3, 'Dh') / O2.MW;
    hi_N2 = findProperty(N2, t4i, 'Dh') / N2.MW;
    hi_H2O = findProperty(H2O, t4i, 'Dh') / H2O.MW;
    
    % Reaction given by NH3 + .75 O2 -> .5 N2 + 1.5 H2O
    % Heat generated per kg of 
    Q34 = (2*h_NH3 + 3/2*h_O2 - h_N2 - 3*h_H2O)/2 ;
    q34 = ER * (hi_NH3 + 0.75*hi_O2 - 0.5*hi_N2 - 1.5*h1_H2O);
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
    
    % See how close the guess was by solving for the temperature and trying
    % to match it with the temperature guess
    T4 = Q34 / cp / (ma+mf) + T3;
    
    hf_N2 = findProperty(N2, t4, 'Dh') / N2.MW;
    hf_H2O = findProperty(H2O, t4, 'Dh') / H2O.MW;

end




%mf = Q34/ (Dh3);
% Pressure losses from combustion, design
P4 = P3 * BPR;

% Calculate the temperature
%T4 = T3*(1 + f*Nu_b*Q34/(cp*T3))/(1+ f);



p3 = p2 * CPR; % New pressure defined by compressor pressure ratio

% Specific work done by compressor defined by isentropic efficiency
w23 = cp * t2 * (1-CPR^((gamma-1)/gamma))/Nu_c;
h3 = w23 + h2;
% Calculate new temperature by using work done equals change in enthalpy
t3 = t2 - w23/cp;


State(4,1) = 4;
State(4,2) = p4;
State(4,3) = t4;
State(4,4) = h4;



end