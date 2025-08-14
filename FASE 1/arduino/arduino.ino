#include <NewPing.h>
#include "TrafficLight.h"

// --- Constantes para Sensores Ultrasónicos ---
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
  NewPing(24, 25, MAX_DISTANCE),
  NewPing(26, 27, MAX_DISTANCE),
  NewPing(28, 29, MAX_DISTANCE),
  NewPing(30, 31, MAX_DISTANCE),
  NewPing(32, 33, MAX_DISTANCE),
  NewPing(34, 35, MAX_DISTANCE),
  NewPing(36, 37, MAX_DISTANCE),
  NewPing(38, 39, MAX_DISTANCE),
  NewPing(40, 41, MAX_DISTANCE),
  NewPing(42, 43, MAX_DISTANCE),
  NewPing(44, 45, MAX_DISTANCE),
  NewPing(46, 47, MAX_DISTANCE) // 12
};

Sensor sensors[] = {
  { &sonar[0],  SENSOR_PASS,    0, 0 },
  { &sonar[1],  SENSOR_ARRIVAL, 1, 0 },
  { &sonar[2],  SENSOR_PASS,    2, 1 },
  { &sonar[3],  SENSOR_ARRIVAL, 3, 1 },
  { &sonar[4],  SENSOR_PASS,    4, 0 },
  { &sonar[5],  SENSOR_ARRIVAL, 5, 0 },
  { &sonar[6],  SENSOR_PASS,    6, 1 },
  { &sonar[7],  SENSOR_ARRIVAL, 7, 1 },
  { &sonar[8],  SENSOR_PASS,    8, 0 },
  { &sonar[9],  SENSOR_ARRIVAL, 9, 0 },
  { &sonar[10], SENSOR_PASS,    10, 1 },
  { &sonar[11], SENSOR_ARRIVAL, 11, 1 },
  { &sonar[12], SENSOR_PASS,    12, 0 }
};

const uint8_t NUM_SENSORS = sizeof(sensors) / sizeof(sensors[0]);

unsigned long pingTimer[NUM_SENSORS];
uint16_t distances[NUM_SENSORS];
uint8_t currentSensor = 0;

// --- Constantes para Semáforos ---
TrafficLight trafficA(12, 11, 10);
TrafficLight trafficB(9, 8, 7);

enum TrafficCycle { GREEN_A, YELLOW_A, GREEN_B, YELLOW_B };
TrafficCycle currentCycle = GREEN_A;

unsigned long stateStartTime = 0;
const unsigned long greenTime = 4000;
const unsigned long yellowTime = 1500;

// --- Constantes y Variables para Botones y Buzzers ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = {48, 52, A15, A13, A11};
const int PINES_BUZZER[NUM_BOTONES] = {49, 53, A14, A12, A10};

bool estadoAnteriorBotones[NUM_BOTONES] = {false};
unsigned long ultimaLecturaBoton[NUM_BOTONES] = {0};
const unsigned long debounceTime = 50;

unsigned long tiempoInicioBuzzer[NUM_BOTONES] = {0};
// Duración del buzzer: n segundos * 1000
const unsigned long duracionBuzzer = 2000; // Sonará por 2 segundos

// --- CONFIGURACIÓN MQ-2 ---
const int MQ2_SENSOR_1 = A0;
const int MQ2_SENSOR_2 = A1;
const int SMOKE_THRESHOLD = 400;

unsigned long lastSmokeCheck = 0;
const unsigned long smokeInterval = 1000;

// --- Funciones Modulares ---
void inicializarPerifericos() {
    for (int i = 0; i < NUM_BOTONES; i++) {
        pinMode(PINES_BOTONES[i], INPUT_PULLUP);
        pinMode(PINES_BUZZER[i], OUTPUT);
        digitalWrite(PINES_BUZZER[i], LOW);
    }
    pinMode(MQ2_SENSOR_1, INPUT);
    pinMode(MQ2_SENSOR_2, INPUT);
}

void sonarBuzzer(int buzzerIndex, unsigned long now) {
    if (buzzerIndex >= 0 && buzzerIndex < NUM_BOTONES) {
        digitalWrite(PINES_BUZZER[buzzerIndex], HIGH);
        tiempoInicioBuzzer[buzzerIndex] = now;
        //! DATA EMITION (sonar buzzer)
        Serial.print(";BUS");
        Serial.print(buzzerIndex + 1);
        Serial.print("=");
        Serial.print(1);
    }
}

void controlarBuzzer() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        if (digitalRead(PINES_BUZZER[i]) == HIGH && (now - tiempoInicioBuzzer[i] >= duracionBuzzer)) {
            digitalWrite(PINES_BUZZER[i], LOW);
            //   Serial.print("Buzzer ");
            //   Serial.print(i + 1);
            //   Serial.println(" apagado.");
        }
    }
}

