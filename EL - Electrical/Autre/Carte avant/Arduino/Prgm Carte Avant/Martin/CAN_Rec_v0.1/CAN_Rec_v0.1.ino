// liens utiles
// https://github.com/Seeed-Studio/CAN_BUS_Shield

// Info DTA p91

#include <SPI.h>
#include "mcp_can.h"

// définition des PIN
const int SPI_CS_PIN = 9; // A MODIFIER

// définition des variables
unsigned long ID; // stock l'ID du CAN
unsigned char len;
char Datach[4]; // stock les données recues du CAN                                                    // Attention c'est un char il faut le convertir avant les test
int Dataint[4];

// variables de tableau de bord
int RPM; //RPM
int WTemp; //Water Temp C
int Volts; //Volts x10

MCP_CAN CAN(SPI_CS_PIN); // Set CS pin

// initialisation du CAN
void setup()
{
    Serial.begin(115200);

    while (CAN_OK != CAN.begin(CAN_1000KBPS)) // initialisation du CAN à 1000KBPS
    {
        Serial.println("CAN BUS Shield init fail");
        Serial.println("Init CAN BUS Shield again");
        delay(100);
    }
    Serial.println("CAN BUS Shield init ok!");
}

void DataMAJ(char data[4]){                                                                         // Attention c'est un char il faut le convertir avant les test
    // on convertit les char en int
    Dataint[1]=int(Datach[1]);
    Dataint[2]=int(Datach[2]);
    Dataint[3]=int(Datach[3]);
    Dataint[4]=int(Datach[4]);
    // en fonction de l'ID, on met à jour différents paramètres
    if(ID=2000){
      RPM=data[1];
      WTemp=data[3];
    }
    if(ID=2002){
      Volts=data[3];
    }
    return;
}

void loop(){
    if(CAN.checkReceive()){

      // on pilote ici ce qui se passe après la réception du CAN
      ID=CAN.getCanId();
      CAN.readMsgBuf(&len, Datach);
      DataMAJ(Datach); // on met les variables à jour
    }
}




















// fin code
