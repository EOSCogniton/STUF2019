clear all

%% Mécanique de freinage

%% Versionnement
     
    % v1.0 du 07/06/2016 par Clément MARIE : Première version
    % v1.1 du 29/02/2017 par Clément MARIE : Amendements
    % v1.2 du 24/05/2017 par Clément MARIE : Fin des commentaires

%% Présentation

% Ce programme est un outil d'aide au dimensionnement mécanique des freins 
% d'une voiture de course.

% Il permet d'évaluer le blocage des roues,les pressions de
% fonctionnements,la force pédale nécessaire ainsi que l'éventuelle action
% d'un limiteur de pression.
% Il permet également de vérifier que les pressions de contact des
% plaquettes ou les pressions du circuit de freins ne sont pas trop
% élevées.

%% Hypothèses
    % Pneus
        % Le coefficient d'adhérence maximal du pneu en fonction de la charge est 
        % interpolé par un polynôme de degré 2

        % Le coefficient d'adhérence de glissement du pneu en fonction de la charge 
        % est interpolé linéairement : ceci permet d'avoir une résolution rapide des
        % équations en cas de blocage de pneu

        % Les coefficients d'adhérence maximum sont interpolés linéairement
        % entre les différents points connus dans les données
        % pneus(influence de la charge et de la pression)
        % Les valeurs entre 0 et 50 lbs et entre 350 et 400 lbs sont prises
        % en continuité des valeurs connues
        
        % Les coefficients d'adéhrence de glissement sont interpolés
        % linéairement en fonction de la charge et de la pression des pneus
        % (une autre interpolation oblige à utiliser un solve pour résoudre
        % le système lors d'un blocage de roue ce qui augmente la durée de
        % traitement de quelques secondes à quelques minutes)
        
    % Véhicule
        % Le véhicule est supposé parfaitement symétrique (systèmes,
        % pressions) entre la droite et la gauche.
        
        % Le véhicule freine en ligne droite, il n'y a pas de composante
        % latérale
        
%% Fonctionnement
    % Ce programme permet de simuler les données de sortie du système de
    % freinage à partir des données d'entrées (géométrie, force appliquée,
    % présence d'un régulateur de pression,...)
    
    % Il suffit de compléter la partie "Paramètres d'entrée" et de faire
    % fonctionner le programme
    
    % Les forces sont parfois exprimées en kilogrammes dans ce programme.
    % Ce n'est pas l'unité réglementaire mais elle permet de se faire une
    % meilleure idée de la force réelle à appliquer.

%% Améliorations possibles

    % Meilleure utilisation des données pneus

    % Avoir des valeurs plus précises sur les valeurs problématiques :
    % coefficient de perte d'adhérence etatsol, correction des données pnues
    % brutes CorDataRaw, et coefficient de frottement plaquette disque etha_av
    % et etha_ar

%% Initialisation

clear all
close all
clc

%% Paramètres d'entrée

% Général
    Dtarget = 1.6; % Décélération maximale souhaitée (curseur) en m/s2

    g = 9.81; % Accélération de la pesanteur en m/s2
    pas = 0.1; % Pas de simulation en kg
    Fpedalekg = [0:pas:200]; % Force exercée sur la pédale en kg (Newton/G)

% Véhicule
    mv = 235; % Masse du véhicule en kg
    mp = 60; % Masse du pilote équipé en kg
    mt = mv+mp; % Masse totale en kg
    h = 305; % Hauteur du CdG en mm
    e = 1635; % Empattement en mm
    repstatav = 0.49; % Répartition de masse statique du véhicule
    
% Pneus
    etatsol = 1 ; % Coeff de dégradation de mu selon la nature du sol
    % (1 pour sol sec, 0.8 pour graviers, 0.6 pour sol humide,0.2 pour sol
    % mouillé,0.1 pour neige,0.05 pour verglas)
   
    
    % Facteur de correction des données pneus pour prendre en compte le
    % fait que les essais ont été fait sur un tapis très adhérent. Le
    % coefficient de 2/3 est celui conseillé par Hoosier sur ses essais.
    CorRawData = 2/3;
    
   Ppneu_av = 0.8; % Pression des pneus avants en bar
   Ppneu_ar =0.8; % Pression des pneus arrières en bar
   
   
   % Données pneus Olympix : Hoosier 20.5x7.0-13 R25B
   
   % Ces tableaux ont pour lignes les charges (50,150,250,350 lbs), pour
   % colonnes les pressions pneus (8,10,12,14 psi)
    mumax =[NaN 8 10 12 14;...
        50 3.85 3.5 3.25 3.1;...
        150 3.05 2.75 2.65 2.5;...
        250 2.9 2.5 2.4 2.25;...
        350 2.7 2.35 2.3 2.15]; % Coefficient longitudinal maximum des pneus en fonction de la charge et de la pression des pneus
    mubloc = [NaN 8 10 12 14;...
        50 3.3 3.25 3.05 2.85;...
        150 2.8 2.6 2.45 2.4;...
        250 2.65 2.35 2.3 2.15;...
        350 2.55 2.3 2.15 2.1]; % Coeffcient longitudinal des pneus au blocage des roues
    

