function [State] = runCompressor(State,Parameter,Constant,Data)
%runCompressor



% COMPRESSOR MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_c = 0.87;    % Isentropic efficiency
CPR = 30;       % Pressure ratio


% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n2 = State(2,2); % Flow rate in kmol/s
p2 = State(2,3);
t2 = State(2,4);
h2 = State(2,5);

gamma = Constant.gamma;




% COMPRESSOR CALCULATIONS
%--------------------------------------------------------------------------
n3 = n2;       % No change in flow rate
p3 = p2 * CPR; % New pressure defined by compressor pressure ratio


% Calculate specific heat at constant pressure
%cp = 0.78*findProperty(Data.O2,t2,'cp')+0.22*findProperty(Data.N2,t2,'cp');
cp = findProperty(Data.O2,t2,'cp');

% Calculate total work done by compressor (defined by isentropic efficiency)
% Find the resulting enthalpy at stage 4
w23 = n3 * cp * t2 * (1-CPR^((gamma-1)/gamma))/Nu_c; % Work in (neg)
h3 = h2 - w23;

% Calculate new temperature by using work done equals change in enthalpy
t3 = t2 - w23/cp/n3;




% CHECKS
%--------------------------------------------------------------------------
% Use findProperties to see if enthalpy is reasonable
h3_meas = n3*findProperty(Data.O2,t3,'Dh');
Margin = h3-h3_meas;
if abs(Margin) < h3*0.1
    fprintf('Compressor successful\r\t(calculated and tabulated enthalpy margin is %d)\r', Margin');
    fprintf('\tCompressor work done %d\r\n',w23);
else
    fprintf('Compressor calculated and tabulated enthalpy at Stage3 inconsistent, margin %d\r\n',Margin);
end
    


State(3,1) = 3;
State(3,2) = n3;
State(3,3) = p3;
State(3,4) = t3;
State(3,5) = h3;

end