void manejarBotones() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;

        if (estadoActual != estadoAnteriorBotones[i] && (now - ultimaLecturaBoton[i] >= debounceTime)) {
            if (estadoActual) {
                // Serial.print("Boton ");
                // Serial.print(i + 1);
                // Serial.println(" presionado. Activando buzzer.");
                sonarBuzzer(i, now);
                //! DATA EMITION (on clicked button)
                Serial.print(";PANICO=");
                Serial.print(i + 1);
                Serial.print("=");
                Serial.print(1);
            }
            estadoAnteriorBotones[i] = estadoActual;
            ultimaLecturaBoton[i] = now;
        }
    }
}

void leerSensoresHumo() {
    int smoke1 = analogRead(MQ2_SENSOR_1);
    int smoke2 = analogRead(MQ2_SENSOR_2);

    //   Serial.print("MQ-2 Sensor 1: ");
    //   Serial.println(smoke1);
    //   Serial.print("MQ-2 Sensor 2: ");
    //   Serial.println(smoke2);

    if (smoke1 > SMOKE_THRESHOLD) {
        // Serial.println("⚠ ALERTA: Nivel de humo ALTO en sensor 1");
        //! DATA EMITION
        Serial.print(";SMOKE1=");
        Serial.print(1);
    }
    if (smoke2 > SMOKE_THRESHOLD) {
        //! DATA EMITION
        Serial.print(";SMOKE2=");
        Serial.print(1);
        // Serial.println("⚠ ALERTA: Nivel de humo ALTO en sensor 2");
    }
}

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
                //   Serial.print("Alert: Red light violation at sensor ");
                //   Serial.println(sensors[i].id);
                //! DATA EMITION (Ultrasonic)
                Serial.print(";INFRACCION");
                Serial.print(sensors[i].id + 1);
                Serial.print("=");
                Serial.print(1);
                
                if (sensors[i].group == 0 && (currentCycle == GREEN_B || currentCycle == YELLOW_B)) {
                    // Serial.println("Confirmed violation in Group A");
                } else if (sensors[i].group == 1 && (currentCycle == GREEN_A || currentCycle == YELLOW_A)) {
                    // Serial.println("Confirmed violation in Group B");
                } else {
                    // Serial.println("No violation - group has green/yellow");
                }
            }
            break;

        case SENSOR_ARRIVAL:
            if (dist <= 10) {
            //   Serial.print("Bus arrival at sensor ");
            //   Serial.println(sensors[i].id);
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
                //! DATA EMITION (TRAFFIC LIGHTS)
                Serial.print(";SEM1=YELLOW");
                Serial.print(";SEM2=RED");
            }
            break;

        case YELLOW_A:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::GREEN);
                stateStartTime = now;
                //! DATA EMITION (TRAFFIC LIGHTS)
                Serial.print(";SEM1=RED");
                Serial.print(";SEM2=GREEN");
            }
            break;

        case GREEN_B:
            if (now - stateStartTime >= greenTime) {
                currentCycle = YELLOW_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::YELLOW);
                stateStartTime = now;
                //! DATA EMITION (TRAFFIC LIGHTS)
                Serial.print(";SEM1=RED");
                Serial.print(";SEM2=YELLOW");
            }
            break;

        case YELLOW_B:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_A;
                trafficA.setState(TrafficLight::GREEN);
                trafficB.setState(TrafficLight::RED);
                stateStartTime = now;
                //! DATA EMITION (TRAFFIC LIGHTS)
                Serial.print(";SEM1=GREEN");
                Serial.print(";SEM2=RED");
            }
            break;
    }
}

// --- Configuración Inicial (setup) ---
void setup() {
    Serial.begin(9600);
    trafficA.begin();
    trafficB.begin();
    trafficA.setState(TrafficLight::GREEN);
    trafficB.setState(TrafficLight::RED);
    currentCycle = GREEN_A;
    stateStartTime = millis();
    inicializarPerifericos();

    unsigned long startTime = millis() + 75;
    for (uint8_t i = 0; i < NUM_SENSORS; i++) {
        pingTimer[i] = startTime + i * PING_INTERVAL;
        distances[i] = 0;
    }
}

// --- Bucle Principal (loop) ---
void loop() {
    unsigned long now = millis();

    updateTrafficLights(now);

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

    manejarBotones();
    controlarBuzzer();

    if (now - lastSmokeCheck >= smokeInterval) {
        leerSensoresHumo();
        lastSmokeCheck = now;
    }

    Serial.println();

    // TODO: still need to implement piezoelectrico data emition
}