% Système de freinage

    % Géométrie avant
        Nd_av = 2; % Nombre de disques sur l'essieu avant
        NMC_av = 1; % Nombre de MC sur l'essieu avant
        Nroue_av = 2; % Nombre de roues sur l'essieu avant
        Np_av = 1; % Nombre de pistons utiles par étrier avant
        Dd_av = 230; % Diamètre moyen du disque en mm
        DMC_av = 12.7; % Diamètre du MC en mm
        Dp_av = 32; % Diamètre d'un piston en mm
        Droue_av = 520.7; % Diamètre d'une roue avant en mm

        Lplaqu_av = 54; % Longueur de plaquette avant en mm
        lplaqu_av = 24; % Largeur de plaquette avant en mm
        Ld_av = 25; % Largeur de piste de disque avant en mm
    
    % Géométrie Arrière
        Nd_ar = 2; % Nombre de disques sur l'essieu arrière
        NMC_ar = 1; % Nombre de MC sur l'essieu arrière
        Nroue_ar = 2; % Nombre de roues sur l'essieu arrière
        Np_ar = 1; % Nombre de pistons utiles par étrier arrière
        Dd_ar = 230; % Diamètre moyen du disque en mm
        DMC_ar = 12.7; %Diamètre du MC en mm
        Dp_ar = 27; % Diamètre d'un piston en mm
        Droue_ar = 520.7; % Diamètre d'une roue arrière en mm

        Lplaqu_ar = 38; % Longueur de plaquette arrière en mm
        lplaqu_ar = 30; % Largeur de plaquette arrière en mm
        Ld_ar = 25; % Largeur de piste de disque arrière en mm
    
    % Pédalier
        reppalonnier = 0.71; % Répartition de freinage sur l'avant au palonnier (entre 34% et 66%)
        ratiopedale = 2.5; % Ratio de pédale (2.5 pour Olympix v2, 1.6 pour Olympix v1)
    
    % Coefficient de friction
        etha_av = 0.4; % coefficient de friction des plaquettes avant (OdG : 0.4-0.5)
        etha_ar = 0.4; % coefficient de friction des plaquettes arrière (OdG : 0.4-0.5)

    % Limiteur de pression
        Plim_ar = 8; % Pression de déclenchement limiteur en bar (entre 5 et 35 par pas de 0.5 pour le limiteur Béringer)
        coefflim_ar = 1; % Coefficient de gain de pression au dessus de la limite (1 pour pas de limiteur)(chez Béringer 0.38, 0 ou -0.2)
    
    % Limites
        Pemax_av = 100; % Pression maximum étrier avant en bar
        Pdmax_av = 100; % Pression maximum durite avant en bar
        PMCmax_av = 100; % Pression maximum MC avant en bar
        
        Pemax_ar = 100; % Pression maximum étrier arrière en bar
        Pdmax_ar = 100; % Pression maximum durite arrière en bar
        PMCmax_ar = 100; % Pression maximum MC arrière en bar
        
        Pplaqumax_av = 12; % Pression de contact maximum des plaquettes en MPa (valeur commune fixe sans autre indication)
        Pplaqumax_ar = 12; % Pression de contact maximum des plaquettes en MPa
	
%% Calculs


