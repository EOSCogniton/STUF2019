/***************************************************************************
   
   Function name: Grear_Update
   
   Author:        Martín Gómez-Valcárcel (MGV)
   
   Descriptions:  Grear_Update receives the gear the engine is in and, from
                  PINS_GEAR, determines which segments it has to illuminate
                  so that the pilot knows the gear he's in.
                            
***************************************************************************/
#include "Gear_Update.h"



/**************************************************************************/
//    Internal variables and constants used ONLY by the functions in this file
/**************************************************************************/

// Gear display
const boolean PINS_GEAR[5][7]={
  {0,0,0,1,0,0,0},
  {0,1,1,1,1,1,0},
  {1,0,0,0,1,0,0},
  {0,0,1,0,1,0,0},
  {0,1,1,0,0,1,0},
};



/**************************************************************************/
//    Functions
/**************************************************************************/

void Gear_Update(signed Gear){
    mcp.begin(0);
    for(int i=0;i<=6;i++){
        mcp.pinMode(i,OUTPUT);
        mcp.digitalWrite(i,PINS_GEAR[Gear][i]);
    }
}



/***************************************************************************
  END FILE
***************************************************************************/
