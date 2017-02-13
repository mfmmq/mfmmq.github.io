function [State] = runBurner(State,Parameter,Constant,Data)
%runCompressor



% BURNER MODEL DEFINITION
%--------------------------------------------------------------------------
% Ammonia dissociation with exhaust energy checking


% Setting the equivalence ratio 
ER = 1.0; % High equivalence ratios are typically required ,
% this is an equivalence ratio in terms of mass flows , air:fuel
RedLine = 2000;


% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n3 = State(3,2);
p3 = State(3,3);
t3 = State(3,4);
h3 = State(3,5);

gamma = Constant.gamma;
cp = Constant.cp;
NH3_MW = Data.NH3.MW;
O2_MW = Data.O2.MW;
BPR = 0.99;



% BURNER CALCULATIONS
%--------------------------------------------------------------------------
t4i = 1200; % Making an initial guess at what the temperature is
t4g = 1500; % Some value of t4 that will start the loop
i = 1; % Initialise loop counter
MaxLoops = 1000;

%{
% Find the heat of combustion
% Heat of combustion is the change in enthalpy between the reference states
% of products and reactants at T=298.15K
% Find reference enthalpies for all 
h0_NH3 = findProperty(NH3, t3, 'Dh');
h0_O2 = findProperty(O2, t3, 'Dh');
h0_N2 = findProperty(N2, t4g, 'Dh');
h0_H2O = findProperty(H2O, t4g, 'Dh');
% Weigh the heat of combustion for 1kmol of ammonia
h0 = h0_NH3 + 0.75*h0_O2 - 0.5*h0_N2 - 1.5*h0_H2O;

% Use these for testing
%Q34 = zeros(MaxLoops,1);
%T4i = Q34;
%T4g = Q34;%abs(t4i -abs(t4i - t4g)abs(t4i - t4g)abs(t4i - t4g) t4g)
%}

% Inject some fuel (1.5 kmol)
n4 = n3 + 1;
q34 = 1000;
while abs(q34) > 50
   
    % Reaction given by NH3 + .75 O2 -> .5 N2 + 1.5 H2O
    % To find the final temperature of the products:
    % 1. Make a guess at the temperature of the products
    % 2. Use the guess to calculate the total product enthalpy
    % 3. Make a better guess at the temperature of the products using the
    %    difference in enthalpy between reactants and products and the heat
    %    of combustion of ammonia
    % 4. Once the temperature converges, stop guessing    
    
    % Make a guess at the product temperature
    % Try not to overshoot by taking a percentage of the difference
    if q34 > 0
        t4g = t4g + q34/cp*0.2;
    elseif q34 < 0
        t4g = t4g - q34/cp*0.2;
    end
    
    % Use findProperty to find the new enthalpies based on the reference
    % state
    % Add the energy of combustion
    hi_NH3 = findProperty(NH3, t3, 'Dh');
    hi_O2 = findProperty(O2, t3, 'Dh');
    hi_N2 = findProperty(N2, t4g, 'Dh');
    hi_H2O = findProperty(H2O, t4g, 'Dh');
    
    cp_NH3 = findProperty(NH3, t3, 'Dh');
    cp_O2 = findProperty(O2, t3, 'Dh');
    cp_N2 = findProperty(N2, t4g, 'Dh');
    cp_H2O = findProperty(H2O, t4g, 'Dh');
    
    % Enthalpy of the reactants relative to h0_r
    h_r = hi_NH3 + 0.75*hi_O2;
    % Enthalpy of the products relative to h0_p
    h_p = 0.5*hi_N2 + 1.5*hi_H2O;
    % Ratio for air to fuel is 1:1, so for heat/total flow rate
    q34 = h_r - h_p; 
    
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
        
    
    %Q34(i) = q34;
    %T4i(i) = t4i;
    %T4g(i) = t4g;
    
    
    % If this has been iterating for a long time, return an error
    if i > MaxLoops
        error('Burner combustion calculations did not converge in %i loops'...
            , i);
    end
    i = i + 1;
    
    
end



q34
t4 = (t4g)
h4 = h3 + q34;


%{
if t4g > RedLine
    error('t4 is greater than redline temperature allowed by materials')
end
%}


% Calculate the temperature
%T4 = T3*(1 + f*Nu_b*Q34/(cp*T3))/(1+ f);



State(4,1) = 4;
State(4,2) = n4;
State(4,3) = p4;
State(4,4) = t4;
State(4,5) = h4;



end