% Interpolation des coefficients d'adhérence longitudinaux
    p1 = 0.1; 
    C = etatsol*CorRawData;
    Ppsi_av = p1*round(Ppneu_av*14.5/p1); % Conversion en PSI et arrondi de la Pavant
    Ppsi_ar = p1*round(Ppneu_ar*14.5/p1); % Conversion en PSI et arrondi de la Parrière
    
    % mumax
    psi = [mumax(1,2):p1:mumax(1,end)]; % Vecteur détaillé des pressions en psi
    
    for i=1:size(mumax,1)-1 % Pour toutes les charges
        mumaxpsi=interp1(mumax(1,2:end),mumax(i+1,2:end),psi); % Interpolation linaire de mumax à charge donnée par rapport à la pression
        mumaxpsi_av(1,i) = mumaxpsi(1,round(1+(Ppsi_av-mumax(1,2))/p1)); % mumax à charge donnée à la pression pneu avant
        mumaxpsi_ar(1,i) = mumaxpsi(1,round(1+(Ppsi_ar-mumax(1,2))/p1)); % mumax à charge donnée à la pression pneu arrière
    end
    
    p2 =0.1;
    
    charge=[mumax(2,1):p2:mumax(end,1)]; % Vecteur des charges entre 50 et 350 lbs
    mumaxNew_av = interp1(mumax(2:end,1),C*mumaxpsi_av,charge); % mumax avant pour les charges correspondantes
    mumaxNew_ar = interp1(mumax(2:end,1),C*mumaxpsi_ar,charge); % mumax arrière pour les charges correspondantes
    
    charge2 = [0:p2:mumax(2,1)-p2]; % Vecteur des charges entre 0 et 49.9 lbs
    mumaxNew_av2 = polyval(polyfit([50 150],C*mumaxpsi_av(1,1:2),1),charge2); % mumax avant pour les charges correspondantes
    mumaxNew_ar2 = polyval(polyfit([50 150],C*mumaxpsi_ar(1,1:2),1),charge2); % mumax arrière pour les charges correspondantes
    
    charge3 = [mumax(end,1):p2:400]; % Vecteur des charges entre 350.1 et 400 lbs
    mumaxNew_av3 = polyval(polyfit([250 350],C*mumaxpsi_av(1,end-1:end),1),charge3); % mumax avant pour les charges correspondantes
    mumaxNew_ar3 = polyval(polyfit([250 350],C*mumaxpsi_ar(1,end-1:end),1),charge3); % mumax arrière pour les charges correspondantes
    
    
    charge =[charge2 charge charge3]; % Concaténations
    mumaxNew_av=[mumaxNew_av2 mumaxNew_av mumaxNew_av3];
    mumaxNew_ar=[mumaxNew_ar2 mumaxNew_ar mumaxNew_ar3];
    
    chargeini = charge(1,1);
    
    % mubloc   
    psi = [mubloc(1,2):p1:mubloc(1,end)]; % Vecteur des pressions en psi
    
    for i=1:size(mumax,1)-1 % Pour toutes les charges
        mublocpsi=interp1(mubloc(1,2:end),mubloc(i+1,2:end),psi); % Interpolation linaire de mubloc à charge donnée par rapport à la pression
        mublocpsi_av(1,i) = mublocpsi(1,round(1+(Ppsi_av-mubloc(1,2))/p1)); % mubloc à charge donnée à la pression pneu avant
        mublocpsi_ar(1,i) = mublocpsi(1,round(1+(Ppsi_ar-mubloc(1,2))/p1)); % mubloc à charge donnée à la pression pneu arrière
    end 
    Cmubloc_av=polyfit(mubloc(2:end,1)',C*mublocpsi_av,1); % Coefficients d'inperloation linéaire avant
    Cmubloc_ar=polyfit(mubloc(2:end,1)',C*mublocpsi_ar,1); % Coefficients d'inperloation linéaire arrière
    
    mublocNew_av = polyval(Cmubloc_av,charge); % Interpolation linéaire avant
    mublocNew_ar = polyval(Cmubloc_ar,charge); % Interpolation linéaire arrière
   
% Allocation mémoire
    N=size(Fpedalekg,2);

    Fpedale=zeros(1,N);
    FMC_av=zeros(1,N);
    FMC_ar=zeros(1,N);
    Pin_av=zeros(1,N);
    Pin_ar=zeros(1,N);
    Pout_av=zeros(1,N);
    Pout_ar=zeros(1,N);
    Fpiston_av=zeros(1,N);
    Fpiston_ar=zeros(1,N);
    Ffrein_av=zeros(1,N);
    Ffrein_ar=zeros(1,N);
    repfrein=zeros(1,N);
    D=zeros(1,N);
    repdynav=zeros(1,N);
    Ffrein_avmax=zeros(1,N);
    Ffrein_armax=zeros(1,N);
    
    bloctrig_av=1;
    bloctrig_ar=1;
    
    Fbloc_av=Inf;
    Fbloc_ar=Inf;
    Dbloc_av=Inf;
    Dbloc_ar=Inf;
    i_av = N;
    i_ar =N;
    
% Calculs
    Fpedale = Fpedalekg*g; % Force exercée sur la pédale en N

    for i=1:size(Fpedale,2) % Pour chaque valeur d'appui pédale

        FMC_av(i)=Fpedale(i)*reppalonnier*ratiopedale; % Force MC avant en N
        FMC_ar(i) = Fpedale(i)*(1-reppalonnier)*ratiopedale; % Force MC arrière en N

        Pin_av(i) = FMC_av(i)*10/(NMC_av*(DMC_av/2)^2*pi); % Pression entrée circuit avant en bar
        Pin_ar(i) = FMC_ar(i)*10/(NMC_ar*(DMC_ar/2)^2*pi); % Pression entrée limiteur arrière en bar

        Pout_av(i) = Pin_av(i); % Pression sortie circuit avant en bar

        % Pression sortie limiteur arrière en bar
        if Pin_ar(i) <= Plim_ar % Si la pression d'entrée est inférieure à la pression de limitation, Pout = Pin
            Pout_ar(i)=Pin_ar(i);
        else
            Pout_ar(i) = Plim_ar+coefflim_ar*(Pin_ar(i)-Plim_ar); % Sinon, limitation pression
        end

        Fpiston_av(i) = (Pout_av(i)*Np_av*pi*(Dp_av/2)^2)/10; % Force pistons avant utiles d'un étrier en N
        Fpiston_ar(i)  = (Pout_ar(i)*Np_ar*pi*(Dp_ar/2)^2)/10; % Force pistons arrière utiles d'un étrier en N

        Ffrein_av(i) = Fpiston_av(i)*Nd_av*2*Dd_av*etha_av/Droue_av; % Force de freinage de l'essieu avant en N
        Ffrein_ar(i) = Fpiston_ar(i)*Nd_ar*2*Dd_ar*etha_ar/Droue_ar; % Force de freinage de l'essieu arrière en N
       
        D(i) = (Ffrein_av(i)+Ffrein_ar(i))/(mt*g); % Déccélération véhicule en G
        repdynav(i)= min(1,(repstatav +D(i)*h/e)); % Répartition de masse dynamique sur l'avant du véhicule
        
        charge_av(i) = p2*round(repdynav(i)*mt/(Nroue_av*0.45*p2)); % charge sur un pneu avant 
        charge_ar(i) = p2*round((1-repdynav(i))*mt/(Nroue_ar*0.45*p2)); % charge sur unpneu arrière
        
        mu_av(i) = mumaxNew_av(1,round(1+(charge_av(i)-chargeini)/p2)); % Coefficient d'adhérence avant
        mu_ar(i) = mumaxNew_ar(1,round(1+(charge_ar(i)-chargeini)/p2)); % Coefficient d'adhérence arrière

        Ffrein_avmax(i) = repdynav(i)*mt*g*mu_av(i); % Force de freinage maximum avant
        Ffrein_armax(i) = mt*g*mu_ar(i)*(1-repdynav(i)); % Force de freinage maximum arrière   
        
        % Blocage de l'essieu avant
        if Ffrein_avmax(i)<=Ffrein_av(i) && Ffrein_armax(i)>Ffrein_ar(i)
            % Marqueur du point de blocage avant
            if bloctrig_av == 1 
                Dbloc_av= D(i-1); 
                Fbloc_av=Fpedalekg(i-1);
                i_av=i-1;
                bloctrig_av = 0;
            end  
             
            s = repstatav;
            Far = Ffrein_ar(i);
            a = Cmubloc_av(1,1);
            b = Cmubloc_av(1,2);
            N = Nroue_av*0.45;
            
            % Coefficients equation second degré
            alpha = a*mt*h^2/(N*e^2);
            beta = ((2*a*mt*s*h)/(N*e))+(b*h/e)-1;
            gamma = (Far/(mt*g))+(a*mt*s^2/N)+b*s;
            delta= beta^2-4*alpha*gamma;
            
            % Grandeurs en blocage
            D(i) = (-beta-sqrt(delta))/(2*alpha);
            repdynav(i) = s + h*D(i)/e;
            charge_av(i) = p2*round(mt*repdynav(i)/(N*p2));
            mu_av(i) = a*charge_av(i)+b;
            Ffrein_av(i) = mu_av(i)*charge_av(i)*N*g;
            Ffrein_avmax(i) = Ffrein_av(i);
           
       % Blocage de l'essieu arrière
        elseif Ffrein_avmax(i)>Ffrein_av(i) && Ffrein_armax(i)<=Ffrein_ar(i)
            % Marqueur du point de blocage arrière
           if bloctrig_ar == 1 
                Dbloc_ar= D(i-1); 
                Fbloc_ar=Fpedalekg(i-1);
                i_ar = i-1;                 
                bloctrig_ar = 0;
           end
            
            s = 1-repstatav;
            Fav = Ffrein_av(i);
            a = Cmubloc_ar(1,1);
            b = Cmubloc_ar(1,2);
            N = Nroue_ar*0.45;
            
            % Coefficients equation second degré
            alpha = a*mt*h^2/(N*e^2);
            beta = (-(2*a*mt*s*h)/(N*e))-(b*h/e)-1;
            gamma = (Fav/(mt*g))+(a*mt*s^2/N)+b*s;
            delta= beta^2-4*alpha*gamma;
            
            % Grandeurs en blocage
            D(i) = (-beta-sqrt(delta))/(2*alpha);
            repdynav(i) = 1-s + h*D(i)/e;
            charge_ar(i) = p2*round(mt*(1-repdynav(i))/(N*p2));
            mu_ar(i) = a*charge_ar(i)+b;
            Ffrein_ar(i) = mu_ar(i)*charge_ar(i)*N*g;
            Ffrein_armax(i) = Ffrein_ar(i);
        
       % Blocage des deux essieux
        elseif Ffrein_avmax(i)<=Ffrein_av(i) && Ffrein_armax(i)<=Ffrein_ar(i)
            % Marqueur des points de blocages
            if bloctrig_ar == 1 
                Dbloc_ar= D(i-1); 
                Fbloc_ar=Fpedalekg(i-1);
                i_ar = i-1;                 
                bloctrig_ar = 0;
            end
             if bloctrig_av == 1 
                Dbloc_av= D(i-1); 
                Fbloc_av=Fpedalekg(i-1);
                i_av=i-1;
                bloctrig_av = 0;
             end
             
            s = repstatav;
            a1 = Cmubloc_av(1,1);
            b1 = Cmubloc_av(1,2);
            N1 = Nroue_av*0.45;
            a2=Cmubloc_ar(1,1);
            b2=Cmubloc_ar(1,2);
            N2=Nroue_ar*0.45;
            
            % Coefficients equation second degré
            alpha = (mt*h^2/e^2)*(a1/N1+a2/N2);
            beta = (2*mt*h/e)*((a1*s/N1)-(a2*(1-s)/N2))+(h/e)*(b1-b2)-1;
            gamma = b1*s+b2*(1-s)+mt*((a1*s^2/N1)+(a2*(1-s)^2/N2));
            delta= beta^2-4*alpha*gamma;
            
            % Grandeurs en blocage
            D(i) = (-beta-sqrt(delta))/(2*alpha);
            repdynav(i) = s + h*D(i)/e;
            charge_av(i) = p2*round(mt*repdynav(i)/(N1*p2));
            charge_ar(i) = p2*round(mt*(1-repdynav(i))/(N2*p2));
            mu_av(i) = a1*charge_av(i)+b1;
            mu_ar(i) = a2*charge_ar(i)+b2;
            Ffrein_av(i) = mu_av(i)*charge_av(i)*N1*g;
            Ffrein_ar(i) = mu_ar(i)*charge_ar(i)*N2*g;
            Ffrein_armax(i) = Ffrein_ar(i);
            Ffrein_avmax(i) = Ffrein_av(i);
        end
        
        % Répartition de freinage
         if i~=1
            repfrein(i) = Ffrein_av(i)/(Ffrein_av(i)+Ffrein_ar(i));
        end
      
    end

Dbloc = min(Dbloc_av, Dbloc_ar); % Décélération de premier blocage de roues
ibloc = min(i_av,i_ar); % Indice de premier blocage de roue
mumaxmoy = (mumaxNew_av(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45))))+...
    mumaxNew_ar(1,find(charge == p2*round(mt/(2*Nroue_ar*p2*0.45)))))/2; % Moyenne mumax avant/arrière
