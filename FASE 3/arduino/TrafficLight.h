#ifndef TRAFFICLIGHT_H
#define TRAFFICLIGHT_H

#include <Arduino.h>

class TrafficLight
{
public:
    enum State
    {
        RED,
        YELLOW,
        GREEN
    };

private:
    int pinRed;
    int pinYellow;
    int pinGreen;
    State state;

public:
    TrafficLight(int redPin, int yellowPin, int greenPin);

    void begin();
    void setState(State newState);
    State getState() const;
    void turnOffAll();
};

#endif