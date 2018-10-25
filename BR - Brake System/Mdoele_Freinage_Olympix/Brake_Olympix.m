%% Cl�ment MARIE - OLYMPIX 2017

%% Ce mod�le renvoie les couples, forces et pressions de freinage, ainsi que la force � appliquer 
% la p�dale de frein pour bloquer les 4 roues.

%% Param�tres du probl�me 
%Hypoth�se d'une masse homog�ne sur deux roues du m�me essieu (pas de
%transfert de charge transversal)
%Ch�ssis infiniment rigide 
%Pneus � la limite du glissement

%% Initialisation

clc

g = 9.81; % acc�l�ration de pesanteur

m = 315; % masse du v�hicule avec pilote en kg 
h = 0.300; % hauteur du centre de gravit� en m 
mu = 1.6; % coefficient d'adh�rence max du penumatique
R = 0.26035; % rayon de la roue (int�rieur) en m (1" = 0.254m) (ici le pneu fait 13")
a = 0.50; % r�partition de la masse sur l'avant (cf Specsheet)
L = 1.635; % empattement en m

r = 0.090; % point d'application du couple de freinage moyen sur le disque en m 
etha = 0.5; % coefficient de frottement des plaquettes

%% Maitre cylindre avant (R�f�rence du MC avant : Beringer MC127)

D_f = 0.0127; % diam�tre du maitre cylindre avant en m 
c = 0.020; % course utile du maitre cylindre avant en m 

%% Etrier avant (R�f�rence de l'�trier avant : Beringer 2P1A)

Dp_f = 0.032; % diam�tre d'un piston en m 
N_f = 2; % nombre de pistons sur un �trier 
% n = 2; % nombre d'�triers sur le maitre cylindre 
% E = 2; % �trier mobile = 1 �trier fixe = 2

%% Maitre cylindre arri�re (R�f�rence du MC arri�re : Beringer MC127)

D_b = 0.0127; % diam�tre du maitre cylindre arri�re en m 
c = 0.020; % course utile du maitre cylindre arri�re en m 

%% Etrier arri�re (R�f�rence de l'�trier arri�re : Beringer 2D1)

Dp_b = 0.027; % diam�tre d'un piston en m 
N_b = 2; % nombre de pistons sur un �trier 
% n = 2; % nombre d'�trier sur le maitre cylindre 
% E = 2; % �trier mobile = 1 �trier fixe = 2

%% Calcul de la r�partition de masse sur les deux essieux

Favant = g*m*(L*a+mu*h)/L; %Charge sur les roues avant
Farriere = m*g-Favant; %Charge sur les roues arri�re

a_avant = Favant/(m*g); % r�partition de masse lors du freinage sur l'avant 
a_arriere = Farriere/(m*g); % r�partition de masse lors du freinage sur l'arri�re

if Farriere<0  % permet d'�viter d'avoir des valeurs de force n�gatives si on change la position 
    Farriere =0 % du centre de gravit� dans des positions extr�mes 
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

%% Calcul de la presssion de freinage � l'avant

Tb_f = R*Favant*muavant/2 %Couple de freinage sur une roue avant
Ffrein_f = R*Favant*muavant/(r*etha*2); % sur une roue 
Sp_f = pi*N_f*(Dp_f/2)^2; % Surface totale des pistons 
Pfrein_f = Ffrein_f/Sp_f; % pression de freinage � l'avant en Pa 
Pbar_f = Pfrein_f*10^-5 % pression en bar � l'avant. Une valeur de 70 bar max est recommand�e

%% Force de freinage dans le maitre cylindre avant

Sm_f = pi*(D_f/2)^2; % surface du piston du maitre cylindre 
Fpedale_f = Pfrein_f*Sm_f % force axiale dans le maitre cylindre pour avoir la limite du glissement au niveau des pneus

%% Calcul de la pression de freinage � l'arri�re

Tb_r = R*Farriere*muarriere/2 %Couple de freinage sur une roue arri�re
Ffrein_b = R*Farriere*muarriere/(r*etha*2); % sur une roue 
Sp_b = pi*N_b*(Dp_b/2)^2; % Surface totale des pistons 
Pfrein_b = Ffrein_b/Sp_b; % pression de freinage � l'arri�re en Pa 
Pbar_b = Pfrein_b*10^-5 % pression en bar � l'arri�re. Une valeur de 70 bar max est recommand�e

%% Force de freinage dans le maitre cylindre arri�re

Sm_b = pi*(D_b/2)^2; % surface du piston du maitre cylindre arri�re 
Fpedale_b = Pfrein_b*Sm_b % force axiale dans le maitre cylindre pour avoir la limite du glissement au niveau des pneus

%% Force totale sur les deux maitres cylindres

Ftot = Fpedale_b+Fpedale_f

%% Calcul de la force � appliquer sur la p�dale

ratio = 2.5; %D�pend uniquement de la conception du p�dalier. Une valeur proche de 4 semble meilleure.
Fpilote = Ftot/ratio; %Force � appliquer par le pilote sur la p�dale en N.
% Rappel : le r�glement impose que la p�dale doit r�sister � 2000N
FPilote = Fpilote/g %Force � appliquer par le pilote sur la p�dale en kg.