mublocmoy = (mublocNew_av(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45))))+...
    mublocNew_ar(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45)))))/2; % Moyenne mubloc avant/arrière

Dmax = max(D(1,1:ibloc));
repfrein(1) = repfrein(2);
repmasse_Dtarget=(repstatav +Dtarget*h/e); % Répartition de masse dynamique à D=Dtarget
repmasse_Dmax = (repstatav +Dmax*h/e); % Répartition de masse dynamique à D =Dmax

itarget = find(0.05*round(D(1,1:ibloc)/0.05)==Dtarget); % Indice correspondant à la décélération visée (pour curseur)
Ftarget = NaN;
if ~isempty(itarget)
    Ftarget = Fpedalekg(1,itarget(1,1)); % Force pédale correspondante
end 

Ffrein_avopt=D(1,1:ibloc).*repdynav(1,1:ibloc)*mt*g; % Force de freinage avant optimale (répartition frein = répartition charge)
Ffrein_aropt=D(1,1:ibloc).*(1-repdynav(1,1:ibloc))*mt*g; % Force de freinage arrière optimale (répartition frein = répartition charge)

Pmax_av = min(min(Pemax_av,PMCmax_av),Pdmax_av); % Minimum des pressions circuit avant
Pmax_ar = min(min(Pemax_ar,PMCmax_ar),Pdmax_ar); % Minimum des pressions circuit arrière

Pplaqu_av = Fpiston_av/(Lplaqu_av*min(lplaqu_av,Ld_av)); % Pression sur les plaquettes avant
Pplaqu_ar = Fpiston_ar/(Lplaqu_ar*min(lplaqu_ar,Ld_ar)); % Pression sur les plaquettes arrière

%% Affichage résultats

% Données console
fprintf('Mecanical Brake Balance: %.2f\n\n',repfrein(1));
fprintf('Target deceleration: %.2f G\n',Dtarget);
fprintf('Dynamic Weight Balance at Target deceleration:%.2f\n\n',repmasse_Dtarget);
fprintf('Maximum deceleration: %.2f G\n',Dmax);
fprintf('Dynamic Weight Balance at Maximum deceleration:%.2f\n\n',repmasse_Dmax);
fprintf('Brake pedale force to lock front wheels: %.1f kg\n',Fbloc_av);
fprintf('Brake pedal force to lock rear wheels: %.1f kg\n',Fbloc_ar);

% Graphes

% Décélération en fonction de la force pédale
    figure('Name','Car deceleration depending on pedal force');

    Dtargetord = [Dtarget Dtarget];
    Fpedalekgabs = [Fpedalekg(1,1) Fpedalekg(1,end)];
    
    plot(Fpedalekg,D,'b',Fpedalekgabs,Dtargetord,'g--',Fpedalekg(1,i_av),D(1,i_av),'rx',...
        Fpedalekg(1,i_ar),D(1,i_ar),'kx');
    
    xlabel('Pedal force (kg)');
    ylabel('Deceleration(g))');
    legend({'Deceleration','Target deceleration',...
        'Front wheels locking','Rear wheels locking'},'Location','southeast','Fontsize',8);
    
