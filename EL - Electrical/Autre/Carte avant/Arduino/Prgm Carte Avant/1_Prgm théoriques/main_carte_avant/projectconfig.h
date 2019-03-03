#ifndef PROJECTCONFIG_H //if not define symbol PROJECTCONFIG_H
#define PROJECTCONFIG_H


/**************************************************************************/

//                        IMPORTANT !!!!!!


//           Make sure that the definitions in this 
//        file are UNIQUE AND EXCLUSIVELY in this file.

/**************************************************************************/



// Defintion of the pins

// Set INT to pin 2
#define CAN0_INT 2

// Led pins
const int DATAPIN = 4;
const int CLOCKPIN = 5;

// Temperature-Voltage
const int TV_PIN=3;

// Carte Arrière Comm
const int H_PIN=12;   // Homing
const int N_PIN=6;   // Neutre

// Launch Control
const int LC_SWITCH_PIN = 7; // Pin à cahnger
const int LC_LED_PIN = 8;



#endif  /* inclusion guards - PROJECTCONFIG_H */ 
