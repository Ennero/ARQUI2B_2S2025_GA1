#include <NewPing.h>
#include "TrafficLight.h"

// -------------------- CONFIGURACIÓN SENSORES ULTRASÓNICOS --------------------
#define MAX_DISTANCE 50
#define PING_INTERVAL 33

// --- CONFIGURACIÓN PIEZOELECTRICO ---
const int PIEZO_PIN = A8;
const int PIEZO_THRESHOLD = 100;  // Ajusta según sensibilidad
unsigned long lastPiezoCheck = 0;
const unsigned long piezoInterval = 500; // revisar cada 0.5s

enum SensorPurpose { SENSOR_PASS,
                     SENSOR_ARRIVAL };

struct Sensor {
  NewPing* sonar;
  SensorPurpose purpose;
  uint8_t id;
  uint8_t group;  // 0 = A, 1 = B
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
  { &sonar[0], SENSOR_PASS   , 1, 0 },
  { &sonar[1], SENSOR_PASS   , 2, 1 },
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
        // Serial.print(";BUS");
        // Serial.print(buzzerIndex + 1);
        // Serial.print("=");
        // Serial.print(1);
    }
}

void controlarBuzzer() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        if (digitalRead(PINES_BUZZER[i]) == HIGH && (now - tiempoInicioBuzzer[i] >= duracionBuzzer)) {
            digitalWrite(PINES_BUZZER[i], LOW);
            Serial.print("Buzzer ");
            Serial.print(i + 1);
            Serial.println(" apagado.");
        }
    }
}

void manejarBotones() {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) {
        bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;

        if (estadoActual != estadoAnteriorBotones[i] && (now - ultimaLecturaBoton[i] >= debounceTime)) {
            if (estadoActual) {
                Serial.print("Boton ");
                Serial.print(i + 1);
                Serial.println(" presionado. Activando buzzer.");
                sonarBuzzer(i, now);
                //! DATA EMITION (on clicked button)
                // Serial.print(";PANICO=");
                // Serial.print(i + 1);
                // Serial.print("=");
                // Serial.print(1);
            }
            estadoAnteriorBotones[i] = estadoActual;
            ultimaLecturaBoton[i] = now;
        }
    }
}

void leerSensoresHumo() {
    int smoke1 = analogRead(MQ2_SENSOR_1);
    int smoke2 = analogRead(MQ2_SENSOR_2);

    Serial.print("MQ-2 Sensor 1: ");
    Serial.println(smoke1);
    Serial.print("MQ-2 Sensor 2: ");
    Serial.println(smoke2);

    //! DATA EMITION (particles)
    Serial.print(";PM1=");
    Serial.print(smoke1);
    Serial.print(";PM2=");
    Serial.print(smoke2);

    if (smoke1 > SMOKE_THRESHOLD) {
        Serial.println("⚠ ALERTA: Nivel de humo ALTO en sensor 1");
        //! DATA EMITION
        // Serial.print(";SMOKE1=");
        // Serial.print(1);
    }

    if (smoke2 > SMOKE_THRESHOLD) {
        //! DATA EMITION
        // Serial.print(";SMOKE2=");
        // Serial.print(1);
        Serial.println("⚠ ALERTA: Nivel de humo ALTO en sensor 2");
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

        if (dist <= 3) {
            switch (sensors[i].purpose) {
            case SENSOR_PASS:
                Serial.print("Bus detectado en sensor ");
                Serial.print(sensors[i].id);
                Serial.print(": ");
                //! DATA EMITION (Ultrasonic)
                // Serial.print(";INFRACCION");
                // Serial.print(sensors[i].id + 1);
                // Serial.print("=");
                // Serial.print(1);
                
                if (sensors[i].group == 0 && (currentCycle == GREEN_B || currentCycle == YELLOW_B)) {
                    Serial.println("violación - paso en rojo en un semáforo del grupo A");
                } else if (sensors[i].group == 1 && (currentCycle == GREEN_A || currentCycle == YELLOW_A)) {
                    Serial.println("violación - paso en rojo en un semáforo del grupo B");
                } else { 
                    Serial.println("sin violación - paso con el semáforo verde/amarillo");
                }
                break;

            case SENSOR_ARRIVAL:
                Serial.print("Bus llego al sensor ");
                Serial.println(sensors[i].id);
                break;
            }
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
                // Serial.print(";SEM1=YELLOW");
                // Serial.print(";SEM2=RED");
            }
            break;

        case YELLOW_A:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::GREEN);
                stateStartTime = now;0
                //! DATA EMITION (TRAFFIC LIGHTS)
                // Serial.print(";SEM1=RED");
                // Serial.print(";SEM2=GREEN");
            }
            break;

        case GREEN_B:
            if (now - stateStartTime >= greenTime) {
                currentCycle = YELLOW_B;
                trafficA.setState(TrafficLight::RED);
                trafficB.setState(TrafficLight::YELLOW);
                stateStartTime = now;
                //! DATA EMITION (TRAFFIC LIGHTS)
                // Serial.print(";SEM1=RED");
                // Serial.print(";SEM2=YELLOW");
            }
            break;

        case YELLOW_B:
            if (now - stateStartTime >= yellowTime) {
                currentCycle = GREEN_A;
                trafficA.setState(TrafficLight::GREEN);
                trafficB.setState(TrafficLight::RED);
                stateStartTime = now;
                //! DATA EMITION (TRAFFIC LIGHTS)
                // Serial.print(";SEM1=GREEN");
                // Serial.print(";SEM2=RED");
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

    // Init piezoeletrico
    pinMode(PIEZO_PIN, INPUT);
}

// --- Piezoelectrico ---
void leerPiezoelectrico() {
    int piezoValue = analogRead(PIEZO_PIN);

    if (piezoValue > PIEZO_THRESHOLD) {
        //! DATA EMITION (Piezoelectric)
        Serial.print(";SISMO");
        Serial.print("=");
        Serial.print(1);
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

    if (now - lastPiezoCheck >= piezoInterval) {
        leerPiezoelectrico();
        lastPiezoCheck = now;
    } else {
        Serial.println(";SISMO=0");
    }

    // Serial.println();

    // TODO: still need to implement piezoelectrico data emition
}
