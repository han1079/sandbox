#include <Arduino.h>

// the loop function runs over and over again forever
int main() {
  init();  
  Serial.begin(9600);
  Serial.println("Hello, World!");
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, 1);
  pinMode(3, OUTPUT);
  digitalWrite(3,1);
  while (1){
  Serial.println("LED is on");
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED on (HIGH is the voltage level)
  delay(200);                      // wait for a second
  Serial.println("LED is off");
  digitalWrite(LED_BUILTIN, LOW);   // turn the LED off by making the voltage LOW
  delay(200);
  }                      // wait for a second
  return 0;
}
