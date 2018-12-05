import time
import numpy

import carseour
import carseour.definitions


# Game Init
game = carseour.live()
gamedef=carseour.definitions

## Version 1

def FileMAJ():

    # Variables MAJ
    RPM=int(game.mRpm)
    Throttle=int(game.mThrottle)
    W_Temp=int(game.mWaterTempCelsius)
    A_Temp=int(game.mAmbientTemperature)
    KPH=int(game.mSpeed*10)
    O_Press=int(game.mOilPressureKPa)
    F_Press=int(game.mFuelPressureKPa)
    O_Temp=int(game.mOilTempCelsius)
    Volts=int(game.mBoostAmount*10)
    Gear=game.mGear
    
    # Open the Data File
    FileName=open('C:/Users/Arthur/OneDrive/1_Documents/1_DIY Sim Dash/CAN/Ttl/DataFile.txt','w')
    
    # File MAJ
    FileName.write('Data,Value\n')
    FileName.write('\n')
    FileName.write('RPM,'+str(RPM)+'\n')
    FileName.write('Throttle,'+str(Throttle)+'\n')
    FileName.write('W_Temp,'+str(W_Temp)+'\n')
    FileName.write('A_Temp,'+str(A_Temp)+'\n')
    FileName.write('KPH,'+str(KPH)+'\n')
    FileName.write('O_Press,'+str(O_Press)+'\n')
    FileName.write('F_Press,'+str(F_Press)+'\n')
    FileName.write('O_Temp,'+str(O_Temp)+'\n')
    FileName.write('Volts,'+str(Volts)+'\n')
    FileName.write('Gear,'+str(Gear)+'\n')


    # Close de Data File
    FileName.close()
    return

def Cont():
    while game.mGameState!=1:
        FileMAJ()
        time.sleep(0.1)
    return

## Version 2

def FileMAJ2():
    # Variables MAJ
    RPM=int(game.mRpm)
    Throttle=int(game.mThrottle)
    W_Temp=int(game.mWaterTempCelsius)
    A_Temp=int(game.mAmbientTemperature)
    KPH=int(game.mSpeed*10)
    O_Press=int(game.mOilPressureKPa)
    F_Press=int(game.mFuelPressureKPa)
    O_Temp=int(game.mOilTempCelsius)
    Volts=int(game.mBoostAmount*10)
    Gear=game.mGear
    
    # Open the Data File
    FileName=open('C:/Users/Arthur/OneDrive/1_Documents/1_DIY Sim Dash/CAN/Ttl/DataFile2.txt','a')
    
    # File MAJ
    FileName.write(str(RPM)+','+str(Throttle)+','+str(W_Temp)+','+str(A_Temp)+','+str(KPH)+','+str(O_Press)+','+str(F_Press)+','+str(O_Temp)+','+str(Volts)+','+str(Gear)+'\n')

    # Close de Data File
    FileName.close()
    

def Cont2():
    
    # Open the Data File
    FileName=open('C:/Users/Arthur/OneDrive/1_Documents/1_DIY Sim Dash/CAN/Ttl/DataFile2.txt','w')
    
    FileName.write('RPM, Throttle, W_Temp, A_Temp, KPH, O_Press, F_Press, O_Temp, Volts, Gear'+'\n')
    
    # Close de Data File
    FileName.close()
    
    while game.mGameState!=1:
        FileMAJ2()
        time.sleep(0.1)
    return
        