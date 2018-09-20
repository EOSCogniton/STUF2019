

//Code carte avant
//CAN
#include <SPI.h>
#include <mcp_can.h>


#include "Adafruit_TLC5947.h"

// définition du LED driver
#define NUM_TLC5974 1 // mettre une résistance de 800 Ohm sur le deuxième shield pour un courant de 20 mA
                      // pour le premier shield il faut mesurer le courant dans les LED
#define data   4
#define clock   5
#define latch   6
#define oe  -1  // set to -1 to not use the enable pin (its optional)

Adafruit_TLC5947 tlc = Adafruit_TLC5947(NUM_TLC5974, clock, data, latch);

//choix des pins 
int pinRPM[10] = {0,1,2,3,4,5,6,7,8,9}; 
int pinRapport[7] = {24,25,26,23,24,25,26}; // dans l'ordre a,b,c,d,e,f,g (voir une image de 7 segments)
int pinTemp1[7] = {27,28,29,30,31,32,33}; //unités
int pinTemp2[7] = {34,35,36,37,38,39,40}; //dizaines
int pinTemp3 = 41; //pour le 1 des centaine

//variables
int RPM =0 ;
int Rapport;
int Temp ;
int oilP;
boolean RAZ;
boolean neutre;

const int pinRAZ = 14;
const int pinNeutre = 15;

//constante pour affichage
const int ETATS_SEGMENTS[10][7] = {
  {1,1,1,1,1,1,0},  //0
  {0,1,1,0,0,0,0}, //1
  {1,1,0,1,1,0,1},  //2
  {1,1,1,1,0,0,1},  //3
  {0,1,1,0,0,1,1},  //4
  {1,0,1,1,0,1,1}, //5
  {1,0,1,1,1,1,1}, //6
  {1,1,1,0,0,0,0},  //7
  {1,1,1,1,1,1,1},  //8
  {1,1,1,1,0,1,1}  //9
};

int E[7] = {1,0,0,1,1,1,1};
int P[7] = {1,1,0,1,1,1,1};
int A[7] = {1,1,1,0,1,1,1};


//CAN
//MCP_CAN CAN(53);
//unsigned char Flag_Recv = 0;
//long unsigned int rxId;
//unsigned char len =0;
//unsigned char buf[8];
//char str[128];




 void allumerLED(int n) {
  for (int i=0 ; i<10; i++) {
    if (i<=n) {
      tlc.setPWM(pinRPM[i],4095);
     }
    else {
      tlc.setPWM(pinRPM[i],0);
      }
  }
  tlc.write();
  }

void compteT(int RPM) {
   if (RPM<1000){
      allumerLED(0);       
      }
   else if (RPM>=1000 && RPM<4000){
      allumerLED(1);
      }
   else if (RPM>=4000 && RPM<6000){
      allumerLED(2);
      }
   else if (RPM>=6000 && RPM<7000){
      allumerLED(3);
      }
   else if (RPM>=7000 && RPM<8000){
      allumerLED(4);
      }
    else if (RPM>=8000 && RPM<9000){
      allumerLED(5);
      }
    else if (RPM>=9000 && RPM<10000){
      allumerLED(6);
      }
    else if (RPM>=10000 && RPM<11000){
      allumerLED(7);
      }
    else if (RPM>=11000 && RPM<12000){
      allumerLED(8);
      }
    else if (RPM>=12000 && RPM<13000){
      allumerLED(9);
      }
    else {
      allumerLED(10);
      }
 }
 

  
 void segments (int n, int L[7]) {
  for (int i=0; i<=6; i++) {
    tlc.setPWM(L[i],ETATS_SEGMENTS[n][i]*4095);
    }
    tlc.write();
}

void afficheTemp (int temp ) {
  if (temp>=100) {
    tlc.setPWM(pinTemp3,4095);
    temp=temp-100;
    }
   else { 
     tlc.setPWM(pinTemp3,0);
     }
     tlc.write();
    char unite = 0, dizaine = 0; // variable pour chaque afficheur

    if(temp > 9) // si le nombre reçu dépasse 9
    {
        dizaine = temp / 10; // on récupère les dizaines
    }
    unite = temp - dizaine*10;
    
    segments(dizaine,pinTemp2);
    segments(unite,pinTemp1);
}

void epsa() {
    for (int i=1 ; i<=10; i++) {
      allumerLED(i);
      delay(100);
    }
    for (int i=0; i<=7; i++) {
      tlc.setPWM(pinRapport[i],E[i]*4095);
    }
    tlc.write();
    delay(300);
    for (int i=1 ; i<=10; i++) {
      allumerLED(i);
      delay(100);
    }
    for (int i=0; i<=9; i++) {
      tlc.setPWM(pinRapport[i],P[i]*4095);
    }
    tlc.write();
    delay(300);
    for (int i=1 ; i<=10; i++) {
      allumerLED(i);
      delay(100);
    }
    for (int i=0; i<=9; i++) {
      tlc.setPWM(pinRapport[i],ETATS_SEGMENTS[5][i]*4095);
    }
    tlc.write();
    delay(300);
    for (int i=1 ; i<=10; i++) {
      allumerLED(i);
      delay(100);
    }
    for (int i=0; i<=9; i++) {
      tlc.setPWM(pinRapport[i],A[i]*4095);
    }
    tlc.write();
    delay(500);
  }
    

  void setup() {
  
      //initialisation canbus
  Serial.begin(9600);
  
//START_INIT:
//  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
//  if(CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK){
//    Serial.println("MCP2515 Initialized Successfully!");}
//  else {
//    Serial.println("Error Initializing MCP2515...");
//    goto START_INIT;
//    }
//  
//  CAN.setMode(MCP_NORMAL);                     // Set operation mode to normal so the MCP2515 sends acks to received data.
//  
//        
//    Serial.println();
 
  
  //ouverture de la liaison avec les TLC
  Serial.println("TLC5974 test");
  tlc.begin();
  if (oe >= 0) {
    pinMode(oe, OUTPUT);
    digitalWrite(oe, LOW);
  }
  
  allumerLED(10);
  delay(1000);
}
  
void loop() {
//envoyer can BUS 
//if (millis()>=temps_can + refresh_can){
//  unsigned char stmp[8] = {RAZ,neutre,0,0,0,0,0,0};
//  CAN.sendMsgBuf(0x30, 0, 8, stmp);
//  temps_can = millis();
//  }
  
  //recevoir CAN
//  for (int i=1; i<3; i++){
//      
//    CAN.readMsgBuf(&rxId, &len, buf);      // Read data: len = data length, buf = data byte(s)
////     Serial.println(rxId);
////     Serial.println(buf);
//      if (rxId == 0x2000) {
//        RPM = buf[1];
//        Temp=buf[3];
//        }
//        else if (rxId = 0x2001) {
//          oilP = buf[2];
//          }
//        else if (rxId = 0x2003){
//          Rapport = buf[1];
//          }
//      }
      Serial.println("golloop");
      allumerLED(RPM%11);
      RPM=RPM+1;
      delay(1000);
}

