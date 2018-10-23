%% Clément MARIE - OLYMPIX 2017

%% Ce modèle renvoie les couples, forces et pressions de freinage, ainsi que la force à appliquer 
% la pédale de frein pour bloquer les 4 roues.

%% Paramètres du problème 
%Hypothèse d'une masse homogène sur deux roues du même essieu (pas de
%transfert de charge transversal)
%Châssis infiniment rigide 
%Pneus à la limite du glissement

%% Initialisation

clc

g = 9.81; % accélération de pesanteur

m = 315; % masse du véhicule avec pilote en kg 
h = 0.300; % hauteur du centre de gravité en m 
mu = 1.6; % coefficient d'adhérence max du penumatique
R = 0.26035; % rayon de la roue (intérieur) en m (1" = 0.254m) (ici le pneu fait 13")
a = 0.50; % répartition de la masse sur l'avant (cf Specsheet)
L = 1.635; % empattement en m

r = 0.090; % point d'application du couple de freinage moyen sur le disque en m 
etha = 0.5; % coefficient de frottement des plaquettes

%% Maitre cylindre avant (Référence du MC avant : Beringer MC127)

D_f = 0.0127; % diamètre du maitre cylindre avant en m 
c = 0.020; % course utile du maitre cylindre avant en m 

%% Etrier avant (Référence de l'étrier avant : Beringer 2P1A)

Dp_f = 0.032; % diamètre d'un piston en m 
N_f = 2; % nombre de pistons sur un étrier 
% n = 2; % nombre d'étriers sur le maitre cylindre 
% E = 2; % étrier mobile = 1 étrier fixe = 2

%% Maitre cylindre arrière (Référence du MC arrière : Beringer MC127)

D_b = 0.0127; % diamètre du maitre cylindre arrière en m 
c = 0.020; % course utile du maitre cylindre arrière en m 

%% Etrier arrière (Référence de l'étrier arrière : Beringer 2D1)

Dp_b = 0.027; % diamètre d'un piston en m 
N_b = 2; % nombre de pistons sur un étrier 
% n = 2; % nombre d'étrier sur le maitre cylindre 
% E = 2; % étrier mobile = 1 étrier fixe = 2

%% Calcul de la répartition de masse sur les deux essieux

Favant = g*m*(L*a+mu*h)/L; %Charge sur les roues avant
Farriere = m*g-Favant; %Charge sur les roues arrière

a_avant = Favant/(m*g); % répartition de masse lors du freinage sur l'avant 
a_arriere = Farriere/(m*g); % répartition de masse lors du freinage sur l'arrière

if Farriere<0  % permet d'éviter d'avoir des valeurs de force négatives si on change la position 
    Farriere =0 % du centre de gravité dans des positions extrêmes 
    Favant = m*g 
    a_avant = 1; 
    a_arriere = 0; 
end

%% Prise en compte du changement de mu lors du freinage

Ff = Favant / (9.81*2) * 2.2 ; %charge sur UN pneu avant
Fr = Farriere / (9.81*2) * 2.2 ; %charge sur UN pneu arriere

if Fr<50
    Fr=50;
end

muavant = -min_grip_r5_13('HB137',10,0,0,Ff) ;
muarriere = -min_grip_r5_13('HB137',10,0,0,Fr) ;

temp = min_grip_r5_13('HB136',10,0,0,Ff) ;
if temp>muavant
    muavant=temp ;
    muarriere = -min_grip_r5_13('HB136',10,0,0,Fr) ;
end

temp = min_grip_r6_13('HB137',10,0,0,Ff) ;
if temp>muavant
    muavant=temp ;
    muarriere = -min_grip_r6_13('HB137',10,0,0,Fr) ;
end

temp = min_grip_r6_13('HB138',10,0,0,Ff) ;
if temp>muavant
    muavant=temp ;
    muarriere = -min_grip_r6_13('HB138',10,0,0,Fr) ;
end

muavant = muavant * 0.66 ;
muarriere = muarriere * 0.66 ;

%% Calcul de la presssion de freinage à l'avant

Tb_f = R*Favant*muavant/2 %Couple de freinage sur une roue avant
Ffrein_f = R*Favant*muavant/(r*etha*2); % sur une roue 
Sp_f = pi*N_f*(Dp_f/2)^2; % Surface totale des pistons 
Pfrein_f = Ffrein_f/Sp_f; % pression de freinage à l'avant en Pa 
Pbar_f = Pfrein_f*10^-5 % pression en bar à l'avant. Une valeur de 70 bar max est recommandée

%% Force de freinage dans le maitre cylindre avant

Sm_f = pi*(D_f/2)^2; % surface du piston du maitre cylindre 
Fpedale_f = Pfrein_f*Sm_f % force axiale dans le maitre cylindre pour avoir la limite du glissement au niveau des pneus

%% Calcul de la pression de freinage à l'arrière

Tb_r = R*Farriere*muarriere/2 %Couple de freinage sur une roue arrière
Ffrein_b = R*Farriere*muarriere/(r*etha*2); % sur une roue 
Sp_b = pi*N_b*(Dp_b/2)^2; % Surface totale des pistons 
Pfrein_b = Ffrein_b/Sp_b; % pression de freinage à l'arrière en Pa 
Pbar_b = Pfrein_b*10^-5 % pression en bar à l'arrière. Une valeur de 70 bar max est recommandée

%% Force de freinage dans le maitre cylindre arrière

Sm_b = pi*(D_b/2)^2; % surface du piston du maitre cylindre arrière 
Fpedale_b = Pfrein_b*Sm_b % force axiale dans le maitre cylindre pour avoir la limite du glissement au niveau des pneus

%% Force totale sur les deux maitres cylindres

Ftot = Fpedale_b+Fpedale_f

%% Calcul de la force à appliquer sur la pédale

ratio = 2.5; %Dépend uniquement de la conception du pédalier. Une valeur proche de 4 semble meilleure.
Fpilote = Ftot/ratio; %Force à appliquer par le pilote sur la pédale en N.
% Rappel : le réglement impose que la pédale doit résister à 2000N
FPilote = Fpilote/g %Force à appliquer par le pilote sur la pédale en kg.