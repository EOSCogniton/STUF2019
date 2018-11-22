// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>
#include "Adafruit_MCP23008.h"

Adafruit_MCP23008 mcp;

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2
// Set CS to pin 10
MCP_CAN CAN0(10); 



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
const int PINS_GEAR[5][7]={
  {0,0,0,1,0,0,0},
  {0,1,1,1,1,1,0},
  {1,0,0,0,1,0,0},
  {0,0,1,0,1,0,0},
  {0,1,1,0,0,1,0},
};

// Temp Voltage (TV) display
int Switch_TV;

//0 turns on, 1 turns off
const int PINS_R1[10][8]={
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
const int PINS_R2[10][8]{
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

void setup(){
    // PIN Settup
    pinMode(1,INPUT);


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

void loop(){
  
    // Read the Switch position
    Switch_TV=digitalRead(1);
    
    // On met les variables à jour
    // If CAN0_INT pin is low, read receive buffer
    if(!digitalRead(CAN0_INT)){   

        // On recoit et on traite les données
        Recieve();
    }

    
}
