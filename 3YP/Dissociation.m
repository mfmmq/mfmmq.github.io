%Dissociation.m

% 2NH3 <-> 3H2 + N2

hf_NH3 = -45.9; sf_NH3 = 0.19277;		
hf_H2 = 0;      sf_H2 = 0.1306;			
hf_N2 = 0;      sf_N2 = 0.19161;		

% Calculate entropy
s = sf_NH3 - 1.5*sf_H2 - 0.5*sf_N2

% Calculate enthalpy
h = hf_NH3;

% Gibbs free energy of formation
g = h - 298*s;

% Calculating equilibrium constant					
lnK0 = -g*1000*1000/8315/298;
K0 = exp(lnK0);

% Calculating equilibrium constant at a different temperature
% Take standard reaction enthalpy of ammonia as a constant
hf = -45.9;
t = 100:1:1000+273;
lnK = lnK0 - hf.*(1000*1000/8315).*(1./t-1/298);
K = exp(lnK);

% calculate the value of decomposed NH3	
% Assume volume is constant in heat exchanger
p = (1.013*10^5/8315).*t;
%p = 1;
alpha = sqrt(4*K./(3*sqrt(3).*p+4*K));

figure(1)
clf
plot(t,alpha)

title('Ammonia Dissociation versus Temperature')
xlabel('Temperature (K)')
ylabel('Percent Dissociation');
xlim([100 700]);   