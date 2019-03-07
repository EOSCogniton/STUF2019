// Code to control the LEDs of the rev counter

#include <Adafruit_DotStar.h>                            //Library offered by the manufacturer of the LEDs
#include <SPI.h>

//definition of the pins
const int DATAPIN = 1;
const int CLOCKPIN = 2;

//definition of the constants
const int NUMPIXELS = 16;                                //Defines the number of pixels in de STRIP
const int RPM_MIN_MAX[2][5] = {
  {    0, 9800, 9800, 9800, 9800},
  {12000,13500,12376,12000,12000}
};                                                       //Matrix with de max/min rev at which le pilot is suggested to climb/reduce gear

//definition of the variables used
int LedNumber;
int RpmRatio;
int RpmRatioCorr;

//declaration of functions
Adafruit_DotStar STRIP = Adafruit_DotStar(NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

//function to turn on the LEDs needed
void LedMAJ (int LedNumber,int Gear){
  if(Gear==0){
    for(int i=0 ; i<NUMPIXELS ; i++){
      if(i<=LedNumber){
        STRIP.setPixelColor(i,255,0,0);
      }
      else{
        STRIP.setPixelColor(i,0,0,0);
      }
    }
    STRIP.show();   
  }
  else if(Gear>=1){
    if(LedNumber==17){
      for(int i=0 ; i<NUMPIXELS ; i++){
        STRIP.setPixelColor(i,255,255,255);                             //STRIP.setPixelColor(index, red, green, blue);
      }
      delay(40);                                                        //Delayed 1fps
      STRIP.show();
      delay(40);
    }
    else if(LedNumber>=12 && LedNumber<=16){
      for(int i=0 ; i<NUMPIXELS ; i++){
        if(i<=LedNumber){
          STRIP.setPixelColor(i,255,0,0);
        }
        else{
          STRIP.setPixelColor(i,0,0,0);
        }
      }
      STRIP.show();
    }
    else if(LedNumber>=6 && LedNumber<=11){
      for(int i=0 ; i<NUMPIXELS ; i++){
        if(i<=LedNumber){
          STRIP.setPixelColor(i,255,255,0);
        }
        else{
          STRIP.setPixelColor(i,0,0,0);
        }
      }
      STRIP.show();
    }
    else if(LedNumber<=5){
      for(int i=0 ; i<NUMPIXELS ; i++){
        if(i<=LedNumber){
          STRIP.setPixelColor(i,0,255,0);
          }
        else{
          STRIP.setPixelColor(i,0,0,0);
        }
      }
      STRIP.show();
    }
  }
}

//function to see how many LEDs must be turned on (if gear engaged)
void Tachometer (int Rpm,int Gear){
  RpmRatio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUMPIXELS+1);
  RpmRatioCorr = Rpm-RPM_MIN_MAX[0][Gear];
  if(RpmRatioCorr>(NUMPIXELS+1)*RpmRatio){
    LedMAJ(NUMPIXELS+1,Gear);
  }
  else{
    for(int i=1 ; i<=NUMPIXELS ; i++){
      if(i*RpmRatio<=RpmRatioCorr && RpmRatioCorr<=(i+1)*RpmRatio){
        LedMAJ(i,Gear);
      }
    }
  }
}







void setup() {
  STRIP.begin();
  STRIP.show();
}



void loop() {
  Tachometer(Rpm,Gear);
}
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


  
