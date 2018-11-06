clear all

%% M�canique de freinage

%% Versionnement
     
    % v1.0 du 07/06/2016 par Cl�ment MARIE : Premi�re version
    % v1.1 du 29/02/2017 par Cl�ment MARIE : Amendements
    % v1.2 du 24/05/2017 par Cl�ment MARIE : Fin des commentaires

%% Pr�sentation

% Ce programme est un outil d'aide au dimensionnement m�canique des freins 
% d'une voiture de course.

% Il permet d'�valuer le blocage des roues,les pressions de
% fonctionnements,la force p�dale n�cessaire ainsi que l'�ventuelle action
% d'un limiteur de pression.
% Il permet �galement de v�rifier que les pressions de contact des
% plaquettes ou les pressions du circuit de freins ne sont pas trop
% �lev�es.

%% Hypoth�ses
    % Pneus
        % Le coefficient d'adh�rence maximal du pneu en fonction de la charge est 
        % interpol� par un polyn�me de degr� 2

        % Le coefficient d'adh�rence de glissement du pneu en fonction de la charge 
        % est interpol� lin�airement : ceci permet d'avoir une r�solution rapide des
        % �quations en cas de blocage de pneu

        % Les coefficients d'adh�rence maximum sont interpol�s lin�airement
        % entre les diff�rents points connus dans les donn�es
        % pneus(influence de la charge et de la pression)
        % Les valeurs entre 0 et 50 lbs et entre 350 et 400 lbs sont prises
        % en continuit� des valeurs connues
        
        % Les coefficients d'ad�hrence de glissement sont interpol�s
        % lin�airement en fonction de la charge et de la pression des pneus
        % (une autre interpolation oblige � utiliser un solve pour r�soudre
        % le syst�me lors d'un blocage de roue ce qui augmente la dur�e de
        % traitement de quelques secondes � quelques minutes)
        
    % V�hicule
        % Le v�hicule est suppos� parfaitement sym�trique (syst�mes,
        % pressions) entre la droite et la gauche.
        
        % Le v�hicule freine en ligne droite, il n'y a pas de composante
        % lat�rale
        
%% Fonctionnement
    % Ce programme permet de simuler les donn�es de sortie du syst�me de
    % freinage � partir des donn�es d'entr�es (g�om�trie, force appliqu�e,
    % pr�sence d'un r�gulateur de pression,...)
    
    % Il suffit de compl�ter la partie "Param�tres d'entr�e" et de faire
    % fonctionner le programme
    
    % Les forces sont parfois exprim�es en kilogrammes dans ce programme.
    % Ce n'est pas l'unit� r�glementaire mais elle permet de se faire une
    % meilleure id�e de la force r�elle � appliquer.

%% Am�liorations possibles

    % Meilleure utilisation des donn�es pneus

    % Avoir des valeurs plus pr�cises sur les valeurs probl�matiques :
    % coefficient de perte d'adh�rence etatsol, correction des donn�es pnues
    % brutes CorDataRaw, et coefficient de frottement plaquette disque etha_av
    % et etha_ar

%% Initialisation

clear all
close all
clc

%% Param�tres d'entr�e

% G�n�ral
    Dtarget = 1.6; % D�c�l�ration maximale souhait�e (curseur) en m/s2

    g = 9.81; % Acc�l�ration de la pesanteur en m/s2
    pas = 0.1; % Pas de simulation en kg
    Fpedalekg = [0:pas:200]; % Force exerc�e sur la p�dale en kg (Newton/G)

% V�hicule
    mv = 235; % Masse du v�hicule en kg
    mp = 60; % Masse du pilote �quip� en kg
    mt = mv+mp; % Masse totale en kg
    h = 305; % Hauteur du CdG en mm
    e = 1635; % Empattement en mm
    repstatav = 0.49; % R�partition de masse statique du v�hicule
    
% Pneus
    etatsol = 1 ; % Coeff de d�gradation de mu selon la nature du sol
    % (1 pour sol sec, 0.8 pour graviers, 0.6 pour sol humide,0.2 pour sol
    % mouill�,0.1 pour neige,0.05 pour verglas)
   
    
    % Facteur de correction des donn�es pneus pour prendre en compte le
    % fait que les essais ont �t� fait sur un tapis tr�s adh�rent. Le
    % coefficient de 2/3 est celui conseill� par Hoosier sur ses essais.
    CorRawData = 2/3;
    
   Ppneu_av = 0.8; % Pression des pneus avants en bar
   Ppneu_ar =0.8; % Pression des pneus arri�res en bar
   
   
   % Donn�es pneus Olympix : Hoosier 20.5x7.0-13 R25B
   
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
    

