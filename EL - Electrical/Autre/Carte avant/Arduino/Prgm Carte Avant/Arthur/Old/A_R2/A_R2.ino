// CAN Receive Example
//

#include <mcp_can.h>
#include <SPI.h>

long unsigned int rxId;
long unsigned int rxId1;
unsigned char len = 0;
unsigned char rxBuf[8];
char msgString[128];                        // Array to store serial string

#define CAN0_INT 2                              // Set INT to pin 2
MCP_CAN CAN0(10);                               // Set CS to pin 10


void setup()
{
  Serial.begin(115200);
  
  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
  if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK)
    Serial.println("MCP2515 Initialized Successfully!");
  else
    Serial.println("Error Initializing MCP2515...");
  
  CAN0.setMode(MCP_NORMAL);                     // Set operation mode to normal so the MCP2515 sends acks to received data.

  pinMode(CAN0_INT, INPUT);                            // Configuring pin for /INT input
  
  Serial.println("MCP2515 Library Receive Example...");
}

void loop()
{
  if(!digitalRead(CAN0_INT))                         // If CAN0_INT pin is low, read receive buffer
  {
    CAN0.readMsgBuf(&rxId, &len, rxBuf);      // Read data: len = data length, buf = data byte(s)
    
    if((rxId & 0x80000000) == 0x80000000)     // Determine if ID is standard (11 bits) or extended (29 bits)
      sprintf(msgString, "Extended ID: 0x%.8lX  DLC: %1d  Data:", (rxId & 0x1FFFFFFF), len);
      
    else
      sprintf(msgString, "Standard ID: 0x%.3lX       DLC: %1d  Data:", rxId, len);
  
    Serial.print(msgString);
  
    if((rxId & 0x40000000) == 0x40000000)
    {    // Determine if message is a remote request frame.
      sprintf(msgString, " REMOTE REQUEST FRAME");
      Serial.print(msgString);
    } 
    else {
            for(byte i = 0; i<len; i++)
            {
            sprintf(msgString, " 0x%.2X", rxBuf[i]);
            Serial.print(msgString);
            } 
          }
     rxId1=(rxId & 0x0000FFFF);
     if(rxId1 == 0x2000){
                         signed RPM=rxBuf[1]+256*rxBuf[0];
                         signed TPS=rxBuf[3]+256*rxBuf[2];
                         signed TWater= rxBuf[5]+256*rxBuf[4];
                         signed TAir=rxBuf[7]+256*rxBuf[6];
                         Serial.println();
                         Serial.println();
                         Serial.println ("RPM = ");
                         Serial.print (RPM);
                         Serial.println();
                         Serial.println ("Throttle = ");
                         Serial.print (TPS);
                          Serial.println();
                         Serial.println ("Temp Eau = ");
                         Serial.print (TWater);
                          Serial.println(); 
                         Serial.println ("Temp Air = ");
                         Serial.print (TAir);
                        }
      else if(rxId1 == 0x2001){
                         signed MAP=rxBuf[1]+256*rxBuf[0];
                         signed Lambda=rxBuf[3]+256*rxBuf[2];
                         signed vCar= rxBuf[5]+256*rxBuf[4];
                         signed pOil=rxBuf[7]+256*rxBuf[6];
                         Serial.println();
                         Serial.println();
                         Serial.println ("MAP = ");
                         Serial.print (MAP);
                         Serial.println();
                         Serial.println ("Lambda = ");
                         Serial.print (Lambda);
                          Serial.println();
                         Serial.println ("Vitesse = ");
                         Serial.print (vCar);
                          Serial.println(); 
                         Serial.println ("Pression Huile = ");
                         Serial.print (pOil);
                        }       
     Serial.println();
   
     Serial.println();
  }
}

/*********************************************************************************************************
  END FILE
*********************************************************************************************************/
