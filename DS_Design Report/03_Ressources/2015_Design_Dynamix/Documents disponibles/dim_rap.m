clear all

mv=250 ; %masse de Dynamix
mp=80 ; %masse du pilote

m=mv+mp; %masse du v�hicule charg�

R=0.5207/2; %rayon de la roue

g=9.81; %acc�l�ration de la pensanteur

hg=0.35; %hauteur du centre de masse de Dynamix
l=1.6 ; %empattement de Dynamix
rep=0.55; %r�partition masse arri�re

lav=l*rep;
lar=l-lav;

ibdv=(76/36*32/12); %rapport bo�te de vitesse

mu=1.3; %coefficient d'adh�rence

Cm=60; %couple moteur max


ipc=mu*m*rep*g/(Cm*ibdv*(1/R-mu/l-mu*hg/(R*l))) %r�duction pignon/couronne

C=Cm*ipc*ibdv %couple � l'essieu arri�re

ifi=ibdv*ipc

Ns=m*g*rep;

delta_P=m*ifi*Cm*hg/l;

delta_roue=Cm*ifi/l;
