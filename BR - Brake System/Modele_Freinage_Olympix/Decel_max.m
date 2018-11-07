clear all 
close all 
clc 

%% Paramètres d'entrée

% Véhicule 
mv = 235; % Masse du véhicule en kg 
mp = 80; % Masse du pilote équipé en kg 
mt = mv + mp; % Masse totale en kg 
h = 300; % Hauteur du CdG en mm 
e = 1635; % Empattement en mm 
repstatav = 0.50; % Répartition de masse statique à l'avant (cf Specsheet)

% Système de freinage 
Nd_av = 2; % Nombre de disques sur l'essieu avant 
NMC_av = 1; % Nombre de MC sur l'essieu avant 
Nroue_av = 2; % Nombre de roues sur l'essieu avant 
Np_av = 1;% Nombre de pistons utiles par étrier 
Dd_av = 230; % Diamètre moyen du disque en mm 
DMC_av = 12.7; %Diamètre du MC en mm 
Dp_av = 32; % Diamètre d'un piston d'étrier avant en mm 
Droue_av = 520.70; %Diamètre d'une roue avant en mm

Nd_ar = 2; % Nombre de disques sur l'essieu arrière
NMC_ar = 1; % Nombre de MC sur l'essieu arrière
Nroue_ar = 2; % Nombre de roues sur l'essieu arrière 
Np_ar = 1;% Nombre de pistons utiles par étrier 
Dd_ar = 230; % Diamètre moyen du disque en mm 
DMC_ar = 17.7; %Diamètre du MC en mm 
Dp_ar = 27; % Diamètre d'un piston d'étrier arrière en mm 
Droue_ar = 520.70; %Diamètre d'une roue arrière en mm

reppalonnier = 0.665; % Répartition de freinage sur l'avant au palonnier

% Autres 
g = 9.81; % Accélération de la pesanteur en m/s2 
mu = 1.6; % Coefficient longitudinal des pneus 
dmax = 1.6; % Décélération maximale souhaitée (mu-epsilon) en m/s2

%% Répartition de masse et freinage

x_av = (Nd_av*Dd_av*Np_av*(Dp_av/2)^2)/(NMC_av*(DMC_av/2)^2*Nroue_av*Droue_av); 
x_ar = (Nd_ar*Dd_ar*Np_ar*(Dp_ar/2)^2)/(NMC_ar*(DMC_ar/2)^2*Nroue_ar*Droue_ar);

repfrein = 2*reppalonnier*(x_av/(x_av+x_ar)) % Répartition de freinage avant totale

repmasse_dmax =(repstatav +dmax*h/e) % Répartition de masse dynamique à D = dmax 
repmasse_mu = (repstatav +mu*h/e) % Répartition de masse dynamique à D = mu

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

D = [0:0.001:10]; % Vecteur décélération

repdynav = (repstatav + D * h / e);

Ffrein_avmax = repdynav * mt * g * muavant; 
Ffrein_avreel = mt * repfrein * g * D; 
Ffrein_armax = mt * g * muarriere * (1-repdynav); 
Ffrein_arreel = mt * (1-repfrein) * g * D;

Dbloc_av = (muavant * repstatav) / (repfrein - muavant * h / e) % Décélération au blocage des roues avant en m/s^2
Dbloc_ar = (muarriere * (1 - repstatav)) / (1 - repfrein + muarriere * h / e) % Décélération au blocage des roues arrières en m/s^2

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