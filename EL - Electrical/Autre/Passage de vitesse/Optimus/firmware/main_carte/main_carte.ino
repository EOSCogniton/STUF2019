/**************************************************************************/
/*!
    @file     main_carte.cpp
    @author   Bruno Moreira Nabinger and Corentin Lepais (EPSA)
                                                  Ecurie Piston Sport Auto
    
    Main code for control the Motor with integrated Controller and CAN 
    interface BG 45 CI

 
    @section  HISTORY
    v0.3 - 10/11/2018 Comments of code and add of the file 
           "projectconfig.h", with the definitions of the pins numbers.
    v0.2 - 17/10/2018 Management of pallets and beginning of creations of 
                      the associated functions
    v0.1 - 10/10/2018 First release (previously code of Pedro)

    example of code version comment
    v0.2 - Rewrote driver for Adafruit_Sensor and Auto-Gain support, and
           added lux clipping check (returns 0 lux on sensor saturation)
*/
/**************************************************************************/
#include "projectconfig.h"

//Ajout des fonctions
#include "fonct_palette_homing.h"
#include "fonct_mot.h"

//initialisation Canbus
#include <SPI.h>
#include "mcp_can.h"
MCP_CAN CAN(53);

const int neutre; 


//Definition of used variables 
boolean statePaletteIncrease; 
boolean statePaletteIncreaseBefore;
boolean statePaletteDecrease;
boolean statePaletteDecreaseBefore;
int PositionEngager; // Contain what motor position is currently engaged
int wantedPosition;// Contain the motor position wanted so the speed rapport of the bike
boolean stateHoming; // Will contain the state of the homing button
boolean stateHomingBefore;
boolean outMotor1; //Info return by the motor
boolean outMotor2;//Info return by the motor
boolean stateNeutre;
boolean stateNeutreBefore;
boolean error;
const int neutrePosition = 2;
const int homingPosition=1;
boolean positionReached=true;

//Table which will contain the combination of the motor input for each speed
boolean motorPosition[16][4];//We use only 4 input motor to command it. The 5 is always 0

void setup() 
{ 
  //Initialization of CANBUS
  START_INIT:
    if(CAN_OK == CAN.begin(CAN_1000KBPS))  
    {
      Serial.println("CAN BUS Shield init ok!");
    }
    else if(millis() <= 2000)//Exit the initialisation after 2s in case of failure
                             //sortir de l'initialisation au bout de 2s en cas de panne
    {
      Serial.println("CAN BUS Shield init fail");
      Serial.println("Init CAN BUS Shield again");
      delay(100);
      goto START_INIT;
    }

  //Initialization of the pins
  pinMode(motorState1, INPUT);
  pinMode(motorState2, INPUT);
  pinMode(motorInput0, OUTPUT);
  pinMode(motorInput1, OUTPUT);
  pinMode(motorInput2, OUTPUT);
  pinMode(motorInput3, OUTPUT);
  pinMode(motorInput4, OUTPUT);
  pinMode(shiftCut, OUTPUT); 
  pinMode(shiftPot, INPUT);

  pinMode(paletteIncrease, INPUT_PULLUP);
  pinMode(paletteDecrease, INPUT_PULLUP);
  pinMode(neutre, INPUT_PULLUP);
  
  digitalWrite(motorInput0, LOW);
  digitalWrite(motorInput1, LOW);
  digitalWrite(motorInput2, LOW);
  digitalWrite(motorInput3, LOW);
  digitalWrite(motorInput4, LOW);
  digitalWrite(shiftCut, HIGH);

  //Initialization of the variables
  statePaletteIncreaseBefore = HIGH; //The pallets mode is INPUT_PULLUP, so the pin level is HIGH when it is inactive
  statePaletteDecreaseBefore = HIGH;
  PositionEngager = 2;
  wantedPosition = 2;
  error = false;
  stateNeutreBefore=HIGH;
  
  {//Initialization of the table. We use only the position 1-6, clear error and start Homing
    
    //Clear error and Stop
    motorPosition[0][0] = 0;
    motorPosition[0][1] = 0;
    motorPosition[0][2] = 0;
    motorPosition[0][3] = 0; 

    //Start Homing
    motorPosition[1][0] = 1;
    motorPosition[1][1] = 0;
    motorPosition[1][2] = 0;
    motorPosition[1][3] = 0;

    //Position 1: Neutre
    motorPosition[2][0] = 0;
    motorPosition[2][1] = 1;
    motorPosition[2][2] = 0;
    motorPosition[2][3] = 0;

    //Position 2 : vitesse 1 de la moto
    motorPosition[3][0] = 1;
    motorPosition[3][1] = 1;
    motorPosition[3][2] = 0;
    motorPosition[3][3] = 0;

    //Position 3 : vitesse 2
    motorPosition[4][0] = 0;
    motorPosition[4][1] = 0;
    motorPosition[4][2] = 1;
    motorPosition[4][3] = 0;

    //Position 4 : vitesse 3
    motorPosition[5][0] = 1;
    motorPosition[5][1] = 0;
    motorPosition[5][2] = 1;
    motorPosition[5][3] = 0;

    //Position 5 : vitesse 4
    motorPosition[6][0] = 0;
    motorPosition[6][1] = 1;
    motorPosition[6][2] = 1;
    motorPosition[6][3] = 0;

    //Position 6 : vitesse 5
    motorPosition[7][0] = 1;
    motorPosition[7][1] = 1;
    motorPosition[7][2] = 1;
    motorPosition[7][3] = 0;

    //Position 7 : vitesse 6
    motorPosition[8][0] = 0;
    motorPosition[8][1] = 0;
    motorPosition[8][2] = 0;
    motorPosition[8][3] = 1;

    //Position 8
    motorPosition[9][0] = 1;
    motorPosition[9][1] = 0;
    motorPosition[9][2] = 0;
    motorPosition[9][3] = 1;

    //Position 9
    motorPosition[10][0] = 0;
    motorPosition[10][1] = 1;
    motorPosition[10][2] = 0;
    motorPosition[10][3] = 1;

    //Position 10
    motorPosition[11][0] = 1;
    motorPosition[11][1] = 1;
    motorPosition[11][2] = 0;
    motorPosition[11][3] = 1;

    //Position 11
    motorPosition[12][0] = 0;
    motorPosition[12][1] = 0;
    motorPosition[12][2] = 1;
    motorPosition[12][3] = 1;
    
    //Position 12
    motorPosition[13][0] = 1;
    motorPosition[13][1] = 0;
    motorPosition[13][2] = 1;
    motorPosition[13][3] = 1;

    //Position 13 
    motorPosition[14][0] = 0;
    motorPosition[14][1] = 1;
    motorPosition[14][2] = 1;
    motorPosition[14][3] = 1;

    //Position 14
    motorPosition[15][0] = 1;
    motorPosition[15][1] = 1;
    motorPosition[15][2] = 1;
    motorPosition[15][3] = 1;
  }

}

