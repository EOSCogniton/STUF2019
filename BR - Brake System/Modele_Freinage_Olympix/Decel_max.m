clear all 
close all 
clc 

%% Param�tres d'entr�e

% V�hicule 
mv = 235; % Masse du v�hicule en kg 
mp = 80; % Masse du pilote �quip� en kg 
mt = mv + mp; % Masse totale en kg 
h = 300; % Hauteur du CdG en mm 
e = 1635; % Empattement en mm 
repstatav = 0.50; % R�partition de masse statique � l'avant (cf Specsheet)

% Syst�me de freinage 
Nd_av = 2; % Nombre de disques sur l'essieu avant 
NMC_av = 1; % Nombre de MC sur l'essieu avant 
Nroue_av = 2; % Nombre de roues sur l'essieu avant 
Np_av = 1;% Nombre de pistons utiles par �trier 
Dd_av = 230; % Diam�tre moyen du disque en mm 
DMC_av = 12.7; %Diam�tre du MC en mm 
Dp_av = 32; % Diam�tre d'un piston d'�trier avant en mm 
Droue_av = 520.70; %Diam�tre d'une roue avant en mm

Nd_ar = 2; % Nombre de disques sur l'essieu arri�re
NMC_ar = 1; % Nombre de MC sur l'essieu arri�re
Nroue_ar = 2; % Nombre de roues sur l'essieu arri�re 
Np_ar = 1;% Nombre de pistons utiles par �trier 
Dd_ar = 230; % Diam�tre moyen du disque en mm 
DMC_ar = 17.7; %Diam�tre du MC en mm 
Dp_ar = 27; % Diam�tre d'un piston d'�trier arri�re en mm 
Droue_ar = 520.70; %Diam�tre d'une roue arri�re en mm

reppalonnier = 0.665; % R�partition de freinage sur l'avant au palonnier

% Autres 
g = 9.81; % Acc�l�ration de la pesanteur en m/s2 
mu = 1.6; % Coefficient longitudinal des pneus 
dmax = 1.6; % D�c�l�ration maximale souhait�e (mu-epsilon) en m/s2

%% R�partition de masse et freinage

x_av = (Nd_av*Dd_av*Np_av*(Dp_av/2)^2)/(NMC_av*(DMC_av/2)^2*Nroue_av*Droue_av); 
x_ar = (Nd_ar*Dd_ar*Np_ar*(Dp_ar/2)^2)/(NMC_ar*(DMC_ar/2)^2*Nroue_ar*Droue_ar);

repfrein = 2*reppalonnier*(x_av/(x_av+x_ar)) % R�partition de freinage avant totale

repmasse_dmax =(repstatav +dmax*h/e) % R�partition de masse dynamique � D = dmax 
repmasse_mu = (repstatav +mu*h/e) % R�partition de masse dynamique � D = mu

%% Prise en compte du changement de mu lors du freinage
Favant = 2483; %en N, cf Brake_Olympix
Farriere = 607; %en N, cf Brake_Olympix

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

%% Calculs

D = [0:0.001:10]; % Vecteur d�c�l�ration

repdynav = (repstatav + D * h / e);

Ffrein_avmax = repdynav * mt * g * muavant; 
Ffrein_avreel = mt * repfrein * g * D; 
Ffrein_armax = mt * g * muarriere * (1-repdynav); 
Ffrein_arreel = mt * (1-repfrein) * g * D;

Dbloc_av = (muavant * repstatav) / (repfrein - muavant * h / e) % D�c�l�ration au blocage des roues avant en m/s^2
Dbloc_ar = (muarriere * (1 - repstatav)) / (1 - repfrein + muarriere * h / e) % D�c�l�ration au blocage des roues arri�res en m/s^2

%% Affichage

Dlim = max(Dbloc_av,Dbloc_ar);

% Curseur de dmax 
Cursorabs = [dmax dmax]; 
Cursorordav = [0,max(Ffrein_avmax)]; 
Cursorordar = [0,max(Ffrein_armax)];

% Graphes 
subplot(2,1,1) 
plot(D,Ffrein_avmax,'r',D,Ffrein_avreel,'b',Cursorabs,Cursorordav,'g', 'Linewidth',2); 
xlabel('Deceleration (g)'); 
xlim([0 Dlim]); 
Flim_av = max(Ffrein_avmax(1,find(D<=Dlim))); 
ylim([0 Flim_av]); 
ylabel('Braking force (N)'); 
legend({'Front force max = f(g)','Front force real = f(g)', 'Curseur'},'Location','southwest','Fontsize',8);

subplot(2,1,2) 
plot(D,Ffrein_armax,'r',D,Ffrein_arreel,'b',Cursorabs,Cursorordar,'g','Linewidth',2); 
xlabel('Deceleration (g)'); 
xlim([0 Dlim]); 
Flim_ar = max(Ffrein_armax(1,find(D<=Dlim))); 
ylim([0 Flim_ar]);
ylabel('Braking force (N)'); 
legend({'Rear force max = f(g)',' Rear force real = f(g)', 'Curseur'},'Location','southwest','Fontsize',8);