% Mu = f(Fpedale) et Far= f(Fav)
    figure('Name','Tire longitudinal coefficient and Braking balance comparison');
    
    subplot(211);
    plot(Fpedalekg,mu_av,'b',Fpedalekg,mu_ar,'r',Fpedalekgabs,[mumaxmoy mumaxmoy],'g--',...
        Fpedalekgabs,[mublocmoy mublocmoy],'k--');
    
    xlabel('Pedal force (kg)');
    ylabel('Tire longitudinal coefficient');
    legend({'Front mu','Rear mu',...
        'Mean weight maximum mu','Mean weight blocked wheels mu'},'Location','northwest','Fontsize',8);
     
    subplot(212);
    plot(Ffrein_av(1,1:ibloc),Ffrein_ar(1,1:ibloc),'b',Ffrein_avopt,Ffrein_aropt,'r');
    
    xlabel('Front brake force (N))');
    ylabel('Rear brake force (N)');
    legend({'Real braking balance','Optimum braking balance'},'Location','southeast','Fontsize',8);

% Fonction de la force pédale
    if ~isempty(Fbloc_av) && ~isempty(Fbloc_ar)
        Flim = max(Fbloc_av,Fbloc_ar)*1.2;
    else
        Flim = 1.2*Fpedalekg(1,find(D==max(D)));
    end
    Ftargetabs=[Ftarget Ftarget];

    figure('Name','Braking forces depending on brake pedal force');

    Flim_av = max(Ffrein_avmax(1,find(Fpedalekg<=Flim)));
    Flim_ar = max(Ffrein_armax(1,find(Fpedalekg<=Flim)));

    subplot(211);
    plot(Fpedalekg,Ffrein_avmax,'r',Fpedalekg,Ffrein_av,'b',Ftargetabs,[0 max(Ffrein_avmax)],'g--'); 
    xlabel('Pedal force (kg)');
    xlim([0 Flim]);
    ylim([0 Flim_av]);
    ylabel('Braking force(N)');
    legend({'Maximum front braking force',' Front braking force', 'Target pedal force'},'Location','southeast','Fontsize',8);

    subplot(212);
    plot(Fpedalekg,Ffrein_armax,'r',Fpedalekg,Ffrein_ar,'b',Ftargetabs,[0 max(Ffrein_armax)],'g--');
    xlabel('Pedal force (kg)');
    xlim([0 Flim]);
    ylim([0 Flim_ar]);
    ylabel('Braking force (N)');
    legend({'Maximum rear braking force',' Rear braking force', 'Target pedal force'},'Location','southeast','Fontsize',8);

    figure('Name','Balances and pressures depending on brake pedal force');

    subplot(221);
    plot(Fpedalekg,repdynav,'r',Fpedalekg,repfrein,'b',Ftargetabs,[0 1],'g--');
    xlabel('Pedal force (kg)');
    xlim([0 Flim]);
    ylim([0 1]);
    ylabel('Weight and braking balances');
    legend({'Front dynamic weight balance','Front braking balance', 'Target pedal force'},'Location','southwest','Fontsize',8);

    subplot(222);
    Pmax1 = max(max(Pout_av),Pmax_av);
    plot(Fpedalekg,Pout_av,'b',Fpedalekgabs,[Pmax_av Pmax_av],'r--',Ftargetabs,[0 Pmax1],'g--');
    xlabel('Pedal force (kg)');
    ylabel('Braking pressure (bar)');
    legend({'Front braking pressure','Front maximum braking pressure',...
        'Target deceleration cursor'},'Location','northwest','Fontsize',8);

    subplot(223);
    Pmax2 = max(max(Pin_ar),Pmax_ar);
    plot(Fpedalekg,Pin_ar,'b',Fpedalekg,Pout_ar,'k',Fpedalekgabs,[Pmax_ar Pmax_ar],'r--',Ftargetabs,[0 Pmax2],'g--');
    xlabel('Pedal force (kg)');
    ylabel('Braking pressure(bar)');
    legend({'Rear In braking pressure','Rear Out braking pressure','Rear maximum braking pressure',...
        'Target pedal force'},'Location','northwest','Fontsize',8);

    subplot(224);
    Pplaqumax = max(max(max(Pplaqu_ar),max(Pplaqu_av)),max(Pplaqumax_av,Pplaqumax_ar));
    
    plot(Fpedalekg,Pplaqu_av,'b',Fpedalekgabs,[Pplaqumax_av Pplaqumax_av],'b--',...
        Fpedalekg,Pplaqu_ar,'r',Fpedalekgabs,[Pplaqumax_ar Pplaqumax_ar],'r--',Ftargetabs,[0 Pplaqumax],'g--');
    xlabel('Pedal force (kg)');
    ylabel('Braking pads pressure (MPa)');
    ylim = [0 1];
    legend({'Front braking pads pressure','Front maximum braking pads pressure',...
        'Rear braking pads pressure','Rear maximum braking pads pressure','Target pedal force'},'Location','northwest','Fontsize',8);

