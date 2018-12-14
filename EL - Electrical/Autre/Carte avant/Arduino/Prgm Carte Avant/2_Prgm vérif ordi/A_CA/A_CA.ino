#include <SPI.h>
#include <mcp_can.h>

// Defintion of the pins
// Set INT to pin 2
#define CAN0_INT 2 
// Set CS to pin 10
MCP_CAN CAN0(10); 
const int DATAPIN = 1;
const int CLOCKPIN = 3;


char Print[128];  


const int H_PIN=12;   // Homing
const int N_PIN=6;   // Neutre


int Switch_H;
int Switch_N;

byte Modif[8];
byte Null[8];

unsigned long tmillis=millis();
unsigned long T_D_Millis=millis();
int T_Time=1000;

void setup() {
    // put your setup code here, to run once:
    pinMode(H_PIN,INPUT);
    pinMode(N_PIN,INPUT);



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

void Send_CA(int Switch_H, int Switch_N){
    Switch_H=digitalRead(H_PIN);
    Switch_N=digitalRead(N_PIN);

    sprintf(Print, "Switch_H = %1d   Switch_N = %1d", Switch_H, Switch_N);
    Serial.print("\n");
    Serial.print(Print);
    
    // Def des messages
    byte Modif[8]={0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    byte Null[8]={0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    tmillis=millis();
    if(tmillis>(T_D_Millis+T_Time)){ // Envoie discret de période T_Time
        T_D_Millis=millis();
        if(Switch_H==0){
            CAN0.sendMsgBuf(0x1000, 1, 8, Null);
        }
        if(Switch_H==1){
            CAN0.sendMsgBuf(0x1000, 1, 8, Modif);
        }
        if(Switch_N==0){
            CAN0.sendMsgBuf(0x1001, 1, 8, Null);
        }
        if(Switch_N==1){
            CAN0.sendMsgBuf(0x1001, 1, 8, Modif);
        }
    }
}

void loop() {
    // put your main code here, to run repeatedly:
    
    Send_CA(Switch_H, Switch_N);

    delay(100);
}
