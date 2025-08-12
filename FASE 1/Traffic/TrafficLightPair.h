#ifndef TRAFFICLIGHTPAIR_H
#define TRAFFICLIGHTPAIR_H

#include <Arduino.h>
#include "TrafficLight.h"

extern unsigned long globalStartMillis;

enum Phase {
    PHASE_GREEN_0,
    PHASE_YELLOW_0,
    PHASE_GREEN_1,
    PHASE_YELLOW_1
};

class TrafficLightPair {
private:
    TrafficLight& light0;
    TrafficLight& light1;

    unsigned long greenDuration;
    unsigned long yellowDuration;
    unsigned long cycleLength;

    void setIfChanged(TrafficLight& light, TrafficLightState state);

public:
    TrafficLightPair(TrafficLight& l0, TrafficLight& l1,
                     unsigned long greenDur = 5000,
                     unsigned long yellowDur = 2000);

    void begin();
    void update();

    TrafficLightState getStateOfLight0() const;
    TrafficLightState getStateOfLight1() const;
};

#endif
