// CAN
#include <SPI.h>
#include <mcp_can.h>

// TM1638
#include <TM1638.h>

// CAN wiring
#define CAN0_INT 2 // Set INT to pin 2
MCP_CAN CAN0(10); // Set CS to pin 10

// TM1638 wiring
//STB -- D9
//CLK -- D7
//DI0 -- D8

// TM1638 setup
int disp=1; // display: 0=off, 1=on
int bright=7; // brightness: 0 to 7
TM1638 module(8,7,9,disp,bright);

// Variables init
// Recieve variables
long unsigned int R_ID_Mask;
long unsigned int R_ID;
unsigned char Len = 0;
unsigned char Data[8];
char Print[128]; 
// Data variables
signed Gear=0;
signed Rpm;
signed Kph; // x10
// Led Display variables
int Led_Disp;


void setup(){
    // CAN Init
    Serial.begin(115200);
    // Initialize MCP2515 running at 16MHz with a baudrate of 1000kb/s and the masks and filters disabled
    if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK){
        Serial.println("CAN Init Successfully");}
    else{
        Serial.println("CAN Init Failure");}
    // Set operation mode to normal so the MCP2515 sends acks to received data
    CAN0.setMode(MCP_NORMAL);                  
    // Configuring pin for /INT input
    pinMode(CAN0_INT, INPUT);
    // Display ini
    module.setDisplayToString("UULCANIX", 0x00, 0);
    delay(1000);
}

void Recieve(){
    Serial.print("\n");
    // Read data: Len = data length, Data = data byte(s)
    CAN0.readMsgBuf(&R_ID_Mask, &Len, Data);      

    // Determine if R_ID_Mask is standard (11 bits) or extended (29 bits)
    if((R_ID_Mask & 0x80000000) == 0x80000000){
        Serial.print("\n");
        Serial.print("Extended");
        R_ID=(R_ID_Mask & 0x0000FFFF);
        Serial.print(R_ID);
        Data_MAJ(Data);
    }
    else{
        Serial.print("\n");
        Serial.print("Standart");
    }
}

void Data_MAJ(unsigned char Data[8]){  
    if(R_ID==0x1002){
      Gear=Data[0];
      
      sprintf(Print, "Gear = %1d", Gear);
      Serial.print("\n");
      Serial.print(Print);
    }
    
    if(R_ID==0x2000){
        Rpm=Data[1]+256*Data[0];
        
        sprintf(Print, "RPM = %5d", Rpm);
        Serial.print("\n");
        Serial.print(Print);
        
        Digit_Display();
        Led_Display();
    }
    
    if(R_ID==0x2001){
        Kph=Data[5]+256*Data[4];
        
        sprintf(Print, "KPH = %3d", Kph);
        Serial.print("\n");
        Serial.print(Print);
    }
    return;
}

void Digit_Display(){
    // Digit display
    module.setDisplayToDecNumber(Rpm, 0x00);
}

void Led_Display(){
    Led_Disp=0;
    for(int i=0; i<8; i++){
        if(Rpm>(6000+i*1000)){
            Led_Disp=i;
        }
    }

    sprintf(Print, "Led_Disp = %1d", Led_Disp);
    Serial.print("\n");
    Serial.print(Print);
    
    module.setLEDs(0x00);
    for(int i=0; i<Led_Disp; i++){
        module.setLED(1,i);
    }
}

void loop() {
    if(!digitalRead(CAN0_INT)){   
        // On recoit et on traite les donnÃ©es
        Recieve();
    }
}

