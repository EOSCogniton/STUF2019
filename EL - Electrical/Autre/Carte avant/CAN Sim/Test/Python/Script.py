# pip install python-CAN
# pip install https://github.com/matslindh/carseour/zipball/master

# https://bitbucket.org/hardbyte/python-can/issues/14/python_usb_can_-reading


from PCANBasic import *
from ctypes import *

import carseour
import carseour.definitions

# CAN Config
CAN = PCANBasic()
res = CAN.Initialize(PCAN_USBBUS1, PCAN_BAUD_1M)
if res == PCAN_ERROR_OK:
    print("CAN init failure")
    # print("Getstatus:-",CAN.GetStatus(PCAN_USBBUS1))
    # print("hardwar:-", CAN.GetValue(PCAN_USBBUS1,PCAN_DEVICE_NUMBER))
else:
    print("CAN init ok")


Gear=3
data2003=00, Gear, 00, 00, 00, 00, 00, 00
msg2003 = TPCANMsg()
tmstamp = TPCANTimestamp()
msg2003._fields_ = [ ("ID",0x2000), ("LEN", 8), ("DATA", data2003) ]
wrtstat= CAN.Write(PCAN_USBBUS1,msg2003)


# Game Config
def Game():
    game = carseour.live()
    gamedef=carseour.definitions
    return
    
def Send():
    while game.mGameState!=1:
        
        RPM=game.mRpm
        W_Temp=game.mWaterTempCelsius
        A_Temp=game.mAmbientTemperature
        KPH=game.mSpeed
        Volts=10*mBoostAmount
        Gear=game.mGear
        
        data2000=RPM//256, RPM%256, 00, 00, W_Temp//256, W_Temp%256, A_Temp//256, A_Temp%256
        data2001=00, 00, 00, 00, KPH//265, KPH%256, 00, 00
        data2002=00, 00, 00, 00, Volts//256, Volts%256, 00, 00
        data2003=00, Gear, 00, 00, 00, 00, 00, 00
         
        msg2000 = TPCANMsg()
        msg2000._fields_ = [ ("ID",0x2000), ("LEN", 8), ("DATA", data2000) ]
        wrtstat= CAN.Write(PCAN_USBBUS1,msg2000)
        
        msg2001 = TPCANMsg()
        msg2001._fields_ = [ ("ID",0x2000), ("LEN", 8), ("DATA", data2001) ]
        wrtstat= CAN.Write(PCAN_USBBUS1,msg2001)
        
        msg2002 = TPCANMsg()
        msg2002._fields_ = [ ("ID",0x2000), ("LEN", 8), ("DATA", data2002) ]
        wrtstat= CAN.Write(PCAN_USBBUS1,msg2002)
        
        msg2003 = TPCANMsg()
        msg2003._fields_ = [ ("ID",0x2000), ("LEN", 8), ("DATA", data2003) ]
        wrtstat= CAN.Write(PCAN_USBBUS1,msg2003)
    return
