#include "TrafficLight.h"

TrafficLight::TrafficLight(int redPin, int yellowPin, int greenPin)
{
    pinRed = redPin;
    pinYellow = yellowPin;
    pinGreen = greenPin;
    state = RED; // default initial state
}

void TrafficLight::begin()
{
    pinMode(pinRed, OUTPUT);
    pinMode(pinYellow, OUTPUT);
    pinMode(pinGreen, OUTPUT);

    turnOffAll();
    setState(state);
}

void TrafficLight::setState(State newState)
{
    state = newState;

    turnOffAll();

    switch (state)
    {
        case RED:
            digitalWrite(pinRed, HIGH);
            break;
        case YELLOW:
            digitalWrite(pinYellow, HIGH);
            break;
        case GREEN:
            digitalWrite(pinGreen, HIGH);
            break;
    }
}

TrafficLight::State TrafficLight::getState() const
{
    return state;
}

void TrafficLight::turnOffAll()
{
    digitalWrite(pinRed, LOW);
    digitalWrite(pinYellow, LOW);
    digitalWrite(pinGreen, LOW);
}
