function [Nu_c] = calculateCompressor(State,Plot)
%calculateCompressor
% function calculates compressor characteristics given a certain rotational
% speed, mole flow rate
% It assumes a design value according to atmospheric conditions and a
% rotational speed of 3300 rev/min
% Returns isentropic efficiency, rotational speed
% Best 



% DESIGN VALUES
%--------------------------------------------------------------------------
N_d = 3300*2*pi/60; % Rotational speed in rad/s, set at 3300 rev/min
t_d = 273.13+25;    % Atmospheric temperature
p_d = 1.013;        % 1.013 bar/atmospheric
n_d = 4;            % 4kmol/s



% INLET CONDITIONS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n2 = State(2,2); % Flow rate in kmol/s
p2 = State(2,3);
t2 = State(2,4);
h2 = State(2,5);
v2 = State(2,6);



% CHARACTERISTIC DATA
%--------------------------------------------------------------------------
% Use non-dimensional numbers to calculate isentropic efficiency
% Data from graph gives best fit line for different speed number ratios
% Compressor speed stores non dimensional speed number, N/sqrt(t)
% Compressor molar stores molar flow number, n*sqrt(t)/p
Compressor.speed = [0.5;0.6;0.7;0.8;0.9;1];
Compressor.molar = [
    0.35        0.43        0.5;
    0.45        0.55        0.64;
    0.55        0.66        0.75;
    0.7         0.8         0.86;
    0.85        0.88        0.95;
    0.94        0.99        1.02];
Compressor.efficiency = [
    0.83        0.88        0.70;
    0.84        0.90        0.71;
    0.87        0.91        0.78;
    0.88        0.88        0.76;
    0.86        0.9         0.76;
    0.84        0.83        0.68];



% CHARACTERISTIC CALCULATIONS
%--------------------------------------------------------------------------

N2 = N_d; %?????????????????????????????????????????????????????????????//

% Calculate non-dimensional number ratios
% For non-dimensional molar flow number:
n = (n2*sqrt(t2)/p2) / (n_d*sqrt(t_d)/p_d);
% For non-dimensional speed number
N = (N2/sqrt(t2)) / (N_d/sqrt(t_d));


[s,~] = size(Compressor.speed);
Compressor.polyfit = zeros(s,3);
for i = 1:s
    x = Compressor.molar(i,:);
    y = Compressor.efficiency(i,:);
    p = polyfit(x,y,2);
    %x_incre = linspace(Compressor.molar(i,1):Compressor.molar(i,3),20);
    Compressor.polyfit(i,:) = p;
end


% Interpolate compressor speed curve and molar flow number
index = 0;
if N < 0.9*Compressor.speed(1) || N > 1.1*Compressor.speed(s)
    % Make sure speed number is within allowed range
    error('Compressor speed number %.2f is out of operational range',N);
end
for i=1:s
    % Find which values the speed number is within
    if N >= 0.9*Compressor.speed(i)
        index = i;
    end
end


% Take closest matching speed number as an approximation to avoid
% interpolation (calculation error will be greater than error from not
% interpolating)
if n < 0.9*Compressor.molar(1) || n > 1.1*Compressor.molar(s)
    error('Molar flow number %.2f is out of speed number curve %.2f range',n,N);
end

% Get isentropic efficiency number using polyval and index value
Nu_c = polyval(Compressor.polyfit(index,:),n);






% PLOT CHARACTERISTIC 
%--------------------------------------------------------------------------
% Plot the compressor characteristic
% Polyfit component data and rewrite compressor
if Plot == 1
    [s,~] = size(Compressor.speed);
    for i = 1:s
        x = linspace(Compressor.molar(i,1),Compressor.molar(i,3),20);
        y = polyval(Compressor.polyfit(i,:),x);
        plot(x,y);
        hold on;
    end
    grid on;
    xlim([0 1.2]);
    xlabel('Mole number, n*sqrt(t)/p');
    ylim([0 1]);
    ylabel('Isentropic efficiency');
    title('Compressor Characteristic Efficiency');
end




end


