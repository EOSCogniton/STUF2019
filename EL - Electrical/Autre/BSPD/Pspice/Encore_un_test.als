* Schematics Aliases *

.ALIASES
R_R1            R1(1=$N_0002 2=$N_0001 )
R_R2            R2(1=$N_0003 2=0 )
X_U1A           U1A(+=$N_0001 -=$N_0003 V+=$N_0005 V-=0 OUT=$N_0004 )
R_R3            R3(1=$N_0005 2=$N_0003 )
V_V1            V1(+=$N_0005 -=0 )
R_R6            R6(1=$N_0007 2=$N_0006 )
R_R7            R7(1=$N_0008 2=0 )
X_U3A           U3A(+=$N_0006 -=$N_0008 V+=$N_0010 V-=0 OUT=$N_0009 )
R_R8            R8(1=$N_0010 2=$N_0008 )
V_V2            V2(+=$N_0010 -=0 )
C_C1            C1(1=0 2=$N_0001 )
X_U5A           U5A(A=$N_0002 Y=$N_0007 PWR=$G_DPWR GND=$G_DGND )
X_U4A           U4A(CLRbar=$N_0011 D=$N_0007 CLK=$N_0009 PREbar=$N_0010
+  Q=$N_0012 Qbar=$N_0013 PWR=$G_DPWR GND=$G_DGND )
V_V3            V3(+=$N_0014 -=0 )
R_R10           R10(1=0 2=$N_0015 )
X_U9A           U9A(A=$N_0016 Y=$N_0011 PWR=$G_DPWR GND=$G_DGND )
X_U6A           U6A(CLRbar=$N_0014 D=$N_0016 CLK=$N_0017 PREbar=$N_0014
+  Q=$N_0015 Qbar=$N_0018 PWR=$G_DPWR GND=$G_DGND )
R_R5            R5(1=0 2=$N_0016 )
X_U2A           U2A(CLRbar=$N_0019 D=$N_0002 CLK=$N_0004 PREbar=$N_0005
+  Q=$N_0016 Qbar=$N_0020 PWR=$G_DPWR GND=$G_DGND )
X_U8A           U8A(A=$N_0012 Y=$N_0019 PWR=$G_DPWR GND=$G_DGND )
R_R9            R9(1=0 2=$N_0012 )
X_U7A           U7A(A=$N_0016 B=$N_0012 Y=$N_0017 PWR=$G_DPWR GND=$G_DGND )
C_C2            C2(1=0 2=$N_0006 )
U_DSTM1          DSTM1(PIN1=$N_0002 )
_    _($G_DPWR=$G_DPWR)
_    _($G_DGND=$G_DGND)
.ENDALIASES

