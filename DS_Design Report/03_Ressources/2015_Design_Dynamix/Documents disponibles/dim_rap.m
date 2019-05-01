clear all

mv=250 ; %masse de Dynamix
mp=80 ; %masse du pilote

m=mv+mp; %masse du véhicule chargé

R=0.5207/2; %rayon de la roue

g=9.81; %accélération de la pensanteur

hg=0.35; %hauteur du centre de masse de Dynamix
l=1.6 ; %empattement de Dynamix
rep=0.55; %répartition masse arrière

lav=l*rep;
lar=l-lav;

ibdv=(76/36*32/12); %rapport boîte de vitesse

mu=1.3; %coefficient d'adhérence

Cm=60; %couple moteur max


ipc=mu*m*rep*g/(Cm*ibdv*(1/R-mu/l-mu*hg/(R*l))) %réduction pignon/couronne

C=Cm*ipc*ibdv %couple à l'essieu arrière

ifi=ibdv*ipc

Ns=m*g*rep;

delta_P=m*ifi*Cm*hg/l;

delta_roue=Cm*ifi/l;
