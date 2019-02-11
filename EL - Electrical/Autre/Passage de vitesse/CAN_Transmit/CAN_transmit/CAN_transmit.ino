/// Library
#include <SPI.h>
#include <mcp_can.h>

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 

// R_ID=0x1002
int Gear; // Vitesse engagée

unsigned long tmillis=millis();
unsigned long T_D_Millis=millis();
int T_Time=200;


void setup(){
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
}

void Send_CA(){

    // Def des messages
    byte Gear_msg[8]={Gear, Gear, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    tmillis=millis();
    if(tmillis>(T_D_Millis+T_Time)){ // Envoie discret de période T_Time
        T_D_Millis=millis();
        CAN0.sendMsgBuf(0x1002, 1, 8, Gear_msg);
    }
}