% Syst�me de freinage

    % G�om�trie avant
        Nd_av = 2; % Nombre de disques sur l'essieu avant
        NMC_av = 1; % Nombre de MC sur l'essieu avant
        Nroue_av = 2; % Nombre de roues sur l'essieu avant
        Np_av = 1; % Nombre de pistons utiles par �trier avant
        Dd_av = 230; % Diam�tre moyen du disque en mm
        DMC_av = 12.7; % Diam�tre du MC en mm
        Dp_av = 32; % Diam�tre d'un piston en mm
        Droue_av = 520.7; % Diam�tre d'une roue avant en mm

        Lplaqu_av = 54; % Longueur de plaquette avant en mm
        lplaqu_av = 24; % Largeur de plaquette avant en mm
        Ld_av = 25; % Largeur de piste de disque avant en mm
    
    % G�om�trie Arri�re
        Nd_ar = 2; % Nombre de disques sur l'essieu arri�re
        NMC_ar = 1; % Nombre de MC sur l'essieu arri�re
        Nroue_ar = 2; % Nombre de roues sur l'essieu arri�re
        Np_ar = 1; % Nombre de pistons utiles par �trier arri�re
        Dd_ar = 230; % Diam�tre moyen du disque en mm
        DMC_ar = 12.7; %Diam�tre du MC en mm
        Dp_ar = 27; % Diam�tre d'un piston en mm
        Droue_ar = 520.7; % Diam�tre d'une roue arri�re en mm

        Lplaqu_ar = 38; % Longueur de plaquette arri�re en mm
        lplaqu_ar = 30; % Largeur de plaquette arri�re en mm
        Ld_ar = 25; % Largeur de piste de disque arri�re en mm
    
    % P�dalier
        reppalonnier = 0.71; % R�partition de freinage sur l'avant au palonnier (entre 34% et 66%)
        ratiopedale = 2.5; % Ratio de p�dale (2.5 pour Olympix v2, 1.6 pour Olympix v1)
    
    % Coefficient de friction
        etha_av = 0.4; % coefficient de friction des plaquettes avant (OdG : 0.4-0.5)
        etha_ar = 0.4; % coefficient de friction des plaquettes arri�re (OdG : 0.4-0.5)

    % Limiteur de pression
        Plim_ar = 8; % Pression de d�clenchement limiteur en bar (entre 5 et 35 par pas de 0.5 pour le limiteur B�ringer)
        coefflim_ar = 1; % Coefficient de gain de pression au dessus de la limite (1 pour pas de limiteur)(chez B�ringer 0.38, 0 ou -0.2)
    
    % Limites
        Pemax_av = 100; % Pression maximum �trier avant en bar
        Pdmax_av = 100; % Pression maximum durite avant en bar
        PMCmax_av = 100; % Pression maximum MC avant en bar
        
        Pemax_ar = 100; % Pression maximum �trier arri�re en bar
        Pdmax_ar = 100; % Pression maximum durite arri�re en bar
        PMCmax_ar = 100; % Pression maximum MC arri�re en bar
        
        Pplaqumax_av = 12; % Pression de contact maximum des plaquettes en MPa (valeur commune fixe sans autre indication)
        Pplaqumax_ar = 12; % Pression de contact maximum des plaquettes en MPa
	
%% Calculs


