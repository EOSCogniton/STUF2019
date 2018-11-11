#include "Adafruit_MCP23008.h"

Adafruit_MCP23008 mcp;

signed Gear;

int PINS_GEAR[5][7]={
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
}

void loop() {
  Gear_MAJ(Gear);
}
