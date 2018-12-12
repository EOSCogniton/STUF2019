
#include <SPI.h>
#include <Adafruit_DotStar.h>

//definition of the pins
const int DATAPIN = 4;
const int CLOCKPIN = 5;

//Variables given by de CAN
signed Rpm;
signed Gear;

// Led constants
const int NUM_PIXELS = 16; // Defines the number of pixels in the strip
const int RPM_MIN_MAX[2][5] = {
  {    0, 9800, 9800, 9800, 9800},
  {12000,13500,12000,12000,12000}
}; // Matrix with the min/max rpm to change gear

// Led variables
int Led_Number;
int Rpm_Ratio;
int Rpm_Ratio_Corr;
int Blink_Count=0;
int Blink_Time=50;
int Blink_Led; // 0=off - 1=on
unsigned long Start_Led_Millis;
unsigned long Current_Led_Millis;

// Led Strip Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

// Function to turn on the LEDs needed
// Strip.setPixelColor(index, green, red, blue);


void Led_MAJ (int Led_Number,int Gear){
    if(Gear>=1){
        // Shift Led Blink
        if(Led_Number==17){
            for(int i=0 ; i<NUM_PIXELS ; i++){
                STRIP.setPixelColor(i,255,255,255); 
            }
            STRIP.show();
            if(Blink_Count==0){
                Start_Led_Millis=millis();
                Blink_Led=1;
                Blink_Count=1;
            }
            if(Blink_Count<=10){
                Current_Led_Millis=millis();
                if(Current_Led_Millis-Start_Led_Millis>Blink_Count*Blink_Time){
                    Blink_Led=abs(Blink_Led-1);
                    Blink_Count++;
                    if(Blink_Led==0){
                        STRIP.setBrightness(0);
                        STRIP.show();
                    }
                    else if(Blink_Led==1){
                        STRIP.setBrightness(255);
                        STRIP.show();
                    }
                }
            }
            Serial.print("\n");
            Serial.print(Rpm);
            Serial.print("   ");
            Serial.print(Blink_Count);
            Serial.print("   ");
            Serial.print(Blink_Led);
        }
        else if(Led_Number>=12 && Led_Number<=16){
            Blink_Count=0;
            for(int i=0 ; i<NUM_PIXELS ; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,0,255,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        }
        else if(Led_Number>=6 && Led_Number<=11){
            for(int i=0 ; i<NUM_PIXELS ; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,255,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        }
        else if(Led_Number<=5){
            for(int i=0 ; i<NUM_PIXELS ; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,0,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        }
    }
    else if(Gear==0){
        for(int i=0 ; i<NUM_PIXELS ; i++){
            if(i<=Led_Number){
                STRIP.setPixelColor(i,255,0,0);
            }
            else{
                STRIP.setPixelColor(i,0,0,0);
            }
        }
    }
    STRIP.show();
}

void Tachometer (int Rpm,int Gear){
    Rpm_Ratio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUM_PIXELS+1);
    Rpm_Ratio_Corr = Rpm-RPM_MIN_MAX[0][Gear];
    if(Rpm_Ratio_Corr>(NUM_PIXELS+1)*Rpm_Ratio){
        Led_MAJ(NUM_PIXELS+1,Gear);
    }
    else{
        for(int i=1 ; i<=NUM_PIXELS ; i++){
            if(i*Rpm_Ratio<=Rpm_Ratio_Corr && Rpm_Ratio_Corr<=(i+1)*Rpm_Ratio){
                Led_MAJ(i,Gear);
            }
        }
    }
}

void setup(){
    Serial.begin(115200);
    STRIP.begin();
    STRIP.show();
}


void loop(){
    for(Gear=0;Gear<=4;Gear++){
        if(Gear==0){
            for(Rpm=2000;Rpm<12000;Rpm++){
                Tachometer(Rpm,Gear); 
            }
        }else{
            for(Rpm=9800;Rpm<12500;Rpm++){
                Tachometer(Rpm,Gear);
            }
        }
    }
}
