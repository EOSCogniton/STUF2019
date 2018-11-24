G=81000*10^6; %module de cisaillement en Pa
D=0.017; %diamètre extérieur barre en m
d=0.0125; %diamètre intérieur barre en m
L=0.488/2; %demi longueur de la barre en m
A=0.124; % longueur du bras de levier en m
K_bar=pi*G*(D^4-d^4)/(32*L*A^2 )
E=210*10^9; % module d'Young en Pa
h=2*D; % largeur du couteau
b=0.05; % épaisseur du couteau
K_arm=E*h*b^3/(4*A^3)
K_arb=K_bar*K_arm/(K_bar+K_arm)

% Conclusions sur l'influence des paramètres
% * On veut minimiser l'influence du bras,
%   donc maximiser sa raideur, ie épaisseur importante
%   2mm semble pas mal

% * Ensemble de valeurs qui marchent pour le KB moyen de la bar avant :
%   Raideur voulue de 100N/mm
%   Raideur de 104 avec un nouveau couteau
%   D=0.015; ; d=0.013m ; A=83mm

% * Pour le KB moyen de la bar arrière :
%   Raideur voulue de 88N/mm
%   Raideur de 89.6N/mm obtenue
%   D=0.017 ; d=0.0125 ; A=146.5mm

% 