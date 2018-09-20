Fosc = 16e6;
BRP = 1; %0 à 63
Tq = (2*(BRP+1))/Fosc;
% Nquanta = (sync_seg + prop_seg + phase_seg1 + phase_seg2); %8 à 25
% T = Tq*Nquanta;
% Fcan = 1/T;

%

T = 1e-6;
Nquanta = 8:1:25;
Tq = T./Nquanta;
BRP = Tq.*Fosc/2 + 1;