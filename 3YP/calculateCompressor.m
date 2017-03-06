function [Nu_c,N2] = calculateCompressor(State,Plot)
%calculateCompressor
% function calculates compressor characteristics given a certain rotational
% speed, mole flow rate
% It assumes a design value according to atmospheric conditions and a
% rotational speed of 3300 rev/min
% Returns isentropic efficiency, rotational speed in rad/s, figure handle
% Try to operate at 0.7 for optimum performance of design values



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

% Calculate non-dimensional number ratios:
% For non-dimensional molar flow number:
[s,~] = size(Compressor.speed);
n_ratio = (n2*sqrt(t2)/p2) / (n_d*sqrt(t_d)/p_d);
if n_ratio < 0.8*Compressor.molar(1,1) || ...
        n_ratio > 1.2*Compressor.molar(s,3)
    % Check if n is within range of the tabulated values above
    error('Molar flow number %.2f is out of tabulated data range',n_ratio);
end

% To find non-dim speed number:
% Find which speed curve this flow number lies in
% Take closest matching speed number as an approximation to avoid
% interpolation (calculation error will be dominant)
N_ratio = -1;
for i=1:s
    % Find which values the speed number is within
    % Round up values with 0.7
    if n_ratio >= 0.7*Compressor.speed(i) && n_ratio<=1.2*Compressor.speed(i)
        N_ratio = Compressor.speed(i);
        break;
    end
end
if N_ratio == -1
    error('Could not find matching compressor speed number for molar flow %.2f',n_ratio);
end

% Solve for spool speed
N2 = N_ratio * (N_d/sqrt(t_d)) * sqrt(t2);


% Polyfit the data for the selected curve and find the efficiency value
Compressor.polyfit = zeros(s,3);
x = Compressor.molar(i,:);
y = Compressor.efficiency(i,:);
p = polyfit(x,y,2);


% Get isentropic efficiency number using polyval and index value
Nu_c = polyval(p,n_ratio);






% PLOT CHARACTERISTIC 
%--------------------------------------------------------------------------
% Plot the compressor characteristic
% Polyfit component data and rewrite compressor
if Plot == 1
    
    % Calculate polyfit
    Compressor.polyfit = zeros(s,3);
    for i = 1:s
        x = Compressor.molar(i,:);
        y = Compressor.efficiency(i,:);
        p = polyfit(x,y,2);
        Compressor.polyfit(i,:) = p;
    end
    
    % Create graph
    f = figure(1)
    for i = 1:s
        x = linspace(Compressor.molar(i,1),Compressor.molar(i,3),20);
        y = polyval(Compressor.polyfit(i,:),x);
        plot(x,y);
        hold on;
    end
    
    % Label the graph
    grid on;
    xlim([0 1.2]);
    xlabel('Mole number, n*sqrt(t)/p');
    ylim([0 1]);
    ylabel('Isentropic efficiency');
    title('Compressor Characteristic Efficiency');
    
    % Add performance point onto the graph
    
end




end


