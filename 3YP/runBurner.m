function [State] = runBurner(State,Parameter,Constant)
%runCompressor



% BURNER MODEL DEFINITION
%--------------------------------------------------------------------------
% Preburner needs to be run, that goes here!!!!!!!!!!!!!
% Preburner function needs to define fuel entrance pressure, temperature
% Some mixing happens here, change in pressure, temperature, enthalpy, etc 


% Don't use this for now, doing 1:1 for simplicity with no fuel injection
ER = 0.8; % High equivalence ratios are typically required ,
% this is an equivalence ratio in terms of mass flows , air:fuel


% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
m3 = State(3,2);
p3 = State(3,3);
t3 = State(3,4);
h3 = State(3,5);

gamma = Constant.gamma;
cp = Constant.cp;
NH3_MW = 44;
Air_MW = 8315/287;
BPR = 0.99;


% Import gas table structures
load('NH3.mat');
load('O2.mat');
load('N2.mat');
load('H2O.mat');
load('NO.mat');



% BURNER CALCULATIONS
%--------------------------------------------------------------------------
t4i = 1200; % Making an initial guess at what the temperature is
t4g = 1500; % Some value of t4 that will start the loop
i = 1; % Initialise loop counter
MaxLoops = 1000;


% Use these for testing
Q34 = zeros(MaxLoops,1);
T4i = Q34;
T4g = Q34;

while abs(t4i - t4g) > 50
    % Make a guess at what the change in enthalpy is 
    % Use findProperty to find base enthalpy of the  
    hi_NH3 = findProperty(NH3, t3, 'Dh') / NH3.MW;
    hi_O2 = findProperty(O2, t3, 'Dh') / O2.MW;
    hi_N2 = findProperty(N2, t4i, 'Dh') / N2.MW;
    hi_H2O = findProperty(H2O, t4i, 'Dh') / H2O.MW;
    
    % Reaction given by NH3 + .75 O2 -> .5 N2 + 1.5 H2O
    % Heat generated per kg of air/fuel mix. Assume all fuel is burnt up
    % for 1:1 air fuel mixture
    %Q34 = (2*h_NH3 + 3/2*h_O2 - h_N2 - 3*h_H2O)/2 ;
    q34 = hi_NH3 + 0.75*hi_O2 - 0.5*hi_N2 - 1.5*hi_H2O; % per kg of fuel
    
    % Ratio for air to fuel is 1:1, so for heat/total flow rate
    q34 = q34/2/1.75/2/2; 
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
    
    % See how close the guess was by solving for the temperature and trying
    % to match it with the temperature guess
    t4g = q34 / cp + t3;
    
    
    Q34(i) = q34;
    T4i(i) = t4i;
    T4g(i) = t4g;
    
    
    % Shift our t4i guess using t4g
    if t4g >= t4i
        t4i = (t4g-t4i)/500 + t4i;
    else
        t4i = (t4i-t4g)/500 + t4i;
    end
    
    % If this has been iterating for a long time, return an error
    if i > MaxLoops
        error('Burner combustion calculations did not converge in %i loops'...
            , i);
    end
    i = i + 1;
    
    
end

q34

t4 = (t4i + t4g)/2;
h4 = h3 + q34;






%mf = Q34/ (Dh3);
% Pressure losses from combustion, design
p4 = p3 * BPR;
m4 = m3;

% Calculate the temperature
%T4 = T3*(1 + f*Nu_b*Q34/(cp*T3))/(1+ f);



State(4,1) = 4;
State(4,2) = m4;
State(4,3) = p4;
State(4,4) = t4;
State(4,5) = h4;



end