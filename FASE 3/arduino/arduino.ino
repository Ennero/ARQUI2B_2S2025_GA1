#include <NewPing.h>
#include "TrafficLight.h"
#include "Melodies.h"

// -------------------- CONFIGURACIÓN SENSORES ULTRASÓNICOS --------------------
#define MAX_DISTANCE 50
#define PING_INTERVAL 33

// ---- Pines y rutas ----
#define RESET1_PIN 4 // reed que resetea (HIGH->LOW)
const int ROUTE1_PINS[] = {5, 6, A3, A4, A5, A6, A7, A8};
const int ROUTE2_PINS[] = {17, 16, 15, 14, 2, 13};
const uint8_t ROUTE1_COUNT = sizeof(ROUTE1_PINS) / sizeof(ROUTE1_PINS[0]);
const uint8_t ROUTE2_COUNT = sizeof(ROUTE2_PINS) / sizeof(ROUTE2_PINS[0]);
const int PIN_PIEZ = A9;

// Parámetros distancia
#define DIST1_INCREMENT 40
#define DIST2_INCREMENT 20
#define RESET_SENSOR_ID 10

int dist1 = 0;
int dist2 = 0;

// --- PIEZO ---
#define PIEZO_PIN 3
unsigned long lastPiezoCheck = 0;
const unsigned long piezoInterval = 500;

// Estados globales
const char *SEM1 = "ROJO";
const char *SEM2 = "ROJO";
int PM1 = 0;
int PM2 = 0;
int INC1 = 0;
int INC2 = 0;
int PANICO[5] = {0, 0, 0, 0, 0};
int SISMO = 0;

enum SensorPurpose
{
  SENSOR_PASS,
  SENSOR_ARRIVAL
};

struct Sensor
{
  NewPing *sonar;
  SensorPurpose purpose;
  uint8_t id;
  uint8_t group;
};

NewPing sonar[] = {
    NewPing(22, 23, MAX_DISTANCE), NewPing(24, 25, MAX_DISTANCE),
    NewPing(26, 27, MAX_DISTANCE), NewPing(28, 29, MAX_DISTANCE),
    NewPing(30, 31, MAX_DISTANCE), NewPing(32, 33, MAX_DISTANCE),
    NewPing(34, 35, MAX_DISTANCE), NewPing(36, 37, MAX_DISTANCE),
    NewPing(38, 39, MAX_DISTANCE), NewPing(40, 41, MAX_DISTANCE),
    NewPing(42, 43, MAX_DISTANCE), NewPing(44, 45, MAX_DISTANCE),
    NewPing(46, 47, MAX_DISTANCE)
};

Sensor sensors[] = {
    {&sonar[0], SENSOR_PASS, 1, 1},     {&sonar[1], SENSOR_PASS, 2, 0},
    {&sonar[2], SENSOR_ARRIVAL, 3, 0},  {&sonar[3], SENSOR_PASS, 4, 0},
    {&sonar[4], SENSOR_PASS, 5, 1},     {&sonar[5], SENSOR_PASS, 6, 1},
    {&sonar[6], SENSOR_PASS, 7, 0},     {&sonar[7], SENSOR_PASS, 8, 1},
    {&sonar[8], SENSOR_PASS, 9, 0},     {&sonar[9], SENSOR_ARRIVAL, 10, 0},
    {&sonar[10], SENSOR_ARRIVAL, 11, 0},{&sonar[11], SENSOR_ARRIVAL, 12, 0},
    {&sonar[12], SENSOR_ARRIVAL, 13, 0}
};

const uint8_t NUM_SENSORS = sizeof(sensors) / sizeof(sensors[0]);
unsigned long pingTimer[NUM_SENSORS];
uint16_t distances[NUM_SENSORS];
uint8_t currentSensor = 0;
uint8_t activeSensor = 0; // ✅ FIX CRÍTICO: Variable para el sensor que está esperando eco

// --- Semáforos ---
TrafficLight trafficA(12, 11, 10);
TrafficLight trafficB(9, 8, 7);
enum TrafficCycle { GREEN_A, YELLOW_A, GREEN_B, YELLOW_B };
TrafficCycle currentCycle = GREEN_A;
unsigned long stateStartTime = 0;
const unsigned long greenTime = 8000;
const unsigned long yellowTime = 3000;

