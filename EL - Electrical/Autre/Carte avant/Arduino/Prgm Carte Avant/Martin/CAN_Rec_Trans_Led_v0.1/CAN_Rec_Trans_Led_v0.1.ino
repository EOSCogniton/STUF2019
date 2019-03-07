// liens utiles
// https://github.com/Seeed-Studio/CAN_BUS_Shield

// Info DTA p91

#include <SPI.h>
#include "mcp_can.h"
#include <Adafruit_DotStar.h>

// defintion of the pins
const int DATAPIN = 1;
const int CLOCKPIN = 2;
const int SPI_CS_PIN = 10; 
const int HOMING_PIN = 4; // à vérif

// definiton of the constant
const int NUM_PIXELS = 16; // defines the number of pixels in the strip
const int RPM_MIN_MAX[2][5] = {
  {    0, 9800, 9800, 9800, 9800},
  {12000,13500,12376,12000,12000}
}; // matrix with the min/max rpm to change gear

// definition of the variables
// CAN
unsigned long ID; // stock the ID of the CAN
unsigned char Len;

// Data
char Data_Ch[4]; // stock les données recues du CAN
int Data_Int[4];
// Homing
int Homing_Int = 0;
unsigned char Homing_Ch;

// Led
int Led_Number;
int Rpm_Ratio;
int Rpm_Ratio_Corr;
int Blink_Count=0;
int Blink_Time;
int Blink_Led; // 0=off - 1=on
unsigned long Prev_Millis;


// Dashboard variables
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

// Led STRIP Init
Adafruit_DotStar STRIP = Adafruit_DotStar(NUM_PIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BRG);

// Function to turn on the LEDs needed
// STRIP.setPixelColor(index, red, green, blue);
void LedMAJ (int Led_Number,int Gear){
  STRIP.show();
  if(Gear>=1){
    if(Led_Number==17){
      for(int i=0 ; i<NUM_PIXELS ; i++){
        STRIP.setPixelColor(i,255,255,255); 
      }
      if(Blink_Count=0){
        Prev_Millis=millis();
      }
      if(Blink_Count<=5){
        if(millis-Prev_Millis>Blink_Time){
          Blink_Led=abs(Blink_Led-1);
          if(Blink_Led=0){
            STRIP.show();
            Blink_Count++;
          }
        }
      } 
    }
    else if(Led_Number>=12 && Led_Number<=16){
      Blink_Count=0;
      for(int i=0 ; i<Led_Number ; i++){
        STRIP.setPixelColor(i,255,0,0);
      }
    }
    else if(Led_Number>=6 && Led_Number<=11){
      for(int i=0 ; i<Led_Number ; i++){
        STRIP.setPixelColor(i,255,255,0);
      }
    }
    else if(Led_Number<=5){
      for(int i=0 ; i<Led_Number ; i++){
        STRIP.setPixelColor(i,0,255,0);
      }
    }
  }
  else if(Gear==0){
    for(int i=0 ; i<=Led_Number ; i++){
      STRIP.setPixelColor(i,255,0,0);
    }
  }
}

void Tachometer (int Rpm,int Gear){
  Rpm_Ratio = (RPM_MIN_MAX[1][Gear]-RPM_MIN_MAX[0][Gear])/(NUM_PIXELS+1);
  Rpm_Ratio_Corr = Rpm-RPM_MIN_MAX[0][Gear];
  if(Rpm_Ratio_Corr>(NUM_PIXELS+1)*Rpm_Ratio){
    LedMAJ(NUM_PIXELS+1,Gear);
  }
  else{
    for(int i=1 ; i<=NUM_PIXELS ; i++){
      if(i*Rpm_Ratio<=Rpm_Ratio_Corr && Rpm_Ratio_Corr<=(i+1)*Rpm_Ratio){
        LedMAJ(i,Gear);
      }
    }
  }
}

void loop(){
    // update the datas by reading the CAN
    if(CAN.checkReceive()){
        ID=CAN.getCanId();
        CAN.readMsgBuf(&Len, Data_Ch);
        DataMAJ(Data_Ch); // update the variables
    }

    // add the homing button and the connection to the rear card
    if(digitalRead(HOMING_PIN)){
      Homing_Int=digitalRead(HOMING_PIN);
      Homing_Ch=char(Homing_Int);
      CAN.sendMsgBuf(1000, 0, 1, Homing_Ch);
    }

    // MAJ RPM Bar
    Tachometer(Rpm,Gear);
}




















// fin code
