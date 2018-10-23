Favant = 2235 ;
Farriere = 511 ;


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

muavant = muavant * 0.66 
muarriere = muarriere * 0.66