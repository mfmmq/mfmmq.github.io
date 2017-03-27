%AdiabaticFlameTemperature.m


% BURNER MODEL DEFINITION
%--------------------------------------------------------------------------

RedLine = 2500;
BPR = 0.99;
HHV_NH3 = 22500; % Enthalpy of combustion
HHV_H2 = 141900;
LHV_NH3 = 18646;
LHV_H2 = 120971;

n3 = 3.75;
t3 = 800;
na = 1;


% BURNER CALCULATIONS
%--------------------------------------------------------------------------

% Check the equivalence ratio
% Equivalence ratio is defined as the ratio of fuel:oxidiser to the
% stochiometric fuel:air ratio
% High equivalence ratios are typically required
StochioRatio = 4/3;
FuelOxidiserRatio = na/(n3*0.2);
ER = FuelOxidiserRatio/StochioRatio;
if ER < 0.4 || ER > 1.2
    error('Equivalence ratio %.1f is out of bounds',ER);
end

cp_NH3 = findProperty(Data.NH3, 298, 'cp');
cp_O2 = findProperty(Data.O2, 298, 'cp');
cp_N2 = findProperty(Data.N2,298,'cp');
% Enthalpy of the reactants relative to h0_r
cp_r = na*cp_NH3 + 0.2*n3*cp_O2 + 0.8*n3*cp_N2;


h3_NH3 = findProperty(Data.NH3, t3, 'Dh');
h3_O2 = findProperty(Data.O2, t3, 'Dh');
h3_N2 = findProperty(Data.N2,t3,'Dh');
h3_H2 = findProperty(Data.H2,t3,'Dh');
% Enthalpy of the reactants relative to h0_r
h_r = na*(0.7*h3_NH3+0.45*h3_H2+0.15*h3_N2) + 0.2*n3*h3_O2 + 0.8*n3*h3_N2;
na
n3
HHV = na*0.7*HHV_NH3 + 0.45*na*HHV_H2;
LHV = na*0.7*LHV_NH3 + 0.45*na*LHV_H2;
h_c = HHV;


H_R = size(2,40);
for i = 1:40
    t = 50*i+500;
    h3_NH3 = findProperty(Data.NH3, t, 'Dh');
    h3_O2 = findProperty(Data.O2, t, 'Dh');
    h3_N2 = findProperty(Data.N2,t,'Dh');
    % Enthalpy of the reactants relative to h0_r
    H_R(2,i) = na*h3_NH3 + 0.2*n3*h3_O2 + 0.8*n3*h3_N2;
    H_R(1,i) = t;
end

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
t4g = 2000; % Some value of t4 that will start the loop
i = 1; % Initialise loop counter
MaxLoops = 1000;


q34 = 1000;


% Use these for testing
Q34 = zeros(MaxLoops,1);
H_P = zeros(2,MaxLoops);
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
        t4g = t4g + q34/cp_4/n4*100;
    elseif q34 > 0
        t4g = t4g - q34/cp_4/n4*100;
    end
    
    
    % Enthalpy of the products relative to h0_p

    h_p = n4_NH3*h4_NH3 + n4_N2*h4_N2 + n4_O2*h4_O2 + n4_H2O*h4_H2O;
    % Ratio for air to fuel is 1:1, so for heat/total flow rate
    q34 = h_r - h_p + h_c;
    
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
    
    Q34(i) = q34;
    H_Pg(:,i) =[t4g;h_p];
    T4g(i) = t4g;
    
    
    % If this has been iterating for a long time, return an error
    if i > MaxLoops
        
        error('Burner combustion calculations did not converge in %i loops'...
            , i);
        q34 = 0;
    end
    i = i + 1;
    
    
end

H_P = zeros(2,30);

for i = 1:40
    t = 800 + 50*i;
    h4_NH3 = findProperty(Data.NH3,t,'Dh');
    h4_N2 = findProperty(Data.N2, t,'Dh');
    h4_O2 = findProperty(Data.O2, t,'Dh');
    h4_H2O = findProperty(Data.H2O, t,'Dh');
    H_P(2,i) = n4_NH3*h4_NH3 + n4_N2*h4_N2 + n4_O2*h4_O2 + n4_H2O*h4_H2O;
    H_P(1,i) = t;
end
    cp_NH3 = findProperty(Data.NH3,298,'cp');
    cp_N2 = findProperty(Data.N2, 298,'cp');
    cp_O2 = findProperty(Data.O2, 298,'cp');
    cp_H2O = 35.22; %findProperty(Data.H2O, 298,'cp');
    cp_p = n4_NH3*cp_NH3 + n4_N2*cp_N2 + n4_O2*cp_O2 + n4_H2O*cp_H2O;



n4_NH3
n4_N2
n4_O2
n4_H2O

t4 = (t4g);

if t4 < RedLine
    fprintf('Burner successful\r');
    fprintf('\tEq ratio %.2f\r\tt4 temperature %d\r\n',ER,t4);
else
    fprintf('Warning, burner t4 temperature past redline %d\r\n',t4);
end
figure(1)
clf
plot(H_R(1,:),H_R(2,:)+h_c);
hold on;
plot(H_R(1,:),polyval([cp_r h_c],H_R(1,:)));
hold on;

plot(H_P(1,:),H_P(2,:));
hold on;
plot(H_P(1,:),polyval([cp_p 0],H_P(1,:)));

plot(H_Pg(1,:),H_Pg(2,:),'+');

plot(H_R(1,:),polyval([0 H_R(2,6)+h_c],H_R(1,:)));
xlim([500 2000]);
title('Enthalpy of Reactants and Products for 1kMol of Ammonia')


%{

%}


