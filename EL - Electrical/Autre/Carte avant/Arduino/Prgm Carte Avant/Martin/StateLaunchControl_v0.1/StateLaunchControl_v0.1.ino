boolean Button_Launch_Control;
boolean Led_Launch_Control;
int Limit_Launch_Control;
int Speed;

void StateLaunchControl(boolean *Led_Launch_Control,int Speed,int Limit_Launch_Control){
  if(Led_Launch_Control==1 && Speed>=Limit_Launch_Control/10){
    Led_Launch_Control=0;
  }
}



void setup() {
  // put your setup code here, to run once:

}

void loop() {
  if(Button_Launch_Control==1){
    Led_Launch_Control=1;
  }
  if(Led_Launch_Control==1){
    StateLaunchControl(&Led_Launch_Control,Speed,Limit_Launch_Control);
  }
}
