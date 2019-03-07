#include "Adafruit_MCP23008.h"

// Connect pin #1 of the expander to Analog 5 (i2c clock)
// Connect pin #2 of the expander to Analog 4 (i2c data)
// Connect pins #3, 4 and 5 of the expander to ground/5V (address selection). 
// Connect pin #6 and 18 of the expander to 5V (power and reset disable)
// Connect pin #9 of the expander to ground (common ground)

int Switch_State; // 0=water temperature , 1=voltage
int W_Temp;
int Volts;
int Init_Seven_Segments;

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
  {0,0,1,1,0,0,0,0},  //9
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
  {0,0,0,0,0,0,1,1},  //9
// B A 1 F G C D E      Pins of the 7 segments corresponding to the x10 (1 is the 1 of the x100)
};

Adafruit_MCP23008 mcp;  //Function that controls the microcontrollers

void switchSegment(int Microcontroller_Number,int Digit,int Point){
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
  



void ThreeSevenSegment(int Switch_Temp_Volt,int W_Temp,int Volts){
  switch(Switch_Temp_Volt){
    case 0: //Water Temperature
      switchSegment(1,W_Temp%10,6);
      W_Temp=W_Temp/10;
      switchSegment(2,W_Temp,6);
      break;
    case 1:  //Voltage
      switchSegment(1,Volts%10,7);
      Volts=Volts/10;
      switchSegment(2,Volts,7);
      break;
  }
}



void setup() {
  for(Init_Seven_Segments=0;Init_Seven_Segments<=2;Init_Seven_Segments++){ //This shuts off all segments at the begining
    mcp.begin(Init_Seven_Segments);
    for(int i=0;i<=7;i++){
      mcp.pinMode(i,OUTPUT);
      mcp.digitalWrite(i,1);
    }
  }
}

void loop() {
  ThreeSevenSegment(Switch_State,W_Temp,Volts);
}
