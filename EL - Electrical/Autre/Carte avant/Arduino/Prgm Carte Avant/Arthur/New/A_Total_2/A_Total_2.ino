// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>
#include "Adafruit_MCP23008.h"
#include <Adafruit_DotStar.h>

Adafruit_MCP23008 mcp;

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2
// Set CS to pin 10
MCP_CAN CAN0(10); 
// Led pins
const int DATAPIN = 4;
const int CLOCKPIN = 5;
// T-V
const int TV_PIN=3;
// Carte Arrière Comm
const int H_PIN=12;   // Homing
const int N_PIN=6;   // Neutre
// Launch Control
int LC_SWITCH_PIN=7; // Pin à cahnger
int LC_LED_PIN=8;



// Recieve variables init
long unsigned int R_ID_Mask;
long unsigned int R_ID;
unsigned char Len = 0;
unsigned char Data[8];
char Print[128];  



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



// Gear display
int Init_Seven_Segments;
const boolean PINS_GEAR[5][7]={
  {0,0,0,1,0,0,0},
  {0,1,1,1,1,1,0},
  {1,0,0,0,1,0,0},
  {0,0,1,0,1,0,0},
  {0,1,1,0,0,1,0},
};



// Temp Voltage (TV) display
int Switch_TV;



//0 turns on, 1 turns off
const boolean PINS_R1[10][8]={
  {1,0,0,0,0,0,0,0},  //0
  {1,0,1,1,1,1,0,0},  //1
  {0,1,0,0,1,0,0,0},  //2
  {0,0,0,1,1,0,0,0},  //3
  {0,0,1,1,0,1,0,0},  //4
  {0,0,0,1,0,0,1,0},  //5
  {0,0,0,0,0,0,1,0},  //6
  {1,0,1,1,1,0,0,0},  //7
  {0,0,0,0,0,0,0,0},  //8
  {0,0,0,1,0,0,0,0},  //9
// G C D E F A B PD     Pins of the 7 segments corresponding to the x1 (PD is the point of x10)
};
const boolean PINS_R2[10][8]{
  {0,0,0,0,1,0,0,0},  //0
  {0,1,0,1,1,0,1,1},  //1
  {0,0,0,1,0,1,0,0},  //2
  {0,0,0,1,0,0,0,1},  //3
  {0,1,0,0,0,0,1,1},  //4
  {1,0,0,0,0,0,0,1},  //5
  {1,0,0,0,0,0,0,0},  //6
  {0,0,0,1,1,0,1,1},  //7
  {0,0,0,0,0,0,0,0},  //8
  {0,0,0,0,0,0,0,1},  //9
// B A 1 F G C D E      Pins of the 7 segments corresponding to the x10 (1 is the 1 of the x100)
};



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
int Blink_Time=75;
int Blink_Led; // 0=off - 1=on
unsigned long Start_Led_Millis;
unsigned long Current_Led_Millis;



// Led Strip Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

// Function to turn on the LEDs needed
// Strip.setPixelColor(index, green, red, blue);



// Carte Arrière Comm
int Switch_H;
int Switch_N;

byte Modif[8];
byte Null[8];



// Transmit var
unsigned long tmillis=millis();
unsigned long T_D_Millis=millis();
int T_Time=1000;



// Launch Control
int Switch_LC=0;
int Limit_LC=30; // Max LC Speed
boolean Led_LC=0;



void setup(){
    // PIN Settup
    pinMode(TV_PIN,INPUT);

    pinMode(H_PIN,INPUT);
    pinMode(N_PIN,INPUT);

    pinMode(LC_SWITCH_PIN,INPUT); 
    pinMode(LC_LED_PIN,OUTPUT);

    // CAN Init
    Serial.begin(115200);
    // Initialize MCP2515 running at 16MHz with a baudrate of 1000kb/s and the masks and filters disabled
    if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK){
        Serial.println("CAN Init Successfully!");}
    else{
        Serial.println("CAN Init Failure");}
    // Set operation mode to normal so the MCP2515 sends acks to received data
    CAN0.setMode(MCP_NORMAL);                  
    // Configuring pin for /INT input
    pinMode(CAN0_INT, INPUT); 

    // Turn Off all Seven Segment
    for(Init_Seven_Segments=0;Init_Seven_Segments<=2;Init_Seven_Segments++){ //This shuts off all segments at the begining
        mcp.begin(Init_Seven_Segments);
        for(int i=0;i<=7;i++){
            mcp.pinMode(i,OUTPUT);
            mcp.digitalWrite(i,1);
        }
        Serial.println("7 Segment Init Successfully!");
    }

    STRIP.begin();
    STRIP.show();
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
        Serial.print(R_ID);
        Data_MAJ(Data);
    }
    else{
        Serial.print("\n");
        Serial.print("Standart");
    }
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
        
        Seven_Seg_Calc(Switch_TV,W_Temp,Volts);
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
        
        Seven_Seg_Calc(Switch_TV,W_Temp,Volts);
    }
    if(R_ID==0x2003){
        Gear=Data[1]+256*Data[0];
        
        sprintf(Print, "Gear = %1d", Gear);
        Serial.print("\n");
        Serial.print(Print);

        Gear_MAJ(Gear);
    }
    return;
}

