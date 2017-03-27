function [Nu_t] = calculateTurbine(State,Plot)
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
t_d = 1900;         % Atmospheric temperature in K
p_d = 20;           % Aim for higher compression ratio to promote combust.
n_d = 5;            % 5kmol/s



% INLET CONDITIONS
%--------------------------------------------------------------------------
% Pass variables from input State structure
n4 = State(4,2); % Flow rate in kmol/s
p4 = State(4,3);
t4 = State(4,4);
h4 = State(4,5);
v4 = State(4,6);



% CHARACTERISTIC DATA
%--------------------------------------------------------------------------
% Use non-dimensional numbers to calculate isentropic efficiency
% Data from graph gives best fit line for different speed number ratios
% Compressor speed stores non dimensional speed number, N/sqrt(t)
% Compressor molar stores molar flow number, n*sqrt(t)/p
Turbine.speed = [0.5;0.6;0.7;0.8;0.9;1];
Turbine.molar = [
    0.35        0.43        0.5;
    0.45        0.55        0.64;
    0.55        0.66        0.75;
    0.7         0.8         0.86;
    0.85        0.88        0.95;
    0.94        0.99        1.02];
Turbine.efficiency = [
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
[s,~] = size(Turbine.speed);
n_ratio = (n2*sqrt(t2)/p2) / (n_d*sqrt(t_d)/p_d);
if n_ratio < 0.8*Turbine.molar(1,1) || ...
        n_ratio > 1.2*Turbine.molar(s,3)
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
    if n_ratio >= Turbine.molar(i,1) && n_ratio<=Turbine.molar(i,3)
        N_ratio = Turbine.speed(i);
        break;
    end
end
if N_ratio == -1
    error('Could not find matching compressor speed number for molar flow %.2f',n_ratio);
end

% Solve for spool speed
N2 = N_ratio * (N_d/sqrt(t_d)) * sqrt(t2);


% Polyfit the data for the selected curve and find the efficiency value
Turbine.polyfit = zeros(s,3);
x = Turbine.molar(i,:);
y = Turbine.efficiency(i,:);
p = polyfit(x,y,2);


% Get isentropic efficiency number using polyval and index value
Nu_t = polyval(p,n_ratio);






% PLOT CHARACTERISTIC 
%--------------------------------------------------------------------------
% Plot the compressor characteristic
% Polyfit component data and rewrite compressor
if Plot == 1
    
    % If figure doesn't exist yet, create characteristic curves
    if ishandle(3) == 0
        % Calculate polyfit
        Turbine.polyfit = zeros(s,3);
        for i = 1:s
            x = Turbine.molar(i,:);
            y = Turbine.efficiency(i,:);
            p = polyfit(x,y,2);
            Turbine.polyfit(i,:) = p;
        end

        % Create graph
        figure(3);
        for i = 1:s
            x = linspace(Turbine.molar(i,1),Turbine.molar(i,3),20);
            y = polyval(Turbine.polyfit(i,:),x);
            plot(x,y, ...
                'LineWidth',2);
            hold on;
        end

        % Label and edit the graph 
        grid on;
        xlim([0 1.2]);
        xlabel('Mole number, n*sqrt(t)/p');
        ylim([0 1]);
        ylabel('Isentropic efficiency');
        title('Compressor Characteristic Efficiency');
    end
    
    % Make sure this is the right figure
    figure(3);
    % Add performance point onto the graph
    hold on;
    plot(n_ratio,Nu_t,'kx','MarkerSize',10);
    
end




end


