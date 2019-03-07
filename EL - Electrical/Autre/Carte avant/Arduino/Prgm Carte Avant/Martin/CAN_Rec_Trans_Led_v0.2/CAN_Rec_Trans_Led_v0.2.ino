// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>
#include <Adafruit_DotStar.h>
#include "Adafruit_MCP23008.h"

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 
const int DATAPIN = 1;
const int CLOCKPIN = 3;
// Set Transmission Pin
const int TRANS_PIN_4 = 4; // à vérif

// Recieve variables init
long unsigned int R_ID_Mask;
long unsigned int R_ID;
unsigned char Len = 0;
unsigned char Data[8];
char Print[128];  

// Transmit variables init
long unsigned int T_ID;
byte Trans[8];
byte Send;
unsigned long tmillis=millis();
unsigned long T_D_Millis=millis();
unsigned long T_C_Millis=millis();
int T_Time=1000;

// Data variables
// R_ID=0x2000
signed Rpm;
signed TPS; // %
signed W_Temp;
signed A_Temp;

// R_ID=0x2001
signed Lambda; // x1000
signed Kph; // x10
signed O_Press;

// R_ID=0x2002
signed F_Press;
signed O_Temp;
signed Volts; // x10

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

void Data_MAJ(unsigned char Data[8]){  
    if(R_ID==0x2000){
        Rpm=Data[1]+256*Data[0];
        TPS=Data[3]+256*Data[2];
        W_Temp=Data[5]+256*Data[4];
        A_Temp=Data[7]+256*Data[6];
        sprintf(Print, "RPM = %5d   Throttle = %3d   Water Temp = %3d    Air Temp = %3d", Rpm, TPS, W_Temp, A_Temp);
        Serial.print("\n");
        Serial.print(Print);
    }
    if(R_ID==0x2001){
        Lambda=Data[3]+256*Data[2];
        Kph=Data[5]+256*Data[4];
        O_Press=Data[7]+256*Data[6];
        sprintf(Print, "Lambda = %3d   KPH = %3d   Oil Press = %3d", Lambda, Kph, O_Press);
        Serial.print("\n");
        Serial.print(Print);
    }
    
    if(R_ID==0x2002){
        F_Press=Data[1]+256*Data[0];
        O_Temp=Data[3]+256*Data[2];
        Volts=Data[5]+256*Data[4];
        sprintf(Print, "Fuel Press = %3d   Oil Temp = %3d   Volts = %3d", F_Press, O_Temp, Volts);
        Serial.print("\n");
        Serial.print(Print);
    }
    if(R_ID==0x2003){
        Gear=Data[1]+256*Data[0];
        sprintf(Print, "Gear = %1d", Gear);
        Serial.print("\n");
        Serial.print(Print);
    }
    return;
}

void Recieve(){
    Serial.print("\n");
    // Read data: Len = data length, Data = data byte(s)
    CAN0.readMsgBuf(&R_ID_Mask, &Len, Data);      

    // Determine if R_ID_Mask is standard (11 bits) or extended (29 bits)
    if((R_ID_Mask & 0x80000000) == 0x80000000){
        Serial.print("\n");
        Serial.print("Extended");
        R_ID=(R_ID_Mask & 0x0000FFFF);
        Data_MAJ(Data);
    }
    else{
        Serial.print("\n");
        Serial.print("Standart");
    }
}

void Transmit_Discrete(){
    T_ID=0x1000;
    byte Trans[8]={TRANS_PIN_4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};
    tmillis=millis();
    if ((digitalRead(TRANS_PIN_4)==HIGH) * ((tmillis>(T_D_Millis+T_Time)))){
        Serial.print("\n");
        T_D_Millis=millis();
        Send=CAN0.sendMsgBuf(T_ID, 1, 8, Trans);
        if(Send == CAN_OK){
            Serial.print("\n");
            Serial.print("Send:");
            Serial.print("\t");
            for(byte i = 0; i<8; i++)
            {
                sprintf(Print, " 0x%.2X", Trans[i]);
                Serial.print(Print);
            } 
        } 
        else {
            Serial.print("\n");
            Serial.println("Sending Error");
        }
    }
}

void Transmit_Continuous(){
    T_ID=0x1001;
    byte Trans[8]={0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};
    if (millis()>(T_C_Millis+T_Time)){
        Serial.print("\n");
        T_C_Millis=millis();
        Send=CAN0.sendMsgBuf(T_ID, 1, 8, Trans);
        if(Send == CAN_OK){
            Serial.print("\n");
            Serial.print("Send:");
            Serial.print("\t");
            for(byte i = 0; i<8; i++)
            {
                sprintf(Print, " 0x%.2X", Trans[i]);
                Serial.print(Print);
            } 
        } 
        else {
            Serial.print("\n");
            Serial.println("Sending Error");
        }
    }
}

// Led Strip Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

// Function to turn on the LEDs needed
// Strip.setPixelColor(index, red, green, blue);


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
    
    // On met les variables à jour
    // If CAN0_INT pin is low, read receive buffer
    if(!digitalRead(CAN0_INT)){   

        // On recoit et on traite les données
        Recieve();
        
        // MAJ RPM Bar
        Tachometer(Rpm,Gear);
    }
    Transmit_Discrete();
    Transmit_Continuous();
}
