/***************************************************************************
   
   Function name: Led_Strip
   
   Author:        Martín Gómez-Valcárcel (MGV)
   
   Descriptions:  All these functions control the LED band. 
                  Engine_Failure checks, from certain values from the engine,
                  if there is a serious problem. If there is, it calls 
                  Led_Update to make all LEDs flash red.
                  Tachometer calculates from the limits set in RPM_MIN_MAX 
                  and the gear engaged, the number of LEDs to be lit and 
                  calls the Led_Update function to perform the task.
                  Led_Update receives the number of LEDs to illuminate, as
                  well as the gear the vehicle is in and if there is an 
                  engine fault. If there is a fault, all LEDs will flash
                  red. If the gear is equal to 0, then the LEDs will light
                  green. If the gear is equal to or greater than 1, up to 
                  5 LEDs will light green, 6 to 11 yellow, 12 to 16 red and
                  if they are 17 it will flash 5 times white, to inform the
                  pilot to increase the gear.
                         
***************************************************************************/
#include "Led_Strip.h"

/**************************************************************************/
//    Internal variables and constants used ONLY by the functions in this file
/**************************************************************************/

// Led constants
const int Bright=20;
const int NUM_PIXELS = 16; // Defines the number of pixels in the strip
const int RPM_MIN_MAX[2][7] = {
  {    0, 2000, 2000, 2000, 2000, 2000, 2000},
  {14000,13300,13100,12900,12800,12700,12000}
}; // Matrix with the min/max rpm to change gear

// Led variables
int Led_Number;
int Led_Number_B;
int Rpm_Ratio;
int Rpm_Ratio_Corr;
int Blink_Time=200;
int Gear_Blink_Count=0;
int Gear_Blink_Led; // 0=off - 1=on
unsigned long Start_Fail_Millis;
unsigned long Current_Fail_Millis;
unsigned long Start_Gear_Millis;
unsigned long Current_Gear_Millis;

//Engine failure
int Fail_Init=0;
int Fail_Disp=0;

// Function to turn on the LEDs needed
// Strip.setPixelColor(index, green, red, blue);

// Led Strip Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

/**************************************************************************/
//    Functions
/**************************************************************************/

void Led_Init(){
    STRIP.begin();
    STRIP.show();
}

void Engine_Failure (signed W_Temp,signed A_Temp,signed O_Press){
    if(W_Temp>135 || A_Temp>60 || O_Press<1){
        if(Fail_Init==0){
            Start_Fail_Millis=millis();
            Fail_Disp=1;
            Fail_Init=1;
        }else{
            Current_Fail_Millis=millis();
            if(Current_Fail_Millis-Start_Fail_Millis>Blink_Time){
                Start_Fail_Millis=millis();
                Fail_Disp=abs(Fail_Disp-1);
                Serial.print("Ploum");
            }
        }
    }else{
        Fail_Disp=0;
        Fail_Init=0;
    }
}

void Tachometer (int Rpm,int Gear,bool Auto){
    Rpm_Ratio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUM_PIXELS+1);
    Rpm_Ratio_Corr = Rpm-RPM_MIN_MAX[0][Gear];
    if(Rpm_Ratio_Corr>(NUM_PIXELS+1)*Rpm_Ratio){
        Led_Update(NUM_PIXELS+1,Gear,0,Auto);
    }
    else{
        for(int i=0 ; i<=NUM_PIXELS ; i++){
            if(i*Rpm_Ratio<=Rpm_Ratio_Corr && Rpm_Ratio_Corr<=(i+1)*Rpm_Ratio){
                Led_Update(i,Gear,0,Auto);
            }
        }
    }
}

void Led_Update (int Led_Number,int Gear,boolean Engine_Fail,bool Auto){
    
    Serial.print("\n");
    Serial.print("Fail_Disp = ");
    Serial.print(Fail_Disp);

    Serial.print("\n");
    Serial.print("Led_Disp = ");
    Serial.print(Led_Number);
    if (Led_Number!=Led_Number_B){
        Led_Number_B=Led_Number;
        STRIP.setBrightness(Bright);
        if(Gear==0){
            for(int i=0 ; i<NUM_PIXELS ; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,255,255);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        } else if(Gear>0){
            if {Led_Number==0){
                for(int i=0; i<NUM_PIXELS ; i++){
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
            for(int i=0; i<10; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,0,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
            for(i=10;i<15;i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,255,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
            for(i=16;i<17;i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,0,255,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        }
    }

    // Affichage d'une erreur
    if(Fail_Disp==1){
        STRIP.setBrightness(Bright);
        Gear_Blink_Count=0;
        for(int i=0 ; i<NUM_PIXELS ; i++){
            STRIP.setPixelColor(i,0,255,0); 
        }
        STRIP.show();
    }

    // Clignotement du bandeau = Shift Light
    if (Led_Number<17) {Gear_Blink_Count=0;}
    if(Led_Number==17){
        for(int i=0 ; i<NUM_PIXELS ; i++){
            STRIP.setPixelColor(i,255,255,255); 
        }
        STRIP.show();
        if(Gear_Blink_Count==0){
            Start_Gear_Millis=millis();
            Gear_Blink_Led=1;
            Gear_Blink_Count=1;
        }
        if(Gear_Blink_Count<=10){  //It's going to blink half the number writen
            Current_Gear_Millis=millis();
            if(Current_Gear_Millis-Start_Gear_Millis>Blink_Time){
                Start_Gear_Millis=millis();
                Gear_Blink_Led=abs(Gear_Blink_Led-1);
                Gear_Blink_Count++;
                if(Gear_Blink_Led==0){
                    STRIP.setBrightness(0);
                    Serial.print("Led Off");
                    STRIP.show();
                }
                else if(Gear_Blink_Led==1){
                    STRIP.setBrightness(Bright);
                    Serial.print("Led On");
                    STRIP.show();
                }
            }
        }
    }
    
    if (Auto){
      Serial.print("\n");
      Serial.print("Auto");
      STRIP.setBrightness(Bright);
      for(int i=0 ; i<6 ; i++){
            STRIP.setPixelColor(i,255,0,255);
        }
    }
    STRIP.show();
}


/***************************************************************************
  END FILE
***************************************************************************/
