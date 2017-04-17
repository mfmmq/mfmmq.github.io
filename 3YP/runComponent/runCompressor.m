function [State] = runCompressor(State,Parameter,Constant,Data)
%runCompressor



% COMPRESSOR MODEL DEFINITION
%--------------------------------------------------------------------------
Nu_c = 0.85;    % Isentropic efficiency
CPR = 15;       % Pressure ratio



% STATE CONDITIONS AND CONSTANTS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n2 = State(2,2); % Flow rate in kmol/s
p2 = State(2,3);
t2 = State(2,4);
h2 = State(2,5);
v2 = State(2,6);

gamma = Constant.gamma;




% COMPRESSOR CALCULATIONS
%--------------------------------------------------------------------------
n3 = n2;       % No change in flow rate
p3 = p2 * CPR; % New pressure defined by compressor pressure ratio


% Calculate specific heat at constant pressure
cp = 0.8*findProperty(Data.O2,t2,'cp')+0.2*findProperty(Data.N2,t2,'cp');

% Calculate isenthalpic efficiency
%[Nu_c,N] = calculateCompressor(State,1);
% Save rotational speed in parameter
N = 3000;
Nu_c = 0.85;
Parameter.N = N;


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
if abs(Margin) < abs(w23)*0.1
    fprintf('Compressor successful\r');
    fprintf('\tTemperature at outlet is %.0f K\r',t3);
    %fprintf('\tIsentropic efficiency is %.4f\r',Nu_c);
    %fprintf('\tShaft rotational speed is %i rad/s\r',N);
    fprintf('\tCalculated and tabulated enthalpy margin is %.3f MJ\r', Margin/1000');
    fprintf('\tCompressor work done %.3f MJ\r\n',w23/1000);
else
    fprintf('Compressor calculated and tabulated enthalpy at Stage3 ');
    fprintf('inconsistent, margin %d\r\n',Margin);
end



State(3,1) = 3;
State(3,2) = n3;
State(3,3) = p3;
State(3,4) = t3;
State(3,5) = h3;
State(3,6) = 8315*t3*n3/p3/10^5;

end



