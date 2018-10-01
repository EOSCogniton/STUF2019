*version 9.1 143680966
u 201
U? 5
X? 4
R? 7
V? 5
C? 5
? 5
@libraries
@analysis
.DC 0 0 0 0 1 1
+ 0 0 V2
+ 0 4 1
+ 0 5 4
+ 0 6 0.1
.TRAN 1 0 0 0
+0 0ns
+1 2s
.OP 0 
.STMLIB test1.stl
@targets
@attributes
@translators
a 0 u 13 0 0 0 hln 100 PCBOARDS=PCB
a 0 u 13 0 0 0 hln 100 PSPICE=PSPICE
a 0 u 13 0 0 0 hln 100 XILINX=XILINX
@setup
unconnectedPins 0
connectViaLabel 0
connectViaLocalLabels 0
NoStim4ExtIFPortsWarnings 1
AutoGenStim4ExtIFPorts 1
@index
pageloc 1 0 5299 
@status
n 0 118:08:28:19:44:31;1538156671 e 
s 0 118:08:28:19:44:36;1538156676 e 
*page 1 0 970 720 iA
@ports
port 13 GND_ANALOG 120 200 h
port 14 +5V 80 160 u
port 128 GND_ANALOG 180 170 h
port 127 +5V 180 110 h
a 1 s 3 0 0 0 hcn 100 LABEL=+5v
port 47 GND_ANALOG 390 230 h
port 70 +5V 440 90 h
port 116 GND_ANALOG 580 190 h
port 17 GND_ANALOG 50 160 h
@parts
part 65 c 340 190 v
a 0 sp 0 0 0 10 hlb 100 PART=c
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=CK05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=C2
a 0 ap 9 0 15 0 hln 100 REFDES=C2
a 0 u 13 0 0 35 hln 100 VALUE=0.01u
part 46 c 390 230 v
a 0 sp 0 0 0 10 hlb 100 PART=c
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=CK05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=C1
a 0 ap 9 0 15 0 hln 100 REFDES=C1
a 0 u 13 0 5 30 hln 100 VALUE=1n
part 45 R 390 130 v
a 0 sp 0 0 0 10 hlb 100 PART=R
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=RC05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=R3
a 0 ap 9 0 15 0 hln 100 REFDES=R3
a 0 u 13 0 15 35 hln 100 VALUE=500k
part 2 LM324 140 120 h
a 0 sp 11 0 14 70 hcn 100 PART=LM324
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=DIP14
a 0 s 0:13 0 0 0 hln 100 GATE=A
a 0 a 0:13 0 0 0 hln 100 PKGREF=U1
a 0 ap 9 0 56 8 hcn 100 REFDES=U1A
part 5 7405 220 140 h
a 0 sp 11 0 40 40 hln 100 PART=7405
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=DIP14
a 0 s 0:13 0 0 0 hln 100 GATE=A
a 0 a 0:13 0 0 0 hln 100 PKGREF=U3
a 0 ap 9 0 28 6 hln 100 REFDES=U3A
part 44 555D 440 140 h
a 0 sp 11 0 66 100 hlb 100 PART=555D
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=DIP8
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=X2
a 1 ap 9 0 70 8 hln 100 REFDES=X2
part 115 R 580 190 v
a 0 sp 0 0 0 10 hlb 100 PART=R
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=RC05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=R4
a 0 ap 9 0 15 0 hln 100 REFDES=R4
part 7 R 120 200 v
a 0 sp 0 0 0 10 hlb 100 PART=R
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=RC05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=R2
a 0 ap 9 0 15 0 hln 100 REFDES=R2
part 6 R 120 160 u
a 0 sp 0 0 0 10 hlb 100 PART=R
a 0 s 0:13 0 0 0 hln 100 PKGTYPE=RC05
a 0 s 0:13 0 0 0 hln 100 GATE=
a 0 a 0:13 0 0 0 hln 100 PKGREF=R1
a 0 ap 9 0 15 0 hln 100 REFDES=R1
part 200 VPULSE 50 120 h
a 0 a 0:13 0 0 0 hln 100 PKGREF=V4
a 1 ap 9 0 20 10 hcn 100 REFDES=V4
a 1 u 0 0 0 0 hcn 100 V1=0
a 1 u 0 0 0 0 hcn 100 V2=5
a 1 u 0 0 0 0 hcn 100 TD=
a 1 u 0 0 0 0 hcn 100 TF=1
part 1 titleblk 970 720 h
a 1 s 13 0 350 10 hcn 100 PAGESIZE=A
a 1 s 13 0 180 60 hcn 100 PAGETITLE=
a 1 s 13 0 300 95 hrn 100 PAGENO=1
a 1 s 13 0 340 95 hrn 100 PAGECOUNT=1
part 193 nodeMarker 580 150 h
a 0 s 0 0 0 0 hln 100 PROBEVAR=
a 0 a 0 0 4 22 hlb 100 LABEL=1
part 194 nodeMarker 60 120 h
a 0 s 0 0 0 0 hln 100 PROBEVAR=
a 0 a 0 0 4 22 hlb 100 LABEL=2
part 196 nodeMarker 300 140 h
a 0 s 0 0 0 0 hln 100 PROBEVAR=
a 0 a 0 0 4 22 hlb 100 LABEL=3
part 199 nodeMarker 120 160 h
a 0 s 0 0 0 0 hln 100 PROBEVAR=
a 0 a 0 0 4 22 hlb 100 LABEL=4
@conn
w 112
a 0 up 0:33 0 0 0 hln 100 V=
s 390 180 390 200 59
s 440 180 390 180 57
s 390 170 390 180 62
s 440 170 390 170 60
a 0 up 33 0 415 169 hct 100 V=
s 390 130 390 170 52
w 72
a 0 up 0:33 0 0 0 hln 100 V=
s 390 90 440 90 73
s 440 90 490 90 75
a 0 up 33 0 465 89 hct 100 V=
s 490 90 490 110 76
w 64
a 0 up 0:33 0 0 0 hln 100 V=
s 440 160 340 160 63
a 0 up 33 0 390 159 hct 100 V=
w 49
a 0 up 0:33 0 0 0 hln 100 V=
s 490 210 490 230 48
s 490 230 390 230 50
a 0 up 33 0 440 229 hct 100 V=
s 340 190 340 230 66
s 340 230 390 230 68
w 118
a 0 up 0:33 0 0 0 hln 100 V=
s 300 150 300 180 119
s 300 180 220 180 121
s 220 180 220 140 123
s 440 150 300 150 117
a 0 up 33 0 370 149 hct 100 V=
w 126
a 0 up 0:33 0 0 0 hln 100 V=
s 540 150 580 150 125
a 0 up 33 0 560 149 hct 100 V=
w 53
a 0 up 0:33 0 0 0 hln 100 V=
s 440 140 300 140 113
a 0 up 33 0 355 139 hct 100 V=
s 300 140 270 140 197
w 9
a 0 up 0:33 0 0 0 hln 100 V=
s 120 160 140 160 36
a 0 up 33 0 130 159 hct 100 V=
w 19
a 0 up 0:33 0 0 0 hln 100 V=
s 50 120 60 120 18
a 0 up 33 0 95 119 hct 100 V=
s 60 120 140 120 195
@junction
j 120 160
+ p 7 2
+ p 6 1
j 120 200
+ p 7 1
+ s 13
j 80 160
+ p 6 2
+ s 14
j 140 120
+ p 2 +
+ w 19
j 140 160
+ p 2 -
+ w 9
j 120 160
+ p 7 2
+ w 9
j 120 160
+ p 6 1
+ w 9
j 220 140
+ p 2 OUT
+ w 118
j 180 110
+ s 127
+ p 2 V+
j 180 170
+ s 128
+ p 2 V-
j 580 190
+ p 115 1
+ s 116
j 390 230
+ p 46 1
+ s 47
j 440 140
+ p 44 TRIGGER
+ w 53
j 440 150
+ p 44 RESET
+ w 118
j 580 150
+ p 115 2
+ w 126
j 540 150
+ p 44 OUTPUT
+ w 126
j 390 200
+ p 46 2
+ w 112
j 440 180
+ p 44 DISCHARGE
+ w 112
j 390 180
+ w 112
+ w 112
j 440 170
+ p 44 THRESHOLD
+ w 112
j 390 130
+ p 45 1
+ w 112
j 390 170
+ w 112
+ w 112
j 390 90
+ p 45 2
+ w 72
j 440 90
+ s 70
+ w 72
j 490 110
+ p 44 VCC
+ w 72
j 340 160
+ p 65 2
+ w 64
j 440 160
+ p 44 CONTROL
+ w 64
j 490 210
+ p 44 GND
+ w 49
j 390 230
+ p 46 1
+ w 49
j 390 230
+ s 47
+ w 49
j 340 190
+ p 65 1
+ w 49
j 220 140
+ p 5 A
+ p 2 OUT
j 220 140
+ p 5 A
+ w 118
j 270 140
+ p 5 Y
+ w 53
j 580 150
+ p 193 pin1
+ p 115 2
j 580 150
+ p 193 pin1
+ w 126
j 60 120
+ p 194 pin1
+ w 19
j 300 140
+ p 196 pin1
+ w 53
j 120 160
+ p 199 pin1
+ p 7 2
j 120 160
+ p 199 pin1
+ p 6 1
j 120 160
+ p 199 pin1
+ w 9
j 50 160
+ p 200 -
+ s 17
j 50 120
+ p 200 +
+ w 19
@attributes
a 0 s 0:13 0 0 0 hln 100 PAGETITLE=
a 0 s 0:13 0 0 0 hln 100 PAGENO=1
a 0 s 0:13 0 0 0 hln 100 PAGESIZE=A
a 0 s 0:13 0 0 0 hln 100 PAGECOUNT=1
@graphics
