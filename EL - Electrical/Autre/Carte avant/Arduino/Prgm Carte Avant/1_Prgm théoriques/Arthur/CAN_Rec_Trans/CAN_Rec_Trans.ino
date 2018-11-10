// liens utiles
// https://github.com/Seeed-Studio/CAN_BUS_Shield

// Info DTA p91

#include <SPI.h>
#include "mcp_can.h"

// définition des PIN
const int SPI_CS_PIN = 10; 
const int HOMING_PIN = 4; // à vérif

// définition des variables
unsigned long ID; // stock the ID of the CAN
unsigned char Len;
char Data_Ch[4]; // stock les données recues du CAN
int Data_Int[4];
unsigned char Homing_Ch;
int Homing_Int = 0;

// dashboard variables
int Rpm; //Rpm
int Gear;
int W_Temp; //Water Temp C
int Volts; //Volts x 10

MCP_CAN CAN(SPI_CS_PIN); // Set CS pin

// initialisation du CAN
void setup()
{
    Serial.begin(115200);

    while (CAN_OK != CAN.begin(CAN_1000KBPS)) // Initialisation of the CAN : 1000KBPS
    {
        Serial.println("CAN BUS Shield init fail");
        Serial.println("Init CAN BUS Shield again");
        delay(100);
    }
    Serial.println("CAN BUS Shield init ok!");
}

void DataMAJ(char data[4]){
    // char to int
    Data_Int[1]=int(Data_Ch[1]);
    Data_Int[2]=int(Data_Ch[2]);
    Data_Int[3]=int(Data_Ch[3]);
    Data_Int[4]=int(Data_Ch[4]);
    // update the variables
    if(ID=2000){
      Rpm=data[1];
      W_Temp=data[3];
    }
    if(ID=2002){
      Volts=data[3];
    }
    if(ID=2003){
      Gear=data[1];
    }
    return;
}

void loop(){
    // update the datas by reading the CAN
    if(CAN.checkReceive()){
        ID=CAN.getCanId();
        CAN.readMsgBuf(&Len, Data_Ch);
        DataMAJ(Data_Ch); // update the variables
    }

    // add the homing button and the connection to the rear card
    Homing=digitalRead(HOMING_PIN);
    Homing_Ch=char(Homing_Int);
    CAN.sendMsgBuf(1000, 1, Homing_Ch);
}




















// fin code