void Gear_MAJ(signed Gear){
  mcp.begin(0);
  for(int i=0;i<=6;i++){
    mcp.pinMode(i,OUTPUT);
    mcp.digitalWrite(i,PINS_GEAR[Gear][i]);
  }
}

void Seven_Seg_Calc(int Switch_Temp_Volt,int W_Temp,int Volts){
  switch(Switch_Temp_Volt){
    case 0: //Water Temperature
      TV_MAJ(1,W_Temp%10,6);
      W_Temp=W_Temp/10;
      TV_MAJ(2,W_Temp,6);
      break;
    case 1:  //Voltage
      TV_MAJ(1,Volts%10,7);
      Volts=Volts/10;
      TV_MAJ(2,Volts,7);
      break;
  }
}

void TV_MAJ(int Microcontroller_Number,int Digit,int Point){
  switch(Microcontroller_Number){
    case 1: //Numbers x1 + point (microcontroller 1)
        mcp.begin(1);
        for(int i=0;i<=Point;i++){
          mcp.pinMode(i,OUTPUT);
          mcp.digitalWrite(i,PINS_R1[Digit][i]);
        }
      break;
    case 2: //Numbers x10 + 1x100 (microcontroller 2)
        mcp.begin(2);
        if(Digit<=9){
          for(int i=0;i<=7;i++){
            if(i!=2){  //Jump colone 2 because it has the 1x100
              mcp.pinMode(i,OUTPUT);
              mcp.digitalWrite(i,PINS_R2[Digit][i]);
            }
          }
        }
        else{
          for(int i=0;i<=7;i++){
            mcp.pinMode(i,OUTPUT);
            mcp.digitalWrite(i,PINS_R2[Digit-10][i]);
          }
        }
      break;
  }
}

void Tachometer (int Rpm,int Gear){
    Rpm_Ratio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUM_PIXELS+1);
    Rpm_Ratio_Corr = Rpm-RPM_MIN_MAX[0][Gear];
    if(Rpm_Ratio_Corr>(NUM_PIXELS+1)*Rpm_Ratio){
        Led_MAJ(NUM_PIXELS+1,Gear);
    }
    else{
        for(int i=0 ; i<=NUM_PIXELS ; i++){
            if(i*Rpm_Ratio<=Rpm_Ratio_Corr && Rpm_Ratio_Corr<=(i+1)*Rpm_Ratio){
                Led_MAJ(i,Gear);
            }
        }
    }
}

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
            Blink_Count=0;
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
            Blink_Count=0;
            for(int i=0 ; i<NUM_PIXELS ; i++){
                if(i<=Led_Number){
                    STRIP.setPixelColor(i,255,0,0);
                }
                else{
                    STRIP.setPixelColor(i,0,0,0);
                }
            }
        }
        else if(Led_Number==0){
            for(int i=0; i<NUM_PIXELS ; i++){
                STRIP.setPixelColor(i,0,0,0);
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

    sprintf(Print, "RPM = %5d   Blink_Count = %2d   Blink_Led = %1d", Rpm, Blink_Count, Blink_Led);
    Serial.print("\n");
    Serial.print(Print);
}

void Send_CA(){
    Switch_H=digitalRead(H_PIN);
    Switch_N=digitalRead(N_PIN);

    sprintf(Print, "Switch_H = %1d   Switch_N = %1d", Switch_H, Switch_N);
    Serial.print("\n");
    Serial.print(Print);
    
    // Def des messages
    byte Modif[8]={0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    byte Null[8]={0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    tmillis=millis();
    if(tmillis>(T_D_Millis+T_Time)){ // Envoie discret de période T_Time
        T_D_Millis=millis();
        if(Switch_H==0){
            CAN0.sendMsgBuf(0x1000, 1, 8, Null);
        }
        if(Switch_H==1){
            CAN0.sendMsgBuf(0x1000, 1, 8, Modif);
        }
        if(Switch_N==0){
            CAN0.sendMsgBuf(0x1001, 1, 8, Null);
        }
        if(Switch_N==1){
            CAN0.sendMsgBuf(0x1001, 1, 8, Modif);
        }
    }
}

void State_LC(int Kph){

    Switch_LC=digitalRead(LC_SWITCH_PIN); 
  
    sprintf(Print, "Switch_LC = %1d   KPH = %3d   Led_LC = %1d", Switch_LC, Kph, Led_LC);
    Serial.print("\n");
    Serial.print(Print);
    
    if(Switch_LC==1 && Kph<Limit_LC){
        Led_LC=1;
        digitalWrite(LC_LED_PIN,HIGH);
    }
    if(Kph>Limit_LC){
        Led_LC=0;
        digitalWrite(LC_LED_PIN,LOW);
    }
}

void loop(){
  
    // Read the Switch position
    Switch_TV=digitalRead(TV_PIN);
    
    // On met les variables à jour
    // If CAN0_INT pin is low, read receive buffer
    if(!digitalRead(CAN0_INT)){   

        // On recoit et on traite les données
        Recieve();
        Send_CA();
        Tachometer(Rpm,Gear);
        State_LC(Kph);
    }
}
