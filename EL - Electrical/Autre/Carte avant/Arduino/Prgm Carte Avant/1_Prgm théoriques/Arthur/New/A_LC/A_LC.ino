int Speed;

int LC_SWITCH_PIN=6; // Pin à cahnger
int LC_LED_PIN=7;
int Switch_LC;
int Limit_LC=30; // Max LC Speed
boolean Led_LC=0;


void State_LC(int Switch_LC, int Speed){
    if(State_LC==1 && Speed<Limit_LC){
        Led_LC=1;
        digitalWrite(LC_LED_PIN,HIGH);
    }
    if(Speed>Limit_LC){
        Led_LC=0;
        digitalWrite(LC_LED_PIN,LOW);
    }
}



void setup() {
    // put your setup code here, to run once:
    pinMode(LC_SWITCH_PIN,INPUT); 
    pinMode(LC_LED_PIN,OUTPUT);
}

void loop() {
    Switch_LC=digitalRead(LC_SWITCH_PIN);
    State_LC(Switch_LC, Speed);
}
