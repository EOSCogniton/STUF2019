// CAN_Rec_4

#include <SPI.h>
#include <mcp_can.h>

// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 

// Variables init
long unsigned int ID_Mask;
long unsigned int ID;
unsigned char Len = 0;
unsigned char Data[8];
char Print[128];  


// Data variables
// ID=0x2000
signed Rpm;
signed TPS; // %
signed W_Temp;
signed A_Temp;
// ID=0x2001
signed Lambda; // x1000
signed Kph; // x10
signed O_Press;
// ID=0x2002
signed F_Press;
signed O_Temp;
signed Volts; // x10
// ID=0x2003
signed Gear;



void setup(){
    Serial.begin(115200);
  
    // Initialize MCP2515 running at 16MHz with a baudrate of 1000kb/s and the masks and filters disabled
    if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK){
        Serial.println("Init Successfully!");
    }
    else{
        Serial.println("Init Failure");
    }

    // Set operation mode to normal so the MCP2515 sends acks to received data
    CAN0.setMode(MCP_NORMAL);                  

    // Configuring pin for /INT input
    pinMode(CAN0_INT, INPUT);                            
}

void Data_MAJ(unsigned char Data[8]){  
    if(ID==0x2000){
        Rpm=Data[1]+256*Data[0];
        TPS=Data[3]+256*Data[2];
        W_Temp=Data[5]+256*Data[4];
        A_Temp=Data[7]+256*Data[6];
        sprintf(Print, "RPM = %5d   Throttle = %3d   Water Temp = %3d    Air Temp = %3d", Rpm, TPS, W_Temp, A_Temp);
        Serial.print(Print);
        Serial.print("\n");
    }
    if(ID==0x2001){
        Lambda=Data[3]+256*Data[2];
        Kph=Data[5]+256*Data[4];
        O_Press=Data[7]+256*Data[6];
        sprintf(Print, "Lambda = %3d   KPH = %3d   Oil Press = %3d", Lambda, Kph, O_Press);
        Serial.print(Print);
        Serial.print("\n");
    }
    
    if(ID==0x2002){
        F_Press=Data[1]+256*Data[0];
        O_Temp=Data[3]+256*Data[2];
        Volts=Data[5]+256*Data[4];
        sprintf(Print, "Fuel Press = %3d   Oil Temp = %3d   Volts = %3d", F_Press, O_Temp, Volts);
        Serial.print(Print);
        Serial.print("\n");
    }
    if(ID==0x2003){
        Gear=Data[1]+256*Data[0];
        sprintf(Print, "Gear = %1d", Gear);
        Serial.print(Print);
        Serial.print("\n");
    }
    return;
}

void loop(){
    // If CAN0_INT pin is low, read receive buffer
    if(!digitalRead(CAN0_INT)){                         
        // Read data: Len = data length, Data = data byte(s)
        CAN0.readMsgBuf(&ID_Mask, &Len, Data);      
  
        // Determine if ID_Mask is standard (11 bits) or extended (29 bits)
        if((ID_Mask & 0x80000000) == 0x80000000){
            Serial.print("Extended");
            Serial.print("\n");
            ID=(ID_Mask & 0x0000FFFF);
            Data_MAJ(Data);
        }
        else{
            Serial.print("Standart");
            Serial.print("\n");
        }
    }
}
