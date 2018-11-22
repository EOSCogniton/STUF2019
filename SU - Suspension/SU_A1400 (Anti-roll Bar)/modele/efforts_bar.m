% Basculeur avant

F=2100; %N
h=0.030; %m
A=0.113; %m
%b=0.002; %m
Re=700*10^6; %Pa
Ks=2; % coefficient de sécurité
% valeur de h a b fixé à la limite de l'inégalité
b=6*Ks*F*A/(h^2*Re)

masse=7800*A*b*h

% Calcul du motion ratio de la barre
% MR_arb = angle de roulis/torsion de la barre
L=0.488/2;
F=1050;
A=0.124;
G=81000*10^6;
D=0.017;
d=0.0125;
phi=(32*L*F*A)/(pi*G*(D^4-d^4))
MR_arb=0.8*1.600/(phi*0.05)
% MR = 5 à l'avant
% MR = 12 à l'arrière