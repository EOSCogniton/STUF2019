// CAN_Rec_4

#include <Wire.h>

// Data variables

// R_ID=0x2003
int Gear;

void setup(){
    Serial.begin(115200);
    Serial.println("OK");                       
}

void Gear_MAJ(signed Gear){
    Wire.begin(); //creates a Wire object
    Wire.beginTransmission(0x20); //begins talking to the slave device number 0Wire.write(0x00); //selects the IODIRA register
    Wire.write(0x00); //this sets all port A pins to outputs
    Wire.write(0x09); //selects the GPIO pins (code 09 corresponds to GIPO)
    switch(Gear){
        case 0:
            Wire.write(01110111); // turns on pins 0, 1, 2, 4, 5 and 6 of GPIO
            break;
        case 1:
            Wire.write(01000001);
            break;
        case 2:
            Wire.write(01101110);
            break;
        case 3:
            Wire.write(01101011);
            break;
        case 4:
            Wire.write(01011001);
            break;
    }
    Wire.endTransmission(0x20); //ends communication with the device
}

void loop(){
    // MAJ Gear
    Serial.print("Void loop");
    for(int Gear=0; Gear<=4; Gear++){
        Gear_MAJ(Gear);
        Serial.println(Gear);
    }
    
}
