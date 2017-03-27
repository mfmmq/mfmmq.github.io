function [State,Parameter] = runBurner(State,Parameter,Constant,Data)
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

na = Parameter.na;


% BURNER CALCULATIONS
%--------------------------------------------------------------------------
p4 = BPR*p3;

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
if ER < 0.765 || ER > 1.0125
    fprintf('Warning, ER is out of interpolation ranges');
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


% Flame temperature is a function of dissociation levels, fuel:air ratio
% Polynomial exponents found from graph, see logbook
p = [-2796.21658	5480.260233	-946.2104087];
t4 = polyval(p,ER) + 273;


% Find product enthalpies
h4_NH3 = findProperty(Data.NH3,t4,'Dh');
h4_N2 = findProperty(Data.N2, t4,'Dh');
h4_O2 = findProperty(Data.O2, t4,'Dh');
h4_H2O = findProperty(Data.H2O, t4,'Dh');


% Calculate new net flow rate
n4 = n4_NH3 + n4_O2 + n4_N2 + n4_H2O;
h_p = n4_NH3*h4_NH3 + n4_N2*h4_N2 + n4_O2*h4_O2 + n4_H2O*h4_H2O;
h4 = h_p;% - h_c*na 



if t4 < RedLine
    fprintf('Burner successful\r');
    fprintf('\tT4 temperature %d K\r',t4);
    fprintf('\tEquivalence ratio %.1f\r\n',ER);
else
    fprintf('Warning, burner t4 temperature past redline %d\r\n',t4);
end

% Save component flow rates
Parameter.n_NH3 = n4_NH3;
Parameter.n_N2 = n4_N2;
Parameter.n_O2 = n4_O2;
Parameter.n_H2O = n4_H2O;

State(4,1) = 4;
State(4,2) = n4;
State(4,3) = p4;
State(4,4) = t4;
State(4,5) = h4;
State(4,6) = 8315*t4*n4/p4/10^5; % Approximate as ideal



% PLOT CHARACTERISTIC 
%--------------------------------------------------------------------------
% Plot burner flame temperature versus equivalence ratio

% If figure doesn't exist yet, create characteristic curves
if ishandle(2) == 0  
    
    % Plot warning line first (limits of operation) in a lighter color
    % Then plot standard operation line
    % Warning line 0.5 < ER < 1.2
    % Nominal operational range given by 0.765 < ER < 1.0125   
    figure(2);
    
    % Warning line graph
    x = linspace(0.5,1.2,(1.2-.5)*30);
    t = polyval(p,x) + 273;
    plot(x,t,'color', [0.8 0.8 0.8],'LineWidth',2)
    hold on;
    
    % Operational line graph
    x = linspace(0.6,1.0125,(1.0125-.765)*30);
    t = polyval(p,x) + 273;
    plot(x,t,'k','LineWidth',2)
    
    
    % Label and edit the graph
    grid on;
    xlim([0.4 1.3]);
    xlabel('Fuel:Air Equivalence Ratio');
    ylim([1000 2400]);
    ylabel('T4 Temperature (K)');
    title('Burner Flame Temperature');
    
end

% Make sure this is the right figure
figure(2);
% Add performance point onto the graph
hold on;
plot(ER,t4,'rx','MarkerSize',15);



end

%{
t4i = 1200; % Making an initial guess at what the temperature is
t4g = 1500; % Some value of t4 that will start the loop
i = 1; % Initialise loop counter
MaxLoops = 1000;
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

q34 = 1000;
cp_NH3 = findProperty(Data.NH3, t3, 'cp');
cp3_O2 = findProperty(Data.O2, t3, 'cp');
cp_3 = (cp3_O2 + cp_NH3)/2;
% Use these for testing
Q34 = zeros(MaxLoops,1);
T4i = Q34;
T4g = Q34;%abs(t4i -abs(t4i - t4g)abs(t4i - t4g)abs(t4i - t4g) t4g)

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
    % Add the energy of combustion
    h4_N2 = findProperty(Data.N2, t4g, 'Dh');
    h4_O2 = findProperty(Data.O2, t4g, 'Dh');
    h4_H2O = findProperty(Data.H2O, t4g, 'Dh');
    
    
    % Make a guess at the product temperature
    % Try not to overshoot by taking a percentage of the difference
    if q34 < 0
        t4g = t4g + q34/cp_3*0.01/n4;
    elseif q34 > 0
        t4g = t4g - q34/cp_3*0.01/n4;
    end
    
    
    % Enthalpy of the products relative to h0_p
    h_p = 0.5*h4_N2 + 1.5*h4_H2O;
    % Ratio for air to fuel is 1:1, so for heat/total flow rate
    q34 = h_r - h_p + h_c;
    
    
    % Weigh the enthalpies to correspond with the mass flow rate of air
    % Use equivalence ratio to relate mass and fuel flow rate
    
    Q34(i) = q34;
    T4i(i) = t4i;
    T4g(i) = t4g;
    
    
    % If this has been iterating for a long time, return an error
    if i > MaxLoops
        fprintf('Burner combustion calculations did not converge in %i loops'...
            , i);
    end
    i = i + 1;
    
    
end

q34
t4g

t4 = (t4g);
h4 = h3 + q34;
%}