% Interpolation des coefficients d'adh�rence longitudinaux
    p1 = 0.1; 
    C = etatsol*CorRawData;
    Ppsi_av = p1*round(Ppneu_av*14.5/p1); % Conversion en PSI et arrondi de la Pavant
    Ppsi_ar = p1*round(Ppneu_ar*14.5/p1); % Conversion en PSI et arrondi de la Parri�re
    
    % mumax
    psi = [mumax(1,2):p1:mumax(1,end)]; % Vecteur d�taill� des pressions en psi
    
    for i=1:size(mumax,1)-1 % Pour toutes les charges
        mumaxpsi=interp1(mumax(1,2:end),mumax(i+1,2:end),psi); % Interpolation linaire de mumax � charge donn�e par rapport � la pression
        mumaxpsi_av(1,i) = mumaxpsi(1,round(1+(Ppsi_av-mumax(1,2))/p1)); % mumax � charge donn�e � la pression pneu avant
        mumaxpsi_ar(1,i) = mumaxpsi(1,round(1+(Ppsi_ar-mumax(1,2))/p1)); % mumax � charge donn�e � la pression pneu arri�re
    end
    
    p2 =0.1;
    
    charge=[mumax(2,1):p2:mumax(end,1)]; % Vecteur des charges entre 50 et 350 lbs
    mumaxNew_av = interp1(mumax(2:end,1),C*mumaxpsi_av,charge); % mumax avant pour les charges correspondantes
    mumaxNew_ar = interp1(mumax(2:end,1),C*mumaxpsi_ar,charge); % mumax arri�re pour les charges correspondantes
    
    charge2 = [0:p2:mumax(2,1)-p2]; % Vecteur des charges entre 0 et 49.9 lbs
    mumaxNew_av2 = polyval(polyfit([50 150],C*mumaxpsi_av(1,1:2),1),charge2); % mumax avant pour les charges correspondantes
    mumaxNew_ar2 = polyval(polyfit([50 150],C*mumaxpsi_ar(1,1:2),1),charge2); % mumax arri�re pour les charges correspondantes
    
    charge3 = [mumax(end,1):p2:400]; % Vecteur des charges entre 350.1 et 400 lbs
    mumaxNew_av3 = polyval(polyfit([250 350],C*mumaxpsi_av(1,end-1:end),1),charge3); % mumax avant pour les charges correspondantes
    mumaxNew_ar3 = polyval(polyfit([250 350],C*mumaxpsi_ar(1,end-1:end),1),charge3); % mumax arri�re pour les charges correspondantes
    
    
    charge =[charge2 charge charge3]; % Concat�nations
    mumaxNew_av=[mumaxNew_av2 mumaxNew_av mumaxNew_av3];
    mumaxNew_ar=[mumaxNew_ar2 mumaxNew_ar mumaxNew_ar3];
    
    chargeini = charge(1,1);
    
    % mubloc   
    psi = [mubloc(1,2):p1:mubloc(1,end)]; % Vecteur des pressions en psi
    
    for i=1:size(mumax,1)-1 % Pour toutes les charges
        mublocpsi=interp1(mubloc(1,2:end),mubloc(i+1,2:end),psi); % Interpolation linaire de mubloc � charge donn�e par rapport � la pression
        mublocpsi_av(1,i) = mublocpsi(1,round(1+(Ppsi_av-mubloc(1,2))/p1)); % mubloc � charge donn�e � la pression pneu avant
        mublocpsi_ar(1,i) = mublocpsi(1,round(1+(Ppsi_ar-mubloc(1,2))/p1)); % mubloc � charge donn�e � la pression pneu arri�re
    end 
    Cmubloc_av=polyfit(mubloc(2:end,1)',C*mublocpsi_av,1); % Coefficients d'inperloation lin�aire avant
    Cmubloc_ar=polyfit(mubloc(2:end,1)',C*mublocpsi_ar,1); % Coefficients d'inperloation lin�aire arri�re
    
    mublocNew_av = polyval(Cmubloc_av,charge); % Interpolation lin�aire avant
    mublocNew_ar = polyval(Cmubloc_ar,charge); % Interpolation lin�aire arri�re
   
% Allocation m�moire
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
    Fpedale = Fpedalekg*g; % Force exerc�e sur la p�dale en N

    for i=1:size(Fpedale,2) % Pour chaque valeur d'appui p�dale

        FMC_av(i)=Fpedale(i)*reppalonnier*ratiopedale; % Force MC avant en N
        FMC_ar(i) = Fpedale(i)*(1-reppalonnier)*ratiopedale; % Force MC arri�re en N

        Pin_av(i) = FMC_av(i)*10/(NMC_av*(DMC_av/2)^2*pi); % Pression entr�e circuit avant en bar
        Pin_ar(i) = FMC_ar(i)*10/(NMC_ar*(DMC_ar/2)^2*pi); % Pression entr�e limiteur arri�re en bar

        Pout_av(i) = Pin_av(i); % Pression sortie circuit avant en bar

        % Pression sortie limiteur arri�re en bar
        if Pin_ar(i) <= Plim_ar % Si la pression d'entr�e est inf�rieure � la pression de limitation, Pout = Pin
            Pout_ar(i)=Pin_ar(i);
        else
            Pout_ar(i) = Plim_ar+coefflim_ar*(Pin_ar(i)-Plim_ar); % Sinon, limitation pression
        end

        Fpiston_av(i) = (Pout_av(i)*Np_av*pi*(Dp_av/2)^2)/10; % Force pistons avant utiles d'un �trier en N
        Fpiston_ar(i)  = (Pout_ar(i)*Np_ar*pi*(Dp_ar/2)^2)/10; % Force pistons arri�re utiles d'un �trier en N

        Ffrein_av(i) = Fpiston_av(i)*Nd_av*2*Dd_av*etha_av/Droue_av; % Force de freinage de l'essieu avant en N
        Ffrein_ar(i) = Fpiston_ar(i)*Nd_ar*2*Dd_ar*etha_ar/Droue_ar; % Force de freinage de l'essieu arri�re en N
       
        D(i) = (Ffrein_av(i)+Ffrein_ar(i))/(mt*g); % D�cc�l�ration v�hicule en G
        repdynav(i)= min(1,(repstatav +D(i)*h/e)); % R�partition de masse dynamique sur l'avant du v�hicule
        
        charge_av(i) = p2*round(repdynav(i)*mt/(Nroue_av*0.45*p2)); % charge sur un pneu avant 
        charge_ar(i) = p2*round((1-repdynav(i))*mt/(Nroue_ar*0.45*p2)); % charge sur unpneu arri�re
        
        mu_av(i) = mumaxNew_av(1,round(1+(charge_av(i)-chargeini)/p2)); % Coefficient d'adh�rence avant
        mu_ar(i) = mumaxNew_ar(1,round(1+(charge_ar(i)-chargeini)/p2)); % Coefficient d'adh�rence arri�re

        Ffrein_avmax(i) = repdynav(i)*mt*g*mu_av(i); % Force de freinage maximum avant
        Ffrein_armax(i) = mt*g*mu_ar(i)*(1-repdynav(i)); % Force de freinage maximum arri�re   
        
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
            
            % Coefficients equation second degr�
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
           
       % Blocage de l'essieu arri�re
        elseif Ffrein_avmax(i)>Ffrein_av(i) && Ffrein_armax(i)<=Ffrein_ar(i)
            % Marqueur du point de blocage arri�re
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
            
            % Coefficients equation second degr�
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
            
            % Coefficients equation second degr�
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
        
        % R�partition de freinage
         if i~=1
            repfrein(i) = Ffrein_av(i)/(Ffrein_av(i)+Ffrein_ar(i));
        end
      
    end

Dbloc = min(Dbloc_av, Dbloc_ar); % D�c�l�ration de premier blocage de roues
ibloc = min(i_av,i_ar); % Indice de premier blocage de roue
mumaxmoy = (mumaxNew_av(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45))))+...
    mumaxNew_ar(1,find(charge == p2*round(mt/(2*Nroue_ar*p2*0.45)))))/2; % Moyenne mumax avant/arri�re
