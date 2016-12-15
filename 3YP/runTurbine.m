function [Stage] = runTurbine(Stage,Stream, Parameters)
%runTurbine

T4 = Stage.T4;
P4 = Stage.P4;
TPR = Parameters.TPR;
Nu_t = Parameters.Nu_t;
cp = Parameters.cp;
gamma = Parameters.gamma;
ma = Stream.ma;
mf = Stream.mf;


% For isentropic compression
Stage.P5 = P4*TPR;     % Pressure in bar

% Calculate specific work done by turbine
Stage.W45 = cp * T4 * Nu_t * (1-TPR^((gamma-1)/gamma));

% Calculate new temperature by using work done equals change in enthalpy
Stage.T5 = T4 - Stage.W45 / cp ;

end