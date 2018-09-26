// Code du BSPD Optimus si possibilité de programmer
// V0.1 par Bob le 26/09/2018 

// ATTENTION les valeur de seuil et de calibration pour la pression n'ont aucun sens il faudra les modifier

//-------------------------------------------------


// Définition des constantes
const int PIN_THROTTLE = 3; //pin du papillion/guillotine
const int PIN_BRAKE = 4; //pin du capteur de pression frein
const int PIN_OUT = 2; //pin de sortie
const int THRESHOLD_THROTTLE = 10; //seuil d'activation pour le papillion (en %)
const int THRESHOLD_BRAKE = 25; // seui d'activation pour la pression frein (en bar)

//Définition des variables
byte Out = LOW; //état de la sortie (LOW = relai fermé, HIGH = relai ouvert)
float Throttle; //Valeur en sortie du potentiomètre papillion (en %)
float Brake; //Valeur en sortie du capteur de pression frein (en bar)


void setup() {
  pinMode(PIN_THROTTLE, INPUT);
  pinMode(PIN_BRAKE, INPUT);
  pinMode(PIN_OUT, OUTPUT);
}

void loop() {
  unsigned long debut= millis(); // Temps au début de la boucle
  // On récupère les valeurs analogique et on les converties 
  Throttle = map(analogRead(PIN_THROTTLE),0,1023,0,100);  
  Brake = map(analogRead(PIN_BRAKE),0,1023,0,150);

  if ((Throttle > THRESHOLD_THROTTLE) && (Brake > THRESHOLD_BRAKE) && (Out == LOW) // Si on a pas bloqué mais que on est en condition on entre dans la boucle 
  {
    while ((Throttle > THRESHOLD_THROTTLE) && (Brake > THRESHOLD_BRAKE) && (millis - debut < 500) {} // Si on reste dans ces conditions pendant 500ms 
    
    if (millis - debut > 500) {
      Out = !Out;    // Alors on bloque le système 
    }

if ((Throttle < THRESHOLD_THROTTLE) && (Brake < THRESHOLD_BRAKE) && (Out == HIGH) // Si on a bloqué mais que on est en condition de débloquer on entre dans la boucle 
  {
    while ((Throttle < THRESHOLD_THROTTLE) && (Brake < THRESHOLD_BRAKE) && (millis - debut < 10000) {} // Si on reste dans ces conditions pendant 10s 
    
    if (millis - debut > 10000) {
      Out = !Out;    // Alors on débloque le système 
    }

}
