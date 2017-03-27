%PlotShomate.m

GasArray(1) = Data.NH3;
GasArray(2) = Data.N2;
GasArray(3) = Data.O2;
GasArray(4) = Data.H2;
GasArray(5) = Data.H2O;



for i = 1:5
    
    
    Gas = GasArray(i);
    GasVal.val = [];
    GasVal.T = [];
    % Set temperature range
    s = size(Gas.shomate_temp);
    for j = 1:s(2)
        
        T = Gas.shomate_temp(1,j):50:Gas.shomate_temp(2,j)-50;

        % Pass shomate constants
        A = Gas.shomate(1,j);
        B = Gas.shomate(2,j);
        C = Gas.shomate(3,j);
        D = Gas.shomate(4,j);
        E = Gas.shomate(5,j);
        F = Gas.shomate(6,j);
        G = Gas.shomate(7,j);
        H = Gas.shomate(8,j);

        t = T./1000;
        h0 = Gas.h0; % enthalpy at 298K

        % Get property from shomate equation
        val = ((A.*t + B.*t.^2./2 + C.*t.^3./3 + D.*t.^4./4 - E./t + F ...
            - H ).*1000+h0);

         GasVal.val = [GasVal.val val];
         GasVal.T = [GasVal.T T];
    end


    GasValArray(i,:) = GasVal;
    plot(GasVal.T,GasVal.val);
end

GasValArray(4).T = GasValArray(4).T(1,5:57);
GasValArray(1).T = GasValArray(1).T(1,9:99);
GasValArray(2).T = GasValArray(2).T(1,9:99);
GasValArray(3).T = GasValArray(3).T(1,9:99);
GasValArray(5).T = GasValArray(5).T(1,1:91);

GasValArray(4).val = GasValArray(4).val(1,5:95);
GasValArray(1).val = GasValArray(1).val(1,9:99);
GasValArray(2).val = GasValArray(2).val(1,9:99);
GasValArray(3).val = GasValArray(3).val(1,9:99);
GasValArray(5).val = GasValArray(5).val(1,1:91);

h_r = 0.7.*GasValArray(1).val + 0.45.*GasValArray(4).val + ...
    3.15.*GasValArray(2).val + 0.75*GasValArray(3).val;
h_p = 1.5*GasValArray(5).val + 3.5 * GasValArray(2).val;

plot(GasValArray(1).T,h_r);
hold on;
plot(GasValArray(1).T,h_p);




