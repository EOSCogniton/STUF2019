#include <SPI.h>
#include <mcp_can.h>

//ATOMIX Monitoring Carte 2

//31/01/2016 v2.0 VGE sortie de la boucle en cas de mauvaise initialisation du CANBUS (2s)
//24/04/2015 v1.3 JGR
//23/04/2015 v1.2 VGE delay enlevé
//22/04/2015 v1.0 TPT récupération des données issues du calculateur et de la boite de vitesse
//12/04/2015 v0.3 VGE mise a jour des id canbus et des infos calculo
//31/03/2015 v0.2 VGE

// VULCANIX Carte arriere

//2018 : reprise du code d'Atomix et adaptation pour la Carte Arriere Vulcanix 

 
//--------------  assignation des pins  ------------------
const int palette_moins = A5;
const int palette_plus = A4;
const int homing = 47;
const int neutre = 45;
const int led_homing = 41;
const int GND_1 = 39;

const int in_0 = 93;
const int in_1 = 3;
const int in_2 = 4;
const int in_3 = 5;
const int in_4 = 6;  
const int out_1 = 9;
const int out_2 = 11;
const int GND_2 = 35;

const int out_rapport = 12;
const int shift_cut = 13;

//-------------------  données calcul  ----------------
boolean etat_palette_moins;
boolean etat_palette_moins_prec;
boolean etat_palette_plus;
boolean etat_palette_plus_prec;
boolean etat_homing;
boolean etat_homing_prec;
boolean etat_neutre;
boolean etat_neutre_prec;
boolean led_clignotante;
boolean led_force;
boolean homed;
boolean error;
long date_clignotement;
long date_coupure;
int delai_clignotement = 200;
int temps_coupure = 400;
const long refresh_can = 250;

//--------------------  variables stockage  -------------------

int id;
int rapport_recherche;
int rapport_engage;
boolean positions[16][4];
long temps_can;

int regime;
int rapport = 3;

//initialisation Canbus


unsigned char Flag_Recv = 0;
unsigned char len = 0; //à vérifier
unsigned char buf[8];
char str[20];
//
MCP_CAN CAN0(10);
byte data[8] = {0,0,0,0,0,0,0,0};



void setup() {
  
Serial.begin(115200);

  // Initialize MCP2515 running at 16MHz with a baudrate of 500kb/s and the masks and filters disabled.
  if(CAN0.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) == CAN_OK) Serial.println("MCP2515 Initialized Successfully!");
  else Serial.println("Error Initializing MCP2515...");

  CAN0.setMode(MCP_NORMAL);   // Change to normal mode to allow messa

  date_clignotement = millis();
  led_clignotante = true;
  led_force = false;
  homed = false;
  error = false;

  
  pinMode(palette_moins, INPUT);
  pinMode(palette_plus, INPUT);
  pinMode(homing, INPUT);
  pinMode(neutre, INPUT);  
  pinMode(led_homing, OUTPUT);
  pinMode(GND_1, OUTPUT);
  
//  digitalWrite(palette_moins, HIGH);
//  digitalWrite(palette_plus, HIGH);  
    digitalWrite(homing, HIGH);
    digitalWrite(neutre, HIGH);
    digitalWrite(led_homing, LOW);
    digitalWrite(GND_1, LOW);
  
  pinMode(in_0, OUTPUT);
  pinMode(in_1, OUTPUT);
  pinMode(in_2, OUTPUT);
  pinMode(in_3, OUTPUT);
  pinMode(in_4, OUTPUT);
  pinMode(out_1, INPUT);
  pinMode(out_2, INPUT);
  pinMode(GND_2, OUTPUT);
    
  digitalWrite(in_0, LOW);
  digitalWrite(in_1, LOW);
  digitalWrite(in_2, LOW);
  digitalWrite(in_3, LOW);
  digitalWrite(in_4, LOW);  
  digitalWrite(GND_2, LOW);
  
  pinMode(out_rapport, OUTPUT);
  
  pinMode(shift_cut, OUTPUT);  
  digitalWrite(shift_cut, HIGH);
  
  
  etat_palette_moins_prec = LOW;
  etat_palette_plus_prec = LOW;
    
  positions[0][0] = 0;
  positions[0][1] = 0;
  positions[0][2] = 0;
  positions[0][3] = 0;  
  
  positions[1][0] = 1;
  positions[1][1] = 0;
  positions[1][2] = 0;
  positions[1][3] = 0;
  
  positions[2][0] = 0;
  positions[2][1] = 1;
  positions[2][2] = 0;
  positions[2][3] = 0;
  
  positions[3][0] = 1;
  positions[3][1] = 1;
  positions[3][2] = 0;
  positions[3][3] = 0;
  
  positions[4][0] = 0;
  positions[4][1] = 0;
  positions[4][2] = 1;
  positions[4][3] = 0;
  
  positions[5][0] = 1;
  positions[5][1] = 0;
  positions[5][2] = 1;
  positions[5][3] = 0;
  
  positions[6][0] = 0;
  positions[6][1] = 1;
  positions[6][2] = 1;
  positions[6][3] = 0;
  
  positions[7][0] = 1;
  positions[7][1] = 1;
  positions[7][2] = 1;
  positions[7][3] = 0;
  
  positions[8][0] = 0;
  positions[8][1] = 0;
  positions[8][2] = 0;
  positions[8][3] = 1;
  
  positions[9][0] = 1;
  positions[9][1] = 0;
  positions[9][2] = 0;
  positions[9][3] = 1;
  
  positions[10][0] = 0;
  positions[10][1] = 1;
  positions[10][2] = 0;
  positions[10][3] = 1;
  
  positions[11][0] = 1;
  positions[11][1] = 1;
  positions[11][2] = 0;
  positions[11][3] = 1;
  
  positions[12][0] = 0;
  positions[12][1] = 0;
  positions[12][2] = 1;
  positions[12][3] = 1;
  
  positions[13][0] = 1;
  positions[13][1] = 0;
  positions[13][2] = 1;
  positions[13][3] = 1;
  
  positions[14][0] = 0;
  positions[14][1] = 1;
  positions[14][2] = 1;
  positions[14][3] = 1;
  
  positions[15][0] = 1;
  positions[15][1] = 1;
  positions[15][2] = 1;
  positions[15][3] = 1;

  rapport_recherche = 1;    
  rapport_engage = rapport_recherche;
  engager_rapport(rapport_recherche);
 
}