% Fonction de la décélération

    Dtargetabs = [Dtarget Dtarget];
    Dabs = [D(1,1) D(1,ibloc)];
    Dbij=D(1,1:ibloc);

    figure('Name','Braking forces depending on car deceleration');

    subplot(211);
    plot(Dbij,Ffrein_avmax(1,1:ibloc),'r',Dbij,Ffrein_av(1,1:ibloc),'b',Dtargetabs,[0 max(Ffrein_avmax(1,1:ibloc))],'g--'); 
    xlabel('Deceleration (g)');
    ylabel('Braking force(N)');
    legend({'Maximum front braking force',' Front braking force', 'Target deceleration'},'Location','southeast','Fontsize',8);

    subplot(212);
    plot(Dbij,Ffrein_armax(1,1:ibloc),'r',Dbij,Ffrein_ar(1,1:ibloc),'b',Dtargetabs,[0 max(Ffrein_armax(1,1:ibloc))],'g--');
    xlabel('Deceleration (g)');
    ylabel('Braking force (N)');
    legend({'Maximum rear braking force',' Rear braking force', 'Target deceleration'},'Location','southeast','Fontsize',8);

    figure('Name','Balances and pressures depending on brake pedal force');

    subplot(221);
    plot(Dbij,repdynav(1,1:ibloc),'r',Dbij,repfrein(1,1:ibloc),'b',Dtargetabs,[0 1],'g--');
    xlabel('Deceleration (g)');
    ylabel('Weight and braking balances');
    legend({'Front dynamic weight balance','Front braking balance', 'Target deceleration'},'Location','southwest','Fontsize',8);

    subplot(222);
    Pmax1 = max(max(Pout_av(1,1:ibloc)),Pmax_av);
    plot(Dbij,Pout_av(1,1:ibloc),'b',Dabs,[Pmax_av Pmax_av],'r--',Dtargetabs,[0 Pmax1],'g--');
    xlabel('Deceleration (g)');
    ylabel('Braking pressure (bar)');
    legend({'Front braking pressure','Front maximum braking pressure',...
        'Target deceleration'},'Location','northwest','Fontsize',8);

    subplot(223);
    Pmax2 = max(max(Pin_ar(1,1:ibloc)),Pmax_ar);
    plot(Dbij,Pin_ar(1,1:ibloc),'b',Dbij,Pout_ar(1,1:ibloc),'k',Dabs,[Pmax_ar Pmax_ar],'r--',Dtargetabs,[0 Pmax2],'g--');
    xlabel('Deceleration (g)');
    ylabel('Braking pressure(bar)');
    legend({'Rear In braking pressure','Rear Out braking pressure','Rear maximum braking pressure',...
        'Target deceleration'},'Location','northwest','Fontsize',8);

    subplot(224);
    Pplaqumax = max(max(max(Pplaqu_ar(1,1:ibloc)),max(Pplaqu_av(1,1:ibloc))),max(Pplaqumax_av,Pplaqumax_ar));
    
    plot(Dbij,Pplaqu_av(1,1:ibloc),'b',Dabs,[Pplaqumax_av Pplaqumax_av],'b--',...
        Dbij,Pplaqu_ar(1,1:ibloc),'r',Dabs,[Pplaqumax_ar Pplaqumax_ar],'r--',Dtargetabs,[0 Pplaqumax],'g--');
    xlabel('Deceleration (g))');
    ylabel('Braking pads pressure (MPa)');
    ylim = [0 15];
    legend({'Front braking pads pressure','Front maximum braking pads pressure',...
        'Rear braking pads pressure','Rear maximum braking pads pressure','Target deceleration'},'Location','northwest','Fontsize',8);
    
    
    
