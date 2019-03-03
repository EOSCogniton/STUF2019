int KPH=31;

int LC_SWITCH_PIN=7; // Pin à cahnger
int LC_LED_PIN=8;
int Switch_LC=0;
int Limit_LC=30; // Max LC Speed
boolean Led_LC=0;

char Print[128]; 


void State_LC(int KPH){

    Switch_LC=digitalRead(LC_SWITCH_PIN); 
  
    sprintf(Print, "Switch_LC = %1d   KPH = %3d   Led_LC = %1d", Switch_LC, KPH, Led_LC);
    Serial.print("\n");
    Serial.print(Print);
    
    if(Switch_LC==1 && KPH<Limit_LC){
        Led_LC=1;
        digitalWrite(LC_LED_PIN,HIGH);
    }
    if(KPH>Limit_LC){
        Led_LC=0;
        digitalWrite(LC_LED_PIN,LOW);
    }
}



void setup() {

    Serial.begin(115200);   
    // put your setup code here, to run once:
    pinMode(LC_SWITCH_PIN,INPUT); 
    pinMode(LC_LED_PIN,OUTPUT);
}

void loop() {
    
    State_LC(KPH);
}
