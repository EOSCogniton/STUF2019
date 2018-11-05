function [ tau ] = coeflong_r5_13(pneu, P, IA, SA, SL, FZ )
%Permet d'obtenir le coefficient d'adh�rence longitudinal pour toute charge, par
%lin�arisation

% pneu = indices du pneu de la forme 'CA137' (string) ;
% Pression: valeurs discr�tes des runs: 8, 10, 12, 14 psi
            %Pour 12psi, on choisir les runs avec 12i
% IA (carossage): valeurs discr�tes des runs: 0, 2, 4 degres
% FZ en pounds
% Vitesse de 25mph 

pres = int2str(P) ;
car = int2str(IA) ;
der = int2str(SA) ;

if P==12
    pres='12f' ;
end

%N�cessite les coefficients des approximations polynomiales de tau=f(SL) dans
%les cas de charges impos�es du run

%On cherche dans quel intervalle de charges impos�es dans le run on se
%situe et on lin�arise gr�ce aux deux cas de charges les plus proches

if P==8
    
    if (200<FZ)&&(FZ<=250)

        FZa=200 ;
        FZb=250 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end

    if (150<FZ)&&(FZ<=200)

        FZa=150 ;
        FZb=200 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end

    if (50<=FZ)&&(FZ<=150)

        FZa=50 ;
        FZb=150 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end
    
else
    if (250<FZ)&&(FZ<=350)

        FZa=250 ;
        FZb=350 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end

    if (150<FZ)&&(FZ<=250)

        FZa=150 ;
        FZb=250 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end

    if (50<=FZ)&&(FZ<=150)

        FZa=50 ;
        FZb=150 ;

        vecta=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        vecta = matfile(vecta,'Writable',true); %coeffs polynomiaux
        taua = polyval(vecta.p,SL) ;  %�valuation de tau en SL

        vectb=strcat('pB5_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        vectb = matfile(vectb,'Writable',true); %coeffs polynomiaux
        taub = polyval(vectb.p,SL) ;  %�valuation de tau en SL

        tau = (1/(FZb-FZa)) * ( (FZ-FZa) * taub + (FZb-FZ) * taua ) ; %lin�arisation

    end

    
end

end