%     Partie utilisée pour les beaux graphes du document pour l'Angleterre
%     => courbes plus épaisses et graphes plus jolis
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
%     
%     figure('Name','Car deceleration depending on pedal force');
%     
%     plot(Fpedalekg(1,1:ibloc*1.2),D(1,1:ibloc*1.2),'r',Fpedalekg(1,i_av),D(1,i_av),'gx',...
%         Fpedalekg(1,i_ar),D(1,i_ar),'kx','LineWidth',2,'MarkerSIze',10);
%     
%     xlabel('Pedal force (kg)','Fontsize',12);
%     ylabel('Deceleration(g))','Fontsize',12);
% %     xlim=[0 max(Fbloc_av,Fbloc_ar)*1.2];
% 
%     legend({'Deceleration',...
%         'Front wheels locking','Rear wheels locking'},'Location','southeast','Fontsize',12);
%     
%     figure
%     subplot(121)
%     plot(Ffrein_av(1,1:ibloc),Ffrein_ar(1,1:ibloc),'b',Ffrein_avopt,Ffrein_aropt,'r','LineWidth',2);
%     
%     xlabel('Front braking force (N))','Fontsize',12);
%     ylabel('Rear braking force (N)','Fontsize',12);
%     legend({'Real braking balance','Optimum braking balance'},'Location','southeast','Fontsize',12);
%     
%     subplot(122);
%     plot(Dbij,repdynav(1,1:ibloc),'r',Dbij,repfrein(1,1:ibloc),'b','LineWidth',2);
%     xlabel('Deceleration (g)','Fontsize',12);
%     ylabel('Weight and braking balances','Fontsize',12);
%     legend({'Front dynamic weight balance','Front braking balance'},'Location','southeast','Fontsize',12);
%     
%     
%     figure('Name','Braking forces depending on brake pedal force');
% 
%     Flim_av = max(Ffrein_avmax(1,find(Fpedalekg<=Flim)));
%     Flim_ar = max(Ffrein_armax(1,find(Fpedalekg<=Flim)));
% 
%     subplot(121);
%     plot(Fpedalekg(1,1:ibloc*1.2),Ffrein_av(1,1:ibloc*1.2),'b',Fpedalekg(1,1:ibloc*1.2),Ffrein_avmax(1,1:ibloc*1.2),'r','LineWidth',2); 
%     xlabel('Pedal force (kg)','Fontsize',12);
%    
%     ylabel('Braking force(N)','Fontsize',12);
%     legend({' Front braking force','Maximum front braking force'},'Location','southeast','Fontsize',12);
% 
%     subplot(122);
%     plot(Fpedalekg(1,1:ibloc*1.2),Ffrein_ar(1,1:ibloc*1.2),'b',Fpedalekg(1,1:ibloc*1.2),Ffrein_armax(1,1:ibloc*1.2),'r','LineWidth',2);
%     xlabel('Pedal force (kg)','Fontsize',12);
% 
%     ylabel('Braking force (N)','Fontsize',12);
%     legend({' Rear braking force','Maximum rear braking force'},'Location','northeast','Fontsize',12);
%     
%     
%     
%      figure
%     Pmax2 = max(max(Pin_ar),Pmax_ar);
%     plot(Fpedalekg,Pin_ar,'b',Fpedalekg,Pout_ar,'k',Fpedalekgabs,[Pmax_ar Pmax_ar],'r--','LineWidth',2);
%     xlabel('Pedal force (kg)','Fontsize',12);
%     ylabel('Braking pressure(bar)','Fontsize',12);
%     legend({'Rear In braking pressure','Rear Out braking pressure','Rear maximum braking pressure'...
%         },'Location','northwest','Fontsize',12);   