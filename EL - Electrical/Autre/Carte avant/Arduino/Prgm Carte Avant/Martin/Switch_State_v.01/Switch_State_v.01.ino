const int SWITCHPIN=0;
boolean Switch_State;

void setup() {
  pinMode(SWITCHPIN,OUTPUT);
}

void loop() {
  Switch_State=digitalRead(SWITCHPIN);
}
