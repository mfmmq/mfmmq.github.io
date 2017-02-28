function [State] = runAdiabaticBurner(State,Parameter,Constant,Data)
%runCompressor



% BURNER MODEL DEFINITION
%--------------------------------------------------------------------------

RedLine = 2500;
BPR = 0.99;
h_c = 18864; % Enthalpy of combustion




% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n3 = State(3,2);
p3 = State(3,3);
t3 = State(3,4);
h3 = State(3,5);

na = Parameter.na;


% BURNER CALCULATIONS
%--------------------------------------------------------------------------
p4 = BPR*p3;
t4 = 2000;

% Check the equivalence ratio
% Equivalence ratio is defined as the ratio of fuel:oxidiser to the
% stochiometric fuel:air ratio
% High equivalence ratios are typically required
StochioRatio = 4/3;
FuelOxidiserRatio = na/(n3*0.2);
ER = FuelOxidiserRatio/StochioRatio;
if ER < 0.5 || ER > 1.2
    error('Equivalence ratio %.1f is out of bounds',ER);
end


h3_NH3 = findProperty(Data.NH3, t3, 'Dh');
h3_O2 = findProperty(Data.O2, t3, 'Dh');
h3_N2 = findProperty(Data.N2,t3,'Dh');
% Enthalpy of the reactants relative to h0_r
h_r = na*h3_NH3 + 0.2*n3*h3_O2 + 0.8*h3_N2;


% Assume all ammonia that can be combusted is combusted and calculate flow 
% rates of products
% Reaction given by NH3 + .75 O2 -> .5 N2 + 1.5 H2O
% Dissociated to 28% hydrogen - assume ratio of ammonia to hydrogen remains
% the same after combustion
if na > 0.2*n3*0.75
    % Amount of oxygen is the limiting factor
    n4_O2 = 0;
    n4_NH3 = na - 0.2*n3/0.75;
else
    % Amount of nitrogen is the limiting factor
    n4_NH3 = 0;
    n4_O2 = 0.2*n3 - na*0.75;
end
n4_N2 = 0.8*n3 + (na-n4_NH3)/2;
n4_H2O = (na-n4_NH3)/3*2;


% Calculate new net flow rate
n4 = n4_NH3 + n4_O2 + n4_N2 + n4_H2O;

t4i = 1200; % Making an initial guess at what the temperature is
t4g = 1500; % Some value of t4 that will start the loop
i = 1; % Initialise loop counter
MaxLoops = 1000;


q34 = 1000;


% Use these for testing
Q34 = zeros(MaxLoops,1);
T4i = Q34;
T4g = Q34;

while abs(q34) > 50
   
    % Reaction given by NH3 + .75 O2 -> .5 N2 + 1.5 H2O
    % To find the final temperature of the products:
    % 1. Make a guess at the temperature of the products
    % 2. Use the guess to calculate the total product enthalpy
    % 3. Make a better guess at the temperature of the products using the
    %    difference in enthalpy between reactants and products and the heat
    %    of combustion of ammonia
    % 4. Once the temperature converges, stop guessing    
    
    
    % Use findProperty to find the new enthalpies based on the reference
    % state
    h4_NH3 = findProperty(Data.NH3,t4g,'Dh');
    h4_N2 = findProperty(Data.N2, t4g,'Dh');
    h4_O2 = findProperty(Data.O2, t4g,'Dh');
    h4_H2O = findProperty(Data.H2O, t4g,'Dh');
    
    c4_NH3 = findProperty(Data.NH3,t4g,'Dh');
    c4_N2 = findProperty(Data.N2, t4g,'Dh');
    c4_O2 = findProperty(Data.O2, t4g,'Dh');
    c4_H2O = findProperty(Data.H2O, t4g,'Dh');
    
    
    cp_4 = n4_NH3*c4_NH3 + n4_N2*c4_N2 + n4_O2*c4_O2 + n4_H2O*c4_H2O;
    

    % Make a guess at the product temperature
    % Try not to overshoot by taking a percentage of the difference
    if q34 < 0
        t4g = t4g + q34/cp_4/n4*10;
    elseif q34 > 0
        t4g = t4g - q34/cp_4/n4*10;
    end
    
    
    % Enthalpy of the products relative to h0_p
    h_p = n4_NH3*h4_NH3 + n4_N2*h4_N2 + n4_O2*h4_O2 + n4_H2O*h4_H2O;
    % Ratio for air to fuel is 1:1, so for heat/total flow rate
    q34 = h_r - h_p + h_c;
    
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
    
    Q34(i) = q34;
    T4i(i) = t4i;
    T4g(i) = t4g;
    
    
    % If this has been iterating for a long time, return an error
    if i > MaxLoops
        
        error('Burner combustion calculations did not converge in %i loops'...
            , i);
    end
    i = i + 1;
    
    
end


t4 = (t4g);
h4 = h3 + q34;

if t4 < RedLine
    fprintf('Burner successful\r');
    fprintf('\tt4 temperature %d\r\n',t4);
else
    fprintf('Warning, burner t4 temperature past redline %d\r\n',t4);
end




State(4,1) = 4;
State(4,2) = n4;
State(4,3) = p4;
State(4,4) = t4;
State(4,5) = h4;
State(4,5) = 8315*t4*n4/p4/10^5; % Approximate as ideal



end

%{

%}