void loop() 
{ 
  //Control of pallet+
  statePaletteIncrease = digitalRead(paletteIncrease);
  if (statePaletteIncrease != statePaletteIncreaseBefore)
  {
    if (!statePaletteIncrease) //Le test précédent va être vrai 2 fois de suite: au moment ou le pilote appuie sur la palette et quand il la relache. Mais on n'a passé qu'une vitesse
    {
      if(PassageVitesseIsPossible(PositionEngager)) //On teste si le changement de vitesse est possible
      {
        digitalWrite(shiftCut, LOW); //On coupe l'injection
        wantedPosition = PositionEngager+1;
      }
    }
    statePaletteIncreaseBefore = statePaletteIncrease;
  }
  
  //Control of pallet-
  statePaletteDecrease = digitalRead(paletteDecrease);
  if (statePaletteDecrease != statePaletteDecreaseBefore)
  {
    if (!statePaletteDecrease) //Le test précédent va être vrai 2 fois de suite: au moment ou le pilote appuie sur la palette et quand il la relache. Il ne faut donc pas passer 2 vitesses pour un appui
    {
      if(PassageVitesseIsPossible(PositionEngager)) //On teste si le changement de vitesse est possible
      {
        digitalWrite(shiftCut, LOW); 
        wantedPosition = PositionEngager-1;
      }
    }
    statePaletteIncreaseBefore = statePaletteIncrease;
  }

  //Gestion du neutre
  stateNeutre = digitalRead(neutre);
  if(stateNeutre != stateNeutreBefore)
  {
    if(!stateNeutre)
    {
      digitalWrite(shiftCut, LOW); 
      wantedPosition = neutrePosition;
    }
    stateNeutreBefore = !stateNeutre;
  }
  
  //Gestion bouton homing
  //stateHoming=;
  if(stateHoming != stateHomingBefore)
  {
    if(!stateHoming)
    {
      wantedPosition=homingPosition;
    }
    stateHomingBefore = !stateHomingBefore;
  }
  
  do //Loop to put the correct position 
  {
    EngageVitesse(wantedPosition);
    positionReached=true;
    outMotor1 = digitalRead(motorState1);
    outMotor2 = digitalRead(motorState2);
    while(not(PositionReachedOrHomingDone(outMotor1,outMotor2))) //while the motor doesn't reach its position
    {
      outMotor1 = digitalRead(motorState1);
      outMotor2 = digitalRead(motorState2);
      if (MotorIsLost(outMotor1,outMotor2)) //error
      {
        //On nettoie l'erreur
        digitalWrite(motorInput0,LOW);
        digitalWrite(motorInput1,LOW);
        digitalWrite(motorInput2,LOW);
        digitalWrite(motorInput3,LOW);
        digitalWrite(motorInput4,LOW);
    
        EngageVitesse(homingPosition); // Homing position for the motor
        positionReached=false;
      }
      outMotor1 = digitalRead(motorState1);
      outMotor2 = digitalRead(motorState2);
    }
  }while(not(positionReached));
  digitalWrite(shiftCut, HIGH);//Open the injection
}

void EngageVitesse(int wantedPosition) //Function which pass the speed
{
  digitalWrite(motorInput0,LOW);
  digitalWrite(motorInput1, motorPosition[wantedPosition][0]);
  digitalWrite(motorInput2, motorPosition[wantedPosition][1]);
  digitalWrite(motorInput3, motorPosition[wantedPosition][2]);
  digitalWrite(motorInput4, motorPosition[wantedPosition][3]);
}
 