// --- Botones ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = {48, 52, A15, A13, A11};
bool estadoAnteriorBotones[NUM_BOTONES] = {false};
unsigned long ultimaLecturaBoton[NUM_BOTONES] = {0};
const unsigned long debounceTime = 50;

// --- MQ2 ---
#define MQ2_SENSOR_1 A0
#define MQ2_SENSOR_2 A1
#define SMOKE_THRESHOLD 200
unsigned long lastSmokeCheck = 0;
const unsigned long smokeInterval = 1500;
int INFRAA = 0, INFRAB = 0, INFRAC = 0, INFRAD = 0;

// --- Emisión estado ---
unsigned long lastEmitTime = 0;
const unsigned long emitInterval = 500;

// --- Arrays de estado ---
int lastStateRoute1[ROUTE1_COUNT];
int lastStateRoute2[ROUTE2_COUNT];
int lastStateReset = HIGH;
int lastTriggeredIndexRoute2 = -1;

// ==================== FUNCIONES ====================

void leerPiezoelectrico(bool makeItSound = false)
{
  int piezoState = digitalRead(PIEZO_PIN);
  SISMO = (piezoState == HIGH) ? 1 : 0;

  if (makeItSound) {
    SISMO = 1;
  }

  if (SISMO == 1) {
    startMelody(0, ALARM_SISMO);
  }
}

void setup()
{
  Serial.begin(9600);
  setupMelodies();

  trafficA.begin();
  trafficB.begin();
  trafficA.setState(TrafficLight::GREEN);
  trafficB.setState(TrafficLight::RED);
  currentCycle = GREEN_A;
  stateStartTime = millis();
  inicializarPerifericos();

  pingTimer[0] = millis();
  for (uint8_t i = 0; i < NUM_SENSORS; i++) {
    distances[i] = 0;
  }
  currentSensor = 0;
  activeSensor = 0; // ✅ Inicializar

  pinMode(PIEZO_PIN, INPUT);
  pinMode(RESET1_PIN, INPUT_PULLUP);
  pinMode(PIN_PIEZ, INPUT_PULLUP);
  lastStateReset = digitalRead(RESET1_PIN);

  for (uint8_t i = 0; i < ROUTE1_COUNT; i++) {
    pinMode(ROUTE1_PINS[i], INPUT_PULLUP);
    lastStateRoute1[i] = digitalRead(ROUTE1_PINS[i]);
  }
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++) {
    pinMode(ROUTE2_PINS[i], INPUT_PULLUP);
    lastStateRoute2[i] = digitalRead(ROUTE2_PINS[i]);
  }
}

void loop()
{
  unsigned long now = millis();
  handleSerialCommands();
  loopMelodies();
  updateTrafficLights(now);

  // ✅ FIX CRÍTICO: Manejo correcto del round-robin de sensores
  if (now >= pingTimer[currentSensor])
  {
    activeSensor = currentSensor; // Guardar ANTES de iniciar ping
    sensors[currentSensor].sonar->ping_timer(echoCheck);
    
    // Preparar el siguiente sensor
    currentSensor++;
    if (currentSensor >= NUM_SENSORS) {
      currentSensor = 0;
    }
    pingTimer[currentSensor] = now + PING_INTERVAL;
  }

  manejarReeds();
  manejarResetReed();
  manejarBotones();

  if (now - lastSmokeCheck >= smokeInterval) {
    leerSensoresHumo();
    lastSmokeCheck = now;
  }
  
  if (now - lastPiezoCheck >= piezoInterval) {
    leerPiezoelectrico();
    lastPiezoCheck = now;
  }
  else if (digitalRead(PIN_PIEZ) == LOW) {
    leerPiezoelectrico(true);
    lastPiezoCheck = now;
  }

  if (now - lastEmitTime >= emitInterval) {
    emitirEstado();
    lastEmitTime = now;
  }
}

