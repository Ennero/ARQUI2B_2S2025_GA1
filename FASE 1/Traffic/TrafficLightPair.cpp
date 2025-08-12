#include "TrafficLightPair.h"

// Variable global para sincronizar todos los pares
unsigned long globalStartMillis = 0;

TrafficLightPair::TrafficLightPair(TrafficLight& l0, TrafficLight& l1,
                                   unsigned long greenDur,
                                   unsigned long yellowDur)
  : light0(l0), light1(l1),
    greenDuration(greenDur),
    yellowDuration(yellowDur)
{
  cycleLength = 2 * (greenDuration + yellowDuration);
}

void TrafficLightPair::begin() {
  // No inicializamos aquí globalStartMillis ni estados,
  // eso se hará globalmente en setup() para sincronizar todos los pares
}

void TrafficLightPair::update() {
  unsigned long now = millis();
  unsigned long elapsed = (now - globalStartMillis) % cycleLength;

  if (elapsed < greenDuration) {
    setIfChanged(light0, GREEN);
    setIfChanged(light1, RED);
  } 
  else if (elapsed < greenDuration + yellowDuration) {
    setIfChanged(light0, YELLOW);
    setIfChanged(light1, RED);
  } 
  else if (elapsed < greenDuration + yellowDuration + greenDuration) {
    setIfChanged(light0, RED);
    setIfChanged(light1, GREEN);
  } 
  else {
    setIfChanged(light0, RED);
    setIfChanged(light1, YELLOW);
  }
}

void TrafficLightPair::setIfChanged(TrafficLight& light, TrafficLightState state) {
  if (light.getState() != state) {
    light.setState(state);
  }
}

TrafficLightState TrafficLightPair::getStateOfLight0() const {
  return light0.getState();
}

TrafficLightState TrafficLightPair::getStateOfLight1() const {
  return light1.getState();
}
