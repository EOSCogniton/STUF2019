#include <SPI.h>
#include <mcp_can.h>

// Defintion of the pins
#define CAN0_INT 2
// Set CS to pin 10
MCP_CAN CAN0(10);

// 
long unsigned int R_ID_Mask;
long unsigned int R_ID;
unsigned char Len = 0;
unsigned char Data[8];
char Print[128];

//
signed Data1;
signed Data2;
signed Data3;
signed Data4;

void setup() {
    // put your setup code here, to run once:
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

void Recieve(){
    Serial.print("\n");
    // Read data: Len = data length, Data = data byte(s)
    CAN0.readMsgBuf(&R_ID_Mask, &Len, Data);      

    // Determine if R_ID_Mask is standard (11 bits) or extended (29 bits)
    if((R_ID_Mask & 0x80000000) == 0x80000000){
        Serial.print("\n");
        Serial.print("Extended ");
        R_ID=(R_ID_Mask & 0x0000FFFF);
        Serial.print(R_ID);
    }
    else{
        Serial.print("\n");
        Serial.print("Standart");
    }
    Data1=Data[0]+256*Data[1];
    Data2=Data[2]+256*Data[3];
    Data3=Data[4]+256*Data[5];
    Data4=Data[6]+256*Data[7];
    
    sprintf(Print, "Data1 = %5d   Data2 = %5d   Data3 = %5d    Data4 = %5d", Data1, Data2, Data3, Data4);
    Serial.print("\n");
    Serial.print(Print);
}

void loop() {
    // put your main code here, to run repeatedly:
    if(!digitalRead(CAN0_INT)){   
        // Variables are received and processed
        Recieve();
    }
}
