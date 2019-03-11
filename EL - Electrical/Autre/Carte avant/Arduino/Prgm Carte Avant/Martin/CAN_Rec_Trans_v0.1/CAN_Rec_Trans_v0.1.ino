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
unsigned char len;
char Datach[4]; // stock les données recues du CAN
int Dataint[4];
unsigned char Homingch;

// dashboard variables
int Rpm; //Rpm
int Gear;
int WTemp; //Water Temp C
int Volts; //Volts x 10

// buttons
int Homingint = 0;

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
    Dataint[1]=int(Datach[1]);
    Dataint[2]=int(Datach[2]);
    Dataint[3]=int(Datach[3]);
    Dataint[4]=int(Datach[4]);
    // update the variables
    if(ID=2000){
      Rpm=data[1];
      WTemp=data[3];
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
        CAN.readMsgBuf(&len, Datach);
        DataMAJ(Datach); // update the variables
    }

    // add the homing button and the connection to the rear card
    Homing=digitalRead(HOMING_PIN);
    Homingch=char(Homingint);
    CAN.sendMsgBuf(1000, 1, Homingch);
}




















// fin code
