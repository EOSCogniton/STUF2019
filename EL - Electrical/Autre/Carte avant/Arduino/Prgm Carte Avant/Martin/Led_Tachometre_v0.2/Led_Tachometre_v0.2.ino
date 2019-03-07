// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>
#include <Adafruit_DotStar.h>

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 
const int DATAPIN = 1;
const int CLOCKPIN = 3;

// Data variables
// R_ID=0x2000
signed Rpm;

// R_ID=0x2003
signed Gear;

// Led cst
const int NUM_PIXELS = 16; // Defines the number of pixels in the strip
const int RPM_MIN_MAX[2][5] = {
  {    0, 9800, 9800, 9800, 9800},
  {12000,13500,12376,12000,12000}
}; // Matrix with the min/max rpm to change gear

// Led variables
int Led_Number;
int Rpm_Ratio;
int Rpm_Ratio_Corr;
int Blink_Count=0;
int Blink_Time=10;
int Blink_Led; // 0=off - 1=on
unsigned long Led_Millis;

// Led Strip Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

// Function to turn on the LEDs needed
// Strip.setPixelColor(index, red, green, blue);

void setup(){
    Serial.begin(115200);
  
    // Initialize MCP2515 running at 16MHz with a baudrate of 1000kb/s and the masks and filters disabled
    if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK){
        Serial.println("Init Successfully!");
    }
    else{
        Serial.println("Init Failure");
    }

    // Set operation mode to normal so the MCP2515 sends acks to received data
    CAN0.setMode(MCP_NORMAL);                  

    // Configuring pin for /INT input
    pinMode(CAN0_INT, INPUT);                            
}

void Led_MAJ (int Led_Number,int Gear){
    STRIP.show();
    if(Gear>=1){
        // Shift Led Blink
        if(Led_Number==17){
            for(int i=0 ; i<NUM_PIXELS ; i++){
                STRIP.setPixelColor(i,255,255,255); 
            }
            if(Blink_Count=0){
                Led_Millis=millis();
            }
            if(Blink_Count<=5){
                if(millis-Led_Millis>Blink_Time){
                    Blink_Led=abs(Blink_Led-1);
                    if(Blink_Led=0){
                        STRIP.show();
                        Blink_Count++;
                    }
                }
            } 
        }
        else if(Led_Number>=12 && Led_Number<=16){
            Blink_Count=0;
            for(int i=0 ; i<Led_Number ; i++){
                STRIP.setPixelColor(i,255,0,0);
            }
        }
        else if(Led_Number>=6 && Led_Number<=11){
            for(int i=0 ; i<Led_Number ; i++){
                STRIP.setPixelColor(i,255,255,0);
            }
        }
        else if(Led_Number<=5){
            for(int i=0 ; i<Led_Number ; i++){
                STRIP.setPixelColor(i,0,255,0);
            }
        }
    }
    else if(Gear==0){
        for(int i=0 ; i<=Led_Number ; i++){
          STRIP.setPixelColor(i,255,0,0);
        }
    }
}

void Tachometer (int Rpm,int Gear){
    Rpm_Ratio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUM_PIXELS+1);
    Rpm_Ratio_Corr = Rpm-RPM_MIN_MAX[0][Gear];
    if(Rpm_Ratio_Corr>(NUM_PIXELS+1)*Rpm_Ratio){
        Led_MAJ(NUM_PIXELS+1,Gear);
        Serial.print("\n");
        Serial.print("LED =");
        Serial.print(NUM_PIXELS+1);
    }
    else{
        for(int i=1 ; i<=NUM_PIXELS ; i++){
            if(i*Rpm_Ratio<=Rpm_Ratio_Corr && Rpm_Ratio_Corr<=(i+1)*Rpm_Ratio){
                Led_MAJ(i,Gear);
                Serial.print("\n");
                Serial.print("LED =");
                Serial.print(i);
            }
        }
    }
}

void loop(){
    // MAJ RPM Bar
    Tachometer(Rpm,Gear);
}