void handleSerialCommands()
{
  static char serialBuffer[32];
  static byte bufferIndex = 0;

  while (Serial.available() > 0)
  {
    char incomingChar = Serial.read();

    if (incomingChar == ';')
    {
      serialBuffer[bufferIndex] = '\0';
      char *command = strtok(serialBuffer, ":");
      char *valueStr = strtok(NULL, "");

      if (command != NULL && valueStr != NULL)
      {
        // ✅ FIX: Mejor validación
        int buzzerNum = atoi(valueStr);
        if (buzzerNum >= 1 && buzzerNum <= NUM_BOTONES)
        {
          int buzzerIndex = buzzerNum - 1;
          
          if (strcmp(command, "armaBlanca") == 0) {
            startMelody(buzzerIndex, ALARM_ARMABLANCA);
          }
          else if (strcmp(command, "antiRobo") == 0) {
            startMelody(buzzerIndex, ALARM_ANTIROBO);
          }
        }
      }
      bufferIndex = 0;
    }
    else if (isprint(incomingChar) && bufferIndex < (sizeof(serialBuffer) - 1))
    {
      serialBuffer[bufferIndex++] = incomingChar;
    }
  }
}

void manejarReeds()
{
  // Ruta 1
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++)
  {
    int lectura = digitalRead(ROUTE1_PINS[i]);
    if (lastStateRoute1[i] == HIGH && lectura == LOW)
    {
      dist1 = (i + 1) * DIST1_INCREMENT;
    }
    lastStateRoute1[i] = lectura;
  }

  // Ruta 2 - ✅ FIX: Corregida lógica de índices
  // ROUTE2_PINS[] = {17, 16, 15, 14, 2, 13}
  // Índices:        { 0,  1,  2,  3, 4,  5}
  // Si quieres salto entre pin 16 (índice 1) y pin 14 (índice 3):
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++)
  {
    int lectura = digitalRead(ROUTE2_PINS[i]);
    if (lastStateRoute2[i] == HIGH && lectura == LOW)
    {
      int newDist = (i + 1) * DIST2_INCREMENT;

      // Caso especial: si pasó por índice 1 y ahora detecta índice 3
      if (lastTriggeredIndexRoute2 == 1 && i == 3) {
        newDist += 20; // Salto extra de 20cm
      }

      dist2 = newDist;
      lastTriggeredIndexRoute2 = i;
    }
    lastStateRoute2[i] = lectura;
  }
}

void manejarResetReed()
{
  int lectura = digitalRead(RESET1_PIN);
  if (lastStateReset == HIGH && lectura == LOW)
  {
    dist1 = 0;
    dist2 = 0;
    lastTriggeredIndexRoute2 = -1;
  }
  lastStateReset = lectura;
}

void inicializarPerifericos()
{
  pinMode(MQ2_SENSOR_1, INPUT);
  pinMode(MQ2_SENSOR_2, INPUT);
}

void manejarBotones()
{
  unsigned long now = millis();
  for (int i = 0; i < NUM_BOTONES; i++)
  {
    bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;
    if (estadoActual != estadoAnteriorBotones[i] && 
        (now - ultimaLecturaBoton[i] >= debounceTime))
    {
      if (estadoActual) {
        startMelody(i, ALARM_PANIC);
        PANICO[i] = 1;
      }
      estadoAnteriorBotones[i] = estadoActual;
      ultimaLecturaBoton[i] = now;
    }
  }
}

void leerSensoresHumo()
{
  PM1 = analogRead(MQ2_SENSOR_1);
  PM2 = analogRead(MQ2_SENSOR_2);
  INC1 = (PM1 > SMOKE_THRESHOLD) ? 1 : 0;
  INC2 = (PM2 > SMOKE_THRESHOLD) ? 1 : 0;

  if (INC1) {
    startMelody(2, ALARM_GAS);
  }
  if (INC2) {
    startMelody(3, ALARM_GAS);
  }
}

