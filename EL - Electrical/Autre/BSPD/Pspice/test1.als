* Schematics Aliases *

.ALIASES
C_C2            C2(1=0 2=$N_0001 )
C_C1            C1(1=0 2=$N_0002 )
R_R3            R3(1=$N_0002 2=+5v )
X_U1A           U1A(+=$N_0004 -=$N_0005 V+=+5v V-=0 OUT=$N_0003 )
X_U3A           U3A(A=$N_0003 Y=$N_0006 PWR=$G_DPWR GND=$G_DGND )
X_X2            X2(GND=0 TRIGGER=$N_0006 OUTPUT=$N_0007 RESET=$N_0003
+  CONTROL=$N_0001 THRESHOLD=$N_0002 DISCHARGE=$N_0002 VCC=+5v )
R_R4            R4(1=0 2=$N_0007 )
R_R2            R2(1=0 2=$N_0005 )
R_R1            R1(1=$N_0005 2=+5v )
V_V4            V4(+=$N_0004 -=0 )
_    _($G_DGND=$G_DGND)
_    _($G_DPWR=$G_DPWR)
_    _(+5v=+5v)
.ENDALIASES

