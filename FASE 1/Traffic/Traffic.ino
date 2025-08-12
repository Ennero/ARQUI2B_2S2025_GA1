#include <NewPing.h>
#include "TrafficLight.h"
#include "TrafficLightPair.h"

#define SONAR_NUM 2  // Ahora 2 sensores
#define MAX_DISTANCE 50
#define PING_INTERVAL 33
#define NUM_PAIRS 1
#define NUM_LIGHTS (NUM_PAIRS * 2)

unsigned long pingTimer[SONAR_NUM];
uint8_t currentSensor = 0;
unsigned int cm[SONAR_NUM];

NewPing sonar[SONAR_NUM] = {
  NewPing(22, 23, MAX_DISTANCE),  // Sensor 0
  NewPing(2, 3, MAX_DISTANCE)     // Sensor 1
};

TrafficLight trafficLights[NUM_LIGHTS] = {
  TrafficLight(25, 27, 29),
  TrafficLight(26, 28, 30)
};

TrafficLightPair pairs[NUM_PAIRS] = {
  TrafficLightPair(trafficLights[0], trafficLights[1])
};

void setup() {
  Serial.begin(9600);

  globalStartMillis = millis();
  
  for (int i = 0; i < NUM_PAIRS; i++) {
    pairs[i].begin();
  }

  unsigned long startTime = millis() + 75;
  for (uint8_t i = 0; i < SONAR_NUM; i++) {
    pingTimer[i] = startTime + i * PING_INTERVAL;
  }
}

void loop() {
  // Actualizar semáforos coordinados
  for (int i = 0; i < NUM_PAIRS; i++) {
    pairs[i].update();
  }

  // Manejo de sensores
  for (uint8_t i = 0; i < SONAR_NUM; i++) {
    if (millis() >= pingTimer[i]) {
      pingTimer[i] += PING_INTERVAL * SONAR_NUM;

      sonar[currentSensor].timer_stop();
      currentSensor = i;
      cm[currentSensor] = 0;
      sonar[currentSensor].ping_timer(echoCheck);
    }
  }

  if (currentSensor == SONAR_NUM - 1) {
    oneSensorCycle();
  }
}

void echoCheck() {
  if (sonar[currentSensor].check_timer()) {
    cm[currentSensor] = sonar[currentSensor].ping_result / US_ROUNDTRIP_CM;
  }
}

void oneSensorCycle() {
  for (uint8_t i = 0; i < SONAR_NUM; i++) {
    if (cm[i] > 0 && cm[i] <= 3) {
      Serial.print("Sensor ");
      Serial.print(i);
      Serial.println(": Object detected");

      if (trafficLights[i].getState() == RED) {
        Serial.print("ALERT! Sensor ");
        Serial.print(i);
        Serial.println(" passed on RED light!");
      }
    }
  }
}
