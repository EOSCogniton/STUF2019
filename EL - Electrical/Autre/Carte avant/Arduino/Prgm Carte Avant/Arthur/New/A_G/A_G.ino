#include "Adafruit_MCP23008.h"

Adafruit_MCP23008 mcp;

signed Gear=0;
int Init_Seven_Segments;
const int PINS_GEAR[5][7]={
  {0,0,0,1,0,0,0},
  {0,1,1,1,1,1,0},
  {1,0,0,0,1,0,0},
  {0,0,1,0,1,0,0},
  {0,1,1,0,0,1,0},
};

void Gear_MAJ(signed Gear){
  mcp.begin(0);
  for(int i=0;i<=6;i++){
    mcp.pinMode(i,OUTPUT);
    mcp.digitalWrite(i,PINS_GEAR[Gear][i]);
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
  Gear_MAJ(Gear);
}
