#ifndef TRAFFICLIGHT_H
#define TRAFFICLIGHT_H

#include <Arduino.h>

enum TrafficLightState {
  RED,
  YELLOW,
  GREEN
};

class TrafficLight {
  private:
    uint8_t pinRed;
    uint8_t pinYellow;
    uint8_t pinGreen;
    TrafficLightState currentState;

  public:
    TrafficLight(uint8_t redPin, uint8_t yellowPin, uint8_t greenPin);

    void setState(TrafficLightState state);
    TrafficLightState getState() const;
};

#endif