//-----------------------------------------------
//-------------------  Loop ---------------------

void loop() {
  
etat_palette_moins = digitalRead(palette_moins);

  if(etat_palette_moins != etat_palette_moins_prec)
  {
    if(etat_palette_moins)
    {
      action_palette_moins();
    }
    etat_palette_moins_prec = !etat_palette_moins_prec;
  }

  etat_palette_plus = digitalRead(palette_plus);

  if(etat_palette_plus != etat_palette_plus_prec)
  {
    if(etat_palette_plus)
    {
      action_palette_plus();
//      Serial.write("pallete_plus");
    }
    etat_palette_plus_prec = !etat_palette_plus_prec;
  }
  
  etat_homing = digitalRead(homing);

  if(etat_homing != etat_homing_prec)
  {
    if(!etat_homing)
    {
      action_homing();
//      Serial.write("bouton 3");
    }
    etat_homing_prec = !etat_homing_prec;
  }

  etat_neutre = digitalRead(neutre);

  if(etat_neutre != etat_neutre_prec)
  {
    if(!etat_neutre)
    {
      action_neutre();
//      Serial.write("bouton 3");
    }
    etat_neutre_prec = !etat_neutre_prec;
  }
  
  engager_rapport(rapport_recherche);
  
  
  if(true) //if(moteur électrique stoppé)
  {
    rapport_engage = rapport_recherche;
  }
  
  if(!digitalRead(out_1) && !digitalRead(out_2)) // error
  {
    error = true;
    homed = false;
    delai_clignotement = 500;
    led_clignotante = true;
    led_force = false;
    if(etat_palette_plus && etat_palette_moins){
      action_homing();
      engager_rapport(rapport_recherche);
    }
  }  
  else
  {  
    error = false;    
    delai_clignotement = 200;
    led_clignotante = false;
    led_force = false;
//    if(etat_palette_plus && etat_palette_moins){
//      action_neutre();
//      engager_rapport(rapport_recherche);
//    }
  }
  
  analogWrite(out_rapport, max(0, rapport_engage-2)*255/6);
  
  clignoter_led();
  
  if(millis() - date_coupure > temps_coupure){
    digitalWrite(shift_cut, HIGH);
  }
//envoyer CANBUS
  data[0]=rapport_engage;
  byte sndStat = CAN0.sendMsgBuf(0x100, 0, 8, data);


////recevoir CANBUS
//  if (mcp2515.readMessage(&receive_frame) == MCP2515::ERROR_OK) {
//    if(receive_frame.can_id == 0x0AA){
//      if(receive_frame.data[0] == 1){
//        action_homing();
//        engager_rapport(rapport_recherche);
//        rapport_engage = rapport_recherche;
//      }
//      if(receive_frame.data[1] == 1){
//        action_neutre();
//        engager_rapport(rapport_recherche);  
//        rapport_engage = rapport_recherche;      
//      }
//    }
//  }
//  Serial.print(rapport_engage);
}


void clignoter_led()
{
  
  if(millis() - date_clignotement > delai_clignotement)
    date_clignotement = millis();
  
  if(millis() - date_clignotement < (delai_clignotement/2) && led_clignotante)
  {
    digitalWrite(led_homing, HIGH);
  }
  else
  {
    if(!led_force)
      digitalWrite(led_homing, LOW);
    else
      digitalWrite(led_homing, HIGH);
  }
  
}

void engager_rapport(int rapport)
{

  digitalWrite(in_0, LOW);
  digitalWrite(in_1, positions[rapport][0]);
  digitalWrite(in_2, positions[rapport][1]);
  digitalWrite(in_3, positions[rapport][2]);
  digitalWrite(in_4, positions[rapport][3]); 
  
}

void action_palette_moins()
{
  if(rapport_recherche > 3)
  {
    rapport_recherche--;
  }
}

void action_palette_plus()
{
  if(millis() > 1000)
  {
    if(rapport_recherche < 8 && rapport_recherche > 1)
    {
      rapport_recherche++;
      digitalWrite(shift_cut, LOW);
      date_coupure = millis();
    }
    else if(rapport_recherche == 1)
      rapport_recherche = 3;
      
    
  }
}

void action_homing()
{
  if(error)
  {
    rapport_recherche = 0;
    engager_rapport(rapport_recherche);
    delay(80);
    rapport_recherche = 1;
  }
  
  else if (!error && millis() > 1000)
  {  
    if(rapport_recherche == 1)
    {
      rapport_recherche = 2;
      delay(50);
      rapport_recherche = 1; 
    }
    else
      rapport_recherche = 1;
  }
  
}

void action_neutre()
{
  rapport_recherche = 2;
}

