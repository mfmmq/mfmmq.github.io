%Dissociation.m

hf_NH3 = -45.9; sf_NH3 = 0.19277;		
hf_H2 = 0;      sf_H2 = 0.1306;			
hf_N2 = 0;      sf_N2 = 0.19161;		

% Calculate entropy
s = sf_NH3 - 1.5*sf_H2 - 0.5*sf_N2;

% Calculate enthalpy
h = nf_NH3;

% Gibbs free energy of formation
g = h - 298*s

% Calculating equilibrium constant					
lnK1 = 2*g/8.315/298;
K1 = exp(lnK1);

% Calculating equilibrium constant at a different temperature
t = 500;


%13.25119558	K = 	568749.6212		
					
Calculating equilibrium constant at temp			500	K	
lnK2 = 	-1.717075663	K2 = 	0.1795905641		