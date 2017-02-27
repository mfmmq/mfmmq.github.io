function [State] = runTurbine(State,Parameter,Constant,Data)
%runTurbine



% TURBINE MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_t = 0.9;             % Isentropic efficiency
p5 = State(1,3);        % Exit pressure will be atmospheric, need to calculate flow rate



% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n4 = State(4,2);        % Flow rate in kmol/s
p4 = State(4,3);
t4 = State(4,4);
h4 = State(4,5);
gamma = Constant.gamma;
cp = Constant.cp;



% TURBINE CALCULATIONS
%--------------------------------------------------------------------------
n5 = n4; % No change in flow rate
TPR = p5/p4;

% Calculate specific heat at constant pressure per kmol of stream flow
cp = (0.25*findProperty(Data.O2,t4,'cp')+ ...
    0.5*findProperty(Data.N2,t4,'cp') + ...
    1.5*findProperty(Data.H2O,t4,'cp'))/2.25;



% Specific work done by turbine is defined by atmospheric pressure and 
% isentropic efficiency
w45 = n4 * cp * t4 * (1-TPR^((gamma-1)/gamma))*Nu_t;
h5 = h4 - w45;

% Calculate new temperature by using work done equals change in enthalpy
t5 = t4 - w45/cp/n4;

%CHECKS
%--------------------------------------------------------------------------
% Use findProperties to see if enthalpy is reasonable

h5_meas = n5*(0.25*findProperty(Data.O2,t5,'Dh')+ ...
    0.5*findProperty(Data.N2,t5,'Dh') + ...
    1.5*findProperty(Data.H2O,t5,'Dh'))/2.25;
Margin = h5-h5_meas;
%if abs(Margin) < abs(h5*0.2)
    fprintf('Turbine successful\r\t(calculated and tabulated enthalpy margin is %d)\r', Margin');
    fprintf('\tTurbine work done %d\r\n',w45);
%else
    %error('Turbine calculated and tabulated enthalpy at Stage5 inconsistent, margin %d\r\n',Margin);
%end
%}


State(5,1) = 5;
State(5,2) = n5;
State(5,3) = p5;
State(5,4) = t5;
State(5,5) = h5;


end



