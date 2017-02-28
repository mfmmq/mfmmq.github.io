function [ val ] = findProperty(Gas,T,Property)
%findProperty
% Function takes gas structure, property name, and temperature and returns
% values from the gas structure
%
% OUTPUTS
% cp, specific heat at constant pressure in kJ/kmolK
% Dh, change in enthalpy from h0 at 298K in kJ/kmol
% s, change in entropy in kJ/kmolK
%
% Gas is a structure with fields shomate, shomate_temp. shomate_temp is in
% Kelvin, shomate is shomate constants
% T should be input in Kelvin
% Property should be either cp, Dh, or s


% Check if structure is correct

% Check if temperature is within range
if T <= 0
    error('T is negative number %d, must be Kelvin', T);
end
[~,s] = size(Gas.shomate_temp);
if (Gas.shomate_temp(1,1) > T) || (Gas.shomate_temp(2,s) < T)
    error('Gas temperature %f is out of shomate range',T);
end

% Find temperature range
i = 1;
while T > Gas.shomate_temp(2,i)
    i = i+1;
end

% Pass shomate constants
A = Gas.shomate(1,i);
B = Gas.shomate(2,i);
C = Gas.shomate(3,i);
D = Gas.shomate(4,i);
E = Gas.shomate(5,i);
F = Gas.shomate(6,i);
G = Gas.shomate(7,i);
H = Gas.shomate(8,i);

t = T/1000;
h0 = Gas.h0; % enthalpy at 298K

% Get property from shomate equation
if strcmp(Property,'cp')
    val =( A + B*t + C*t^2 + D*t^3 + E/t^2 );
elseif strcmp(Property,'Dh')
    val = ((A*t + B*t^2/2 + C*t^3/3 + D*t^4/4 - E/t + F - H )*1000+h0);
elseif strcmp(Property, 's')
    val = A*ln(t) + B*t + C*t^2/2 + D*t^3/3 - E/(2*t^2) + G;
else 
    error('%s property not found in gas structure', Property);
end



end



