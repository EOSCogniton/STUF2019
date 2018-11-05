function [ min_grip, SL_mingrip ] = min_grip_r6_13( pneu, P, IA, SA, FZ )
%Renvoie le maximum d'adhérence pour un pneu donné (13" du Round 6), à pression,
%carrossage, charge, dérive donnés. Renvoie également le SL pour lequel ce
%max est atteint


pres = int2str(P) ;
car = int2str(IA) ;
der = int2str(SA) ;

if P==12
    pres='12f' ;
end

%Détermination de la plage de variation de SL

if P==8
    
    if (250<FZ)&&(FZ<=300)

        FZa=250 ;
        FZb=300 ;

        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end
        

    end

    if (150<FZ)&&(FZ<=250)

        FZa=150 ;
        FZb=250 ;

        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end

    end

    if (50<=FZ)&&(FZ<=150)
        
        FZa = 50 ;
        FZb = 150 ;
        
        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end

    end
    
else
    if (250<FZ)&&(FZ<=350)
        
        FZa = 250 ;
        FZb = 350 ;

        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end

    end

    if (150<FZ)&&(FZ<=250)

        FZa=150 ;
        FZb=250 ;

        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end
    end

    if (50<=FZ)&&(FZ<=150)

        FZa=50 ;
        FZb=150 ;

        vecta=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZa),'_',car,'_',der) ;
        ma = matfile(vecta,'Writable',true);
        SLamin = ma.SLmin ;
%         SLamax = ma.SLmax ;
        
        vectb=strcat('pB6_',pneu,'_',pres,'_25_',num2str(FZb),'_',car,'_',der) ;
        mb = matfile(vectb,'Writable',true);
        SLbmin = mb.SLmin ;
%         SLbmax = mb.SLmax ;
        
        if SLamin < SLbmin
            SLmin = SLbmin ;
        else
            SLmin = SLamin ;
        end
        
%         if SLamax > SLbmax
%             SLmax = SLbmax ;
%         else
%             SLmax = SLamax ;
%         end
    end

    
end


SLmin = SLmin+0.02 ;  %borne inf de SL
% SLmax = SLmax-0.02 ;  %borne sup de SL

x = SLmin:0.005:0 ;
min_grip = 0 ;
SL_mingrip = 0 ;

for i = 1 : length(x)
    grip = - coeflong_r6_13(pneu, P, IA, SA, x(i), FZ ) ;
    
    if grip < min_grip
        min_grip = grip ;
        SL_mingrip = x(i) ;
    end
    
end

end

