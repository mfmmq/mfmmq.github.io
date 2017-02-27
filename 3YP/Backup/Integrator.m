%Integrator.m
% This function needs some turbine matlab model and demand/supply data, it
% then integrates the amount of ammonia needed over a certain time period

% The engine model is in RunModel.m

% The engine model defines the amount of work that can be generated per
% kilogram of air
% Further work should be done as far as burner/combustion characteristics
% and processes go, the calculations are probably not that accurate
% Eventually the program should account for performance variations in the
% compressor and turbine due to changes in flow rate, etc. 
% An accurate model representing current industrial turbines should be
% found to represent the component characteristics



% Run the model, get the work output/kg air 

w_out = RunModel;

Demand = [123.5570504 % This is in MW/hr
129.5449491
130.9211547
130.9436233
133.4207934
142.679755
147.1716152
142.3034049
135.3811843
128.1350405
118.5371766
110.8454043
101.3168187
99.22348831
100.33007
99.42757866
96.40179871
95.74459031
96.72197716
97.64319234
109.7425674
120.4488853
130.8855793
133.7110137
135.3399917
136.2368659
136.5907473
138.714036
143.9267658
161.2313811
171.9882535
168.6366779
159.9581569
149.0758344
137.9969111
125.9799212
114.1501701
110.1956854
111.253585
107.606172
104.2583412
100.7345059
101.3655008];

s = size(Demand); % Find the number of values we need to integrate
M = 0;              % Initialise the mass of ammonia counter

% Start the integration loop, treat the demand as constant for all hours
for i = 1:s(1)
    m = Demand(i)/w_out;
    M_hr = m * 3600;
    M = M+M_hr;
end






