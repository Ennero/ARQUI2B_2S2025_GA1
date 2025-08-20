#include <NewPing.h>
#include "TrafficLight.h"

// -------------------- CONFIGURACIÓN SENSORES ULTRASÓNICOS --------------------
#define MAX_DISTANCE 50
#define PING_INTERVAL 33

// --- CONFIGURACIÓN PIEZOELECTRICO (DIGITAL) ---
const int PIEZO_PIN = 3;
unsigned long lastPiezoCheck = 0;
const unsigned long piezoInterval = 500;

const int PIN_TEST = A8;

// Estados globales para construir el buffer unificado
String SEM1 = "ROJO";
String SEM2 = "ROJO";
int BUS1 = 0;
int BUS2 = 0;
int PM1 = 0;
int PM2 = 0;
int INC1 = 0;
int INC2 = 0;
int PANICO[5] = {0,0,0,0,0};
int SISMO = 0;

enum SensorPurpose { SENSOR_PASS, SENSOR_ARRIVAL };

struct Sensor {
    NewPing* sonar;
    SensorPurpose purpose;
    uint8_t id;
    uint8_t group;  // Grupo 1, Grupo 2
};

NewPing sonar[] = {
    NewPing(22, 23, MAX_DISTANCE),  // 1
    NewPing(24, 25, MAX_DISTANCE),  // 2
    NewPing(26, 27, MAX_DISTANCE),  // 3
    NewPing(28, 29, MAX_DISTANCE),  // 4
    NewPing(30, 31, MAX_DISTANCE),  // 5
    NewPing(32, 33, MAX_DISTANCE),  // 6
    NewPing(34, 35, MAX_DISTANCE),  // 7
    NewPing(36, 37, MAX_DISTANCE),  // 8
    NewPing(38, 39, MAX_DISTANCE),  // 9
    NewPing(40, 41, MAX_DISTANCE),  // 10
    NewPing(42, 43, MAX_DISTANCE),  // 11
    NewPing(44, 45, MAX_DISTANCE),  // 12
    NewPing(46, 47, MAX_DISTANCE)   // 13
};

Sensor sensors[] = {
  { &sonar[0], SENSOR_PASS   , 1, 1 },
  { &sonar[1], SENSOR_PASS   , 2, 0 },
  { &sonar[2], SENSOR_ARRIVAL, 3, 0 },
  { &sonar[3], SENSOR_PASS   , 4, 0 },
  { &sonar[4], SENSOR_PASS   , 5, 1 },
  { &sonar[5], SENSOR_PASS   , 6, 1 },
  { &sonar[6], SENSOR_PASS   , 7, 0 },
  { &sonar[7], SENSOR_PASS   , 8, 0 },
  { &sonar[8], SENSOR_PASS   , 9, 1 },
  { &sonar[9], SENSOR_ARRIVAL, 10, 0 },
  { &sonar[10], SENSOR_ARRIVAL, 11, 0 },
  { &sonar[11], SENSOR_ARRIVAL, 12, 0 },
  { &sonar[12], SENSOR_ARRIVAL, 13, 0 }
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
const unsigned long greenTime = 8000;
const unsigned long yellowTime = 3000;

// --- Constantes y Variables para Botones y Buzzers ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = {48, 52, A15, A13, A11};
const int PINES_BUZZER[NUM_BOTONES] = {49, 53, A14, A12, A10};

bool estadoAnteriorBotones[NUM_BOTONES] = {false};
unsigned long ultimaLecturaBoton[NUM_BOTONES] = {0};
const unsigned long debounceTime = 50;

unsigned long tiempoInicioBuzzer[NUM_BOTONES] = {0};
const unsigned long duracionBuzzer = 2000;

// --- CONFIGURACIÓN MQ-2 ---
const int MQ2_SENSOR_1 = A0;
const int MQ2_SENSOR_2 = A1;
const int SMOKE_THRESHOLD = 400;

unsigned long lastSmokeCheck = 0;
const unsigned long smokeInterval = 1000;

int INFRAA = 0;
int INFRAB = 0;
int INFRAC = 0;
int INFRAD = 0;

// --- Variables para emisión de estado ---
unsigned long lastEmitTime = 0;
const unsigned long emitInterval = 500;
char salidaBuffer[250];

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
    
    pinMode(PIEZO_PIN, INPUT);
    pinMode(PIN_TEST, INPUT);
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

    manejarBotones();
    controlarBuzzer();

    if (now - lastSmokeCheck >= smokeInterval) {
        leerSensoresHumo();
        lastSmokeCheck = now;
    }

    if (now - lastPiezoCheck >= piezoInterval) {
        leerPiezoelectrico();
        lastPiezoCheck = now;
    }

    // Emitir estado con control de tiempo para evitar interferencias
    if (now - lastEmitTime >= emitInterval) {
        emitirEstado();
        lastEmitTime = now;
    }

    // Test code
    // if(digitalRead(PIN_TEST) == LOW){
    //     Serial.println("JAJAJAJAJAJJAJAJAJAJJAJAJA");
    // }
}

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
        PANICO[buzzerIndex] = 1;
    }
}

