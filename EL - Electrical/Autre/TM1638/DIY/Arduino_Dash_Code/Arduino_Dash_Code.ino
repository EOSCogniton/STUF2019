#include <TM1638.h>

//STB -- D9
//CLK -- D7
//DI0 -- D8

int disp=1; // display: 0=off, 1=on
int bright=7; // brightness: 0 to 7

TM1638 module(8,7,9,disp,bright);

String Data;
int Led;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available()){
    Data=Serial.readStringUntil('\x0?');
    module.setDisplayToString(Data, 0xFF, 0); 
    module.setLEDs(0x00);
    Led=Data[8]-48;
    for(int i=0; i<Led; i++){
      module.setLED(1,i);
    }
  }
}
