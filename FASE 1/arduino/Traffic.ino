#include <NewPing.h>
#include "TrafficLight.h"

#define MAX_DISTANCE 50
#define PING_INTERVAL 33

enum SensorPurpose { SENSOR_PASS, SENSOR_ARRIVAL };

struct Sensor {
    NewPing* sonar;
    SensorPurpose purpose;
    uint8_t id;
    uint8_t group;  // 0 = A, 1 = B
};

NewPing sonar[] = {
    NewPing(22, 23, MAX_DISTANCE), // 0
    NewPing(2, 3, MAX_DISTANCE),   // 1
    NewPing(4, 5, MAX_DISTANCE),   // 2
    NewPing(6, 7, MAX_DISTANCE)    // 3
};

Sensor sensors[] = {
    { &sonar[0], SENSOR_PASS,    0, 0 },
    { &sonar[1], SENSOR_ARRIVAL, 1, 0 },
    { &sonar[2], SENSOR_PASS,    2, 1 },
    { &sonar[3], SENSOR_ARRIVAL, 3, 1 }
};

const uint8_t NUM_SENSORS = sizeof(sensors) / sizeof(sensors[0]);

unsigned long pingTimer[NUM_SENSORS];
uint16_t distances[NUM_SENSORS];
uint8_t currentSensor = 0;

TrafficLight trafficA(25, 27, 29);
TrafficLight trafficB(24, 26, 28);

enum TrafficCycle { GREEN_A, YELLOW_A, GREEN_B, YELLOW_B };
TrafficCycle currentCycle = GREEN_A;

unsigned long stateStartTime = 0;
const unsigned long greenTime = 4000;
const unsigned long yellowTime = 1500;

// --- Nueva sección para Botones y Buzzers ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = {30, 31, 32, 33, 34};
const int PINES_BUZZER[NUM_BOTONES] = {35, 36, 37, 38, 39};

// Variables para el estado de los botones
bool estadosBotones[NUM_BOTONES] = {false};
bool estadoAnteriorBotones[NUM_BOTONES] = {false};
unsigned long debounceTime = 50;

// --- Funciones Modulares para Botones y Buzzers ---
void inicializarPerifericos() {
    for (int i = 0; i < NUM_BOTONES; i++) {
        pinMode(PINES_BOTONES[i], INPUT_PULLUP);
        pinMode(PINES_BUZZER[i], OUTPUT);
        digitalWrite(PINES_BUZZER[i], LOW);
    }
}

void manejarBotones() {
    for (int i = 0; i < NUM_BOTONES; i++) {
        bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;
        if (estadoActual != estadoAnteriorBotones[i]) {
            delay(debounceTime); // Antirrebote (debounce)
            estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;
        }
        if (estadoActual && !estadoAnteriorBotones[i]) {
            Serial.print("Boton ");
            Serial.print(i + 1);
            Serial.println(" presionado. Activando buzzer.");
            sonarBuzzer(i);
        }
        estadoAnteriorBotones[i] = estadoActual;
    }
}

void sonarBuzzer(int buzzerIndex) {
    if (buzzerIndex >= 0 && buzzerIndex < NUM_BOTONES) {
        digitalWrite(PINES_BUZZER[buzzerIndex], HIGH);
        delay(250); // Sonar por 250ms
        digitalWrite(PINES_BUZZER[buzzerIndex], LOW);
    }
}

// --- setup y loop modificados ---
void setup() {
    Serial.begin(9600);
    trafficA.begin();
    trafficB.begin();
    trafficA.setState(TrafficLight::GREEN);
    trafficB.setState(TrafficLight::RED);
    currentCycle = GREEN_A;
    stateStartTime = millis();

    // Inicializar los pines de los nuevos periféricos
    inicializarPerifericos();

    unsigned long startTime = millis() + 75;
    for (uint8_t i = 0; i < NUM_SENSORS; i++) {
        pingTimer[i] = startTime + i * PING_INTERVAL;
        distances[i] = 0;
    }
}

void loop() {
    unsigned long now = millis();

    // Actualiza semáforos
    updateTrafficLights(now);

    // Maneja sensores ultrasónicos
    for (uint8_t i = 0; i < NUM_SENSORS; i++) {
        if (now >= pingTimer[i]) {
            pingTimer[i] += PING_INTERVAL * NUM_SENSORS;
            sensors[currentSensor].sonar->timer_stop();
            currentSensor = i;
            distances[currentSensor] = 0;
            sensors[currentSensor].sonar->ping_timer(echoCheck);
        }
    }

    if (currentSensor == NUM_SENSORS - 1) {
        processSensorReadings();
    }

    // Maneja los botones
    manejarBotones();
}

// Las funciones echoCheck, processSensorReadings y updateTrafficLights
// no necesitan cambios y se mantienen intactas.

void echoCheck() {
    if (sensors[currentSensor].sonar->check_timer()) {
        distances[currentSensor] = sensors[currentSensor].sonar->ping_result / US_ROUNDTRIP_CM;
    }
}

void processSensorReadings() {
    for (uint8_t i = 0; i < NUM_SENSORS; i++) {
        uint16_t dist = distances[i];
        if (dist == 0) continue;

        switch (sensors[i].purpose) {
        case SENSOR_PASS:
            if (dist <= 3) {
                Serial.print("Alert: Red light violation at sensor ");
                Serial.println(sensors[i].id);
                if (sensors[i].group == 0 && (currentCycle == GREEN_B || currentCycle == YELLOW_B)) {
                    Serial.println("Confirmed violation in Group A");
                } else if (sensors[i].group == 1 && (currentCycle == GREEN_A || currentCycle == YELLOW_A)) {
                    Serial.println("Confirmed violation in Group B");
                } else {
                    Serial.println("No violation - group has green/yellow");
                }
            }

            break;
        case SENSOR_ARRIVAL:
            if (dist <= 10) {
                Serial.print("Bus arrival at sensor ");
                Serial.println(sensors[i].id);
            }

            break;
        }
    }
}

void updateTrafficLights(unsigned long now) {
    switch (currentCycle) {
        case GREEN_A:
            if (now - stateStartTime >= greenTime) {
                currentCycle = YELLOW_A;
                trafficA.setState(TrafficLight::YELLOW);
                trafficB.setState(TrafficLight::RED);
                stateStartTime = now;
            }
            
            break;
        case YELLOW_A:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::GREEN);
                stateStartTime = now;
            }
            
            break;
        case GREEN_B:
            if (now - stateStartTime >= greenTime) {
                currentCycle = YELLOW_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::YELLOW);
                stateStartTime = now;
            }
            
            break;
        case YELLOW_B:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_A;
                trafficA.setState(TrafficLight::GREEN);
                trafficB.setState(TrafficLight::RED);
                stateStartTime = now;
            }

            break;
    }
}