% Basculeur avant

F=2100; %N
h=0.030; %m
A=0.113; %m
%b=0.002; %m
Re=700*10^6; %Pa
Ks=2; % coefficient de s�curit�
% valeur de h a b fix� � la limite de l'in�galit�
b=6*Ks*F*A/(h^2*Re)

masse=7800*A*b*h