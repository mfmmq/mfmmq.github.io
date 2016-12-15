function [Stage] = runCompressor(Stage, Stream, Parameters)
%runCompressor

% Pass variables
T2 = Stage.T2;
P2 = Stage.P2;
CPR = Parameters.CPR;
gamma = Parameters.gamma;
cp = Parameters.cp;
Nu_c = Parameters.Nu_c;
ma = Stream.ma;


% For isentropic compression
Stage.P3 = P2*CPR;     % Pressure in bar 

% Calculate work done by compressor (negative number)
Stage.W23 = cp * T2 * (1-CPR^((gamma-1)/gamma))/Nu_c;

% Calculate new temperature by using work done equals change in enthalpy
Stage.T3 = T2 - Stage.W23;

end