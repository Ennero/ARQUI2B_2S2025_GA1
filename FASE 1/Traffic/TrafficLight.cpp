#include "TrafficLight.h"

TrafficLight::TrafficLight(uint8_t redPin, uint8_t yellowPin, uint8_t greenPin)
  : pinRed(redPin), pinYellow(yellowPin), pinGreen(greenPin), currentState(RED)
{
  pinMode(pinRed, OUTPUT);
  pinMode(pinYellow, OUTPUT);
  pinMode(pinGreen, OUTPUT);
  setState(RED);
}

void TrafficLight::setState(TrafficLightState state) {
  currentState = state;
  digitalWrite(pinRed,    state == RED    ? HIGH : LOW);
  digitalWrite(pinYellow, state == YELLOW ? HIGH : LOW);
  digitalWrite(pinGreen,  state == GREEN  ? HIGH : LOW);
}

TrafficLightState TrafficLight::getState() const {
  return currentState;
}
