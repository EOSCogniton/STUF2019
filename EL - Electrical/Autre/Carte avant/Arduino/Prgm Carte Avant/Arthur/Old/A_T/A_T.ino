// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>
#include <Adafruit_DotStar.h>
#include "Adafruit_MCP23008.h"
#include <Wire.h>

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 
const int DATAPIN = 1;
const int CLOCKPIN = 3;
// Set Transmission Pin
const int TRANS_PIN_4 = 4; // à vérif

// Transmit variables init
long unsigned int T_ID;
byte Trans[8];
byte Send;
unsigned long tmillis=millis();
unsigned long T_D_Millis=millis();
unsigned long T_C_Millis=millis();
int T_Time=1000;

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



void loop(){
    Transmit_Discrete();
    Transmit_Continuous();
}