void controlarBuzzer() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        if (PANICO[i] && (now - tiempoInicioBuzzer[i] >= duracionBuzzer)) {
            digitalWrite(PINES_BUZZER[i], LOW);
            PANICO[i] = 0;
        }
    }
}

void manejarBotones() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;
        if (estadoActual != estadoAnteriorBotones[i] && (now - ultimaLecturaBoton[i] >= debounceTime)) {
            if (estadoActual) {
                sonarBuzzer(i, now);
            } else {
                PANICO[i] = 0;
            }
            estadoAnteriorBotones[i] = estadoActual;
            ultimaLecturaBoton[i] = now;
        }
    }
}

void leerSensoresHumo() {
    PM1 = analogRead(MQ2_SENSOR_1);
    PM2 = analogRead(MQ2_SENSOR_2);
    INC1 = (PM1 > SMOKE_THRESHOLD) ? 1 : 0;
    INC2 = (PM2 > SMOKE_THRESHOLD) ? 1 : 0;
}

void echoCheck() {
    if (!sensors[currentSensor].sonar->check_timer()) return;

    distances[currentSensor] = sensors[currentSensor].sonar->ping_result / US_ROUNDTRIP_CM;
    uint16_t dist = distances[currentSensor];

    int* infra[] = { &INFRAA, &INFRAB, &INFRAC, &INFRAD };
    int buzzerIdx = -1;

    if (dist == 0 || dist > 3) {
        switch (sensors[currentSensor].id) {
            case 1: case 2: *infra[0] = 0; break;
            case 4: case 5: *infra[1] = 0; break;
            case 6: case 7: *infra[2] = 0; break;
            case 8: case 9: *infra[3] = 0; break;
        }
        return;
    }

    if (sensors[currentSensor].purpose == SENSOR_PASS) {
        bool active = false;
        if (sensors[currentSensor].group == 0 && (currentCycle == GREEN_B || currentCycle == YELLOW_B)) active = true;
        if (sensors[currentSensor].group == 1 && (currentCycle == GREEN_A || currentCycle == YELLOW_A)) active = true;

        if (!active) return;

        switch (sensors[currentSensor].id) {
            case 1: case 2:
                INFRAA = 1;
                buzzerIdx = 0; 
                break;
            case 4: case 5: 
                INFRAB = 1;
                buzzerIdx = 0;
                break;
            case 6: case 7: 
                INFRAC = 1;
                buzzerIdx = 3; 
                break;
            case 8: case 9: 
                INFRAD = 1;
                buzzerIdx = 2;
                break;
        }

        if (buzzerIdx >= 0) sonarBuzzer(buzzerIdx, millis());
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
            SEM1 = (currentCycle == GREEN_A) ? "VERDE" : "AMARILLO";
            SEM2 = "ROJO";
            break;

        case YELLOW_A:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::GREEN);
                stateStartTime = now;
            }
            SEM1 = "ROJO";
            SEM2 = (currentCycle == GREEN_B) ? "VERDE" : "AMARILLO";
            break;

        case GREEN_B:
            if (now - stateStartTime >= greenTime) {
                currentCycle = YELLOW_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::YELLOW);
                stateStartTime = now;
            }
            SEM1 = "ROJO";
            SEM2 = (currentCycle == GREEN_B) ? "VERDE" : "AMARILLO";
            break;

        case YELLOW_B:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_A;
                trafficA.setState(TrafficLight::GREEN);
                trafficB.setState(TrafficLight::RED);
                stateStartTime = now;
            }
            SEM1 = (currentCycle == GREEN_A) ? "VERDE" : "AMARILLO";
            SEM2 = "ROJO";
            break;
    }
}

// --- Piezoelectrico ---
void leerPiezoelectrico() {
    int piezoState = digitalRead(PIEZO_PIN);
    SISMO = (piezoState == HIGH) ? 1 : 0;
    if (SISMO == 1) {
        unsigned long now = millis();
        for (int i = 0; i < NUM_BOTONES; i++) {
            sonarBuzzer(i, now);
        }
    }
}

// --- Emitir estado unificado ---
void emitirEstado() {
    snprintf(salidaBuffer, sizeof(salidaBuffer),
        "SEM1=%s;SEM2=%s;BUS1=%d;BUS2=%d;PM1=%d;PM2=%d;INC1=%d;INC2=%d;"
        "PANICO1=%d;PANICO2=%d;PANICO3=%d;PANICO4=%d;PANICO5=%d;"
        "SISMO=%d;INFRAA=%d;INFRAB=%d;INFRAC=%d;INFRAD=%d",
        SEM1.c_str(), SEM2.c_str(),
        BUS1, BUS2, PM1, PM2, INC1, INC2,
        PANICO[0], PANICO[1], PANICO[2], PANICO[3], PANICO[4],
        SISMO, INFRAA, INFRAB, INFRAC, INFRAD
    );
    Serial.println(salidaBuffer);
}