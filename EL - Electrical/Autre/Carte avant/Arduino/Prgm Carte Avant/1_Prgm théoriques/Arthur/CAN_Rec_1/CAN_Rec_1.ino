// liens utiles
// https://github.com/Seeed-Studio/CAN_BUS_Shield

// Info DTA p91

#include <SPI.h>
#include "mcp_can.h"

// définition des PIN
const int SPI_CS_PIN = 9; // A MODIFIER

// définition des variables
unsigned long ID; // stock l'ID du CAN
unsigned char Len;
char Data_Ch[4]; // stock les données recues du CAN                                                    // Attention c'est un char il faut le convertir avant les test
int Data_Int[4];

// variables de tableau de bord
int Rpm; //Rpm
int Gear;
int W_Temp; //Water Temp C
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
    Data_Int[1]=int(Data_Ch[1]);
    Data_Int[2]=int(Data_Ch[2]);
    Data_Int[3]=int(Data_Ch[3]);
    Data_Int[4]=int(Data_Ch[4]);
    // en fonction de l'ID, on met à jour différents paramètres
    if(ID=2000){
      Rpm=data[1];
      Serial.println(Rpm)
      W_Temp=data[3];
      Serial.println(W_Temp)
    }
    if(ID=2002){
      Volts=data[3];
      Serial.println(Volts)
    }
    if(ID=2003){
      Gear=data[1];
      Serial.println(Gear)
    }
    return;
}

void loop(){
    if(CAN.checkReceive()){

      // on pilote ici ce qui se passe après la réception du CAN
      ID=CAN.getCanId();
      CAN.readMsgBuf(&Len, Data_Ch);
      DataMAJ(Data_Ch); // on met les variables à jour
    }
}




















// fin code