// ✅ FIX CRÍTICO: Ahora usa activeSensor en lugar de currentSensor
void echoCheck()
{
  if (!sensors[activeSensor].sonar->check_timer())
    return;

  distances[activeSensor] = sensors[activeSensor].sonar->ping_result / US_ROUNDTRIP_CM;
  uint16_t dist = distances[activeSensor];

  int buzzerIdx = -1;

  if (dist == 0 || dist > 3)
  {
    switch (sensors[activeSensor].id)
    {
    case 1: case 2:
      INFRAA = 0;
      break;
    case 4: case 5:
      INFRAB = 0;
      break;
    case 6: case 7:
      INFRAC = 0;
      break;
    case 8: case 9:
      INFRAD = 0;
      break;
    }
    return;
  }

  if (sensors[activeSensor].purpose == SENSOR_PASS)
  {
    bool active = false;
    if (sensors[activeSensor].group == 0 && 
        (currentCycle == GREEN_B || currentCycle == YELLOW_B))
      active = true;
    if (sensors[activeSensor].group == 1 && 
        (currentCycle == GREEN_A || currentCycle == YELLOW_A))
      active = true;
    if (!active)
      return;

    switch (sensors[activeSensor].id)
    {
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
    if (buzzerIdx >= 0) {
      startMelody(buzzerIdx, ALARM_INFRACTION);
    }
  }

  if (sensors[activeSensor].purpose == SENSOR_ARRIVAL)
  {
    if (sensors[activeSensor].id == RESET_SENSOR_ID) {
      dist2 = 0;
      lastTriggeredIndexRoute2 = -1;
    }
    else if (sensors[activeSensor].id == 13) {
      dist2 = 80;
    }
  }
}

void updateTrafficLights(unsigned long now)
{
  unsigned long timeInState = now - stateStartTime;

  switch (currentCycle)
  {
  case GREEN_A:
    if (timeInState >= greenTime) {
      currentCycle = YELLOW_A;
      stateStartTime = now;
    }
    break;
  case YELLOW_A:
    if (timeInState >= yellowTime) {
      currentCycle = GREEN_B;
      stateStartTime = now;
    }
    break;
  case GREEN_B:
    if (timeInState >= greenTime) {
      currentCycle = YELLOW_B;
      stateStartTime = now;
    }
    break;
  case YELLOW_B:
    if (timeInState >= yellowTime) {
      currentCycle = GREEN_A;
      stateStartTime = now;
    }
    break;
  }

  if (currentCycle == GREEN_A) {
    trafficA.setState(TrafficLight::GREEN);
    trafficB.setState(TrafficLight::RED);
    SEM1 = "VERDE";
    SEM2 = "ROJO";
  }
  else if (currentCycle == YELLOW_A) {
    trafficA.setState(TrafficLight::YELLOW);
    trafficB.setState(TrafficLight::RED);
    SEM1 = "AMARILLO";
    SEM2 = "ROJO";
  }
  else if (currentCycle == GREEN_B) {
    trafficA.setState(TrafficLight::RED);
    trafficB.setState(TrafficLight::GREEN);
    SEM1 = "ROJO";
    SEM2 = "VERDE";
  }
  else {
    trafficA.setState(TrafficLight::RED);
    trafficB.setState(TrafficLight::YELLOW);
    SEM1 = "ROJO";
    SEM2 = "AMARILLO";
  }
}

// ✅ OPTIMIZADO: Usa F() macro para ahorrar RAM
void emitirEstado()
{
  Serial.print(F("SEM1="));
  Serial.print(SEM1);
  Serial.print(F(";SEM2="));
  Serial.print(SEM2);
  Serial.print(F(";PM1="));
  Serial.print(PM1);
  Serial.print(F(";PM2="));
  Serial.print(PM2);
  Serial.print(F(";INC1="));
  Serial.print(INC1);
  Serial.print(F(";INC2="));
  Serial.print(INC2);
  Serial.print(F(";PANICO1="));
  Serial.print(PANICO[0]);
  Serial.print(F(";PANICO2="));
  Serial.print(PANICO[1]);
  Serial.print(F(";PANICO3="));
  Serial.print(PANICO[2]);
  Serial.print(F(";PANICO4="));
  Serial.print(PANICO[3]);
  Serial.print(F(";PANICO5="));
  Serial.print(PANICO[4]);
  Serial.print(F(";SISMO="));
  Serial.print(SISMO);
  Serial.print(F(";INFRAA="));
  Serial.print(INFRAA);
  Serial.print(F(";INFRAB="));
  Serial.print(INFRAB);
  Serial.print(F(";INFRAC="));
  Serial.print(INFRAC);
  Serial.print(F(";INFRAD="));
  Serial.print(INFRAD);
  Serial.print(F(";DIST1="));
  Serial.print(dist1);
  Serial.print(F(";DIST2="));
  Serial.println(dist2);

  // Limpiar banderas
  for (int i = 0; i < NUM_BOTONES; i++) {
    PANICO[i] = 0;
  }
  INFRAA = 0;
  INFRAB = 0;
  INFRAC = 0;
  INFRAD = 0;
  INC1 = 0;
  INC2 = 0;
  SISMO = 0;
}