mublocmoy = (mublocNew_av(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45))))+...
    mublocNew_ar(1,find(charge == p2*round(mt/(2*Nroue_av*p2*0.45)))))/2; % Moyenne mubloc avant/arri�re

Dmax = max(D(1,1:ibloc));
repfrein(1) = repfrein(2);
repmasse_Dtarget=(repstatav +Dtarget*h/e); % R�partition de masse dynamique � D=Dtarget
repmasse_Dmax = (repstatav +Dmax*h/e); % R�partition de masse dynamique � D =Dmax

itarget = find(0.05*round(D(1,1:ibloc)/0.05)==Dtarget); % Indice correspondant � la d�c�l�ration vis�e (pour curseur)
Ftarget = NaN;
if ~isempty(itarget)
    Ftarget = Fpedalekg(1,itarget(1,1)); % Force p�dale correspondante
end 

Ffrein_avopt=D(1,1:ibloc).*repdynav(1,1:ibloc)*mt*g; % Force de freinage avant optimale (r�partition frein = r�partition charge)
Ffrein_aropt=D(1,1:ibloc).*(1-repdynav(1,1:ibloc))*mt*g; % Force de freinage arri�re optimale (r�partition frein = r�partition charge)

Pmax_av = min(min(Pemax_av,PMCmax_av),Pdmax_av); % Minimum des pressions circuit avant
Pmax_ar = min(min(Pemax_ar,PMCmax_ar),Pdmax_ar); % Minimum des pressions circuit arri�re

Pplaqu_av = Fpiston_av/(Lplaqu_av*min(lplaqu_av,Ld_av)); % Pression sur les plaquettes avant
Pplaqu_ar = Fpiston_ar/(Lplaqu_ar*min(lplaqu_ar,Ld_ar)); % Pression sur les plaquettes arri�re

%% Affichage r�sultats

% Donn�es console
fprintf('Mecanical Brake Balance: %.2f\n\n',repfrein(1));
fprintf('Target deceleration: %.2f G\n',Dtarget);
fprintf('Dynamic Weight Balance at Target deceleration:%.2f\n\n',repmasse_Dtarget);
fprintf('Maximum deceleration: %.2f G\n',Dmax);
fprintf('Dynamic Weight Balance at Maximum deceleration:%.2f\n\n',repmasse_Dmax);
fprintf('Brake pedale force to lock front wheels: %.1f kg\n',Fbloc_av);
fprintf('Brake pedal force to lock rear wheels: %.1f kg\n',Fbloc_ar);

% Graphes

% D�c�l�ration en fonction de la force p�dale
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

% Fonction de la force p�dale
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

% Fonction de la d�c�l�ration

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
    
    
    
%     Partie utilis�e pour les beaux graphes du document pour l'Angleterre
%     => courbes plus �paisses et graphes plus jolis
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