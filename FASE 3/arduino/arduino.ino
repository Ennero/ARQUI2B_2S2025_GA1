#include <NewPing.h>
#include "TrafficLight.h"

// -------------------- CONFIGURACIÓN SENSORES ULTRASÓNICOS --------------------
#define MAX_DISTANCE 50
#define PING_INTERVAL 33

// ---- Pines y rutas ----
#define RESET1_PIN 4  // reed que resetea (HIGH->LOW)
const int ROUTE1_PINS[] = { 5, 6, A3, A4, A5, A6, A7, A8 };
const int ROUTE2_PINS[] = { 17, 16, 15, 14, 2, 13 };
const uint8_t ROUTE1_COUNT = sizeof(ROUTE1_PINS) / sizeof(ROUTE1_PINS[0]);
const uint8_t ROUTE2_COUNT = sizeof(ROUTE2_PINS) / sizeof(ROUTE2_PINS[0]);
// --- MODIFICADO --- Único pin para el piezo, configurado como PULLUP para una detección estable
const int PIN_PIEZ = A9;

// Parámetros distancia
#define DIST1_INCREMENT 40  // cm por "paso" (40, 80, 120...)
#define DIST2_INCREMENT 20  // cm por "paso" (20, 40, 60...)

#define RESET_SENSOR_ID 10  // sensor ultrasónico que resetea dist2 al detectar llegada (<=3cm)

int dist1 = 0;
int dist2 = 0;

// --- PIEZO ---
// #define PIEZO_PIN 3 // --- ELIMINADO --- Se elimina la definición duplicada y confusa.
unsigned long lastPiezoCheck = 0;
const unsigned long piezoInterval = 500; // Intervalo para revisar el sensor

// Estados globales
String SEM1 = "ROJO";
String SEM2 = "ROJO";
int BUS1 = 0;
int BUS2 = 0;
int PM1 = 0;
int PM2 = 0;
int INC1 = 0;
int INC2 = 0;
int PANICO[5] = { 0, 0, 0, 0, 0 };
int SISMO = 0;

// Banderitas para el coso a enviar
int SISMO_a_enviar = 0;
int INC1_a_enviar = 0;
int INC2_a_enviar = 0;
int PANICO_a_enviar[5] = { 0, 0, 0, 0, 0 };


enum SensorPurpose { SENSOR_PASS, SENSOR_ARRIVAL };
struct Sensor {
  NewPing* sonar;
  SensorPurpose purpose;
  uint8_t id;
  uint8_t group;
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
  { &sonar[0], SENSOR_PASS, 1, 1 },
  { &sonar[1], SENSOR_PASS, 2, 0 },
  { &sonar[2], SENSOR_ARRIVAL, 3, 0 },
  { &sonar[3], SENSOR_PASS, 4, 0 },
  { &sonar[4], SENSOR_PASS, 5, 1 },
  { &sonar[5], SENSOR_PASS, 6, 1 },
  { &sonar[6], SENSOR_PASS, 7, 0 },
  { &sonar[7], SENSOR_PASS, 8, 1 },
  { &sonar[8], SENSOR_PASS, 9, 0 },
  { &sonar[9], SENSOR_ARRIVAL, 10, 0 },  // sensor 10
  { &sonar[10], SENSOR_ARRIVAL, 11, 0 },
  { &sonar[11], SENSOR_ARRIVAL, 12, 0 },
  { &sonar[12], SENSOR_ARRIVAL, 13, 0 }
};
const uint8_t NUM_SENSORS = sizeof(sensors) / sizeof(sensors[0]);
unsigned long pingTimer[NUM_SENSORS];
uint16_t distances[NUM_SENSORS];
uint8_t currentSensor = 0;
// --- Semáforos ---
TrafficLight trafficA(12, 11, 10);
TrafficLight trafficB(9, 8, 7);
enum TrafficCycle { GREEN_A, YELLOW_A, GREEN_B, YELLOW_B };
TrafficCycle currentCycle = GREEN_A;
unsigned long stateStartTime = 0;
const unsigned long greenTime = 8000;
const unsigned long yellowTime = 3000;

// --- Botones (sin cambios) ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = { 48, 52, A15, A13, A11 };
bool estadoAnteriorBotones[NUM_BOTONES] = { false };
unsigned long ultimaLecturaBoton[NUM_BOTONES] = { 0 };
const unsigned long debounceTime = 50;

// -------------------- NUEVO SISTEMA DE PATRONES DE SONIDO --------------------
const int PINES_BUZZER[NUM_BOTONES] = { 49, 53, A14, A12, A10 };

enum SoundPattern {
  PATTERN_NONE,
  PATTERN_PANIC,
  PATTERN_SMOKE,
  PATTERN_INFRA,
  PATTERN_SEISMIC,
  PATTERN_ARMABLANCA,
  PATTERN_ANTIROBO
};

const int PATTERN_PANIC_DURATIONS[] = {100, 100, 100, 100, 100, 300, 300, 100, 300, 100, 300, 300, 100, 100, 100, 100, 100, 800};
const int PATTERN_SMOKE_DURATIONS[] = {800, 400, 800, 400};
const int PATTERN_INFRA_DURATIONS[] = {250, 250, 250, 1000};
const int PATTERN_SEISMIC_DURATIONS[] = {2000, 0}; // 2 segundos continuos
const int PATTERN_ARMABLANCA_DURATIONS[] = {60, 60, 60, 60, 60, 60, 60, 1000};
const int PATTERN_ANTIROBO_DURATIONS[] = {500, 250, 500, 1000};

struct BuzzerState {
  SoundPattern currentPattern;
  int patternStep;
  unsigned long lastStepTime;
  const int* durations;
  int patternLength;
};
BuzzerState buzzerStates[NUM_BOTONES];
// ----------------------------------------------------------------------------

// --- Lógica para el puerto serial ---
String serialBuffer = "";

// --- MQ2 ---
#define MQ2_SENSOR_1 A0
#define MQ2_SENSOR_2 A1
#define SMOKE_THRESHOLD 600

unsigned long lastSmokeCheck = 0;
const unsigned long smokeInterval = 1000;
int INFRAA = 0, INFRAB = 0, INFRAC = 0, INFRAD = 0;
// --- Emisión estado ---
unsigned long lastEmitTime = 0;
const unsigned long emitInterval = 500;
char salidaBuffer[320];

// --- Reset reed ---
int lastStateReset = HIGH;

// --- ELIMINADO --- La función original `leerPiezoelectrico` se elimina.
// Su lógica se ha refactorizado y mejorado en `activarAlarmaSismica` y `controlarBuzzer`.

// +++ NUEVA FUNCIÓN PARA CENTRALIZAR LA ALARMA SÍSMICA +++
void activarAlarmaSismica() {
  // Solo activa la alarma si no está ya activa, para evitar reinicios constantes
  // mientras el sensor sigue vibrando.
  if (SISMO == 1) return;

  // 1. Poner la bandera global de SISMO en 1. Ahora SISMO=1 se enviará
  //    porque la alarma ha comenzado.
  SISMO = 1; 
  SISMO_a_enviar = 1; // Marcar para que se envíe una vez
  unsigned long now = millis();

  // 2. Activar el patrón sísmico en TODOS los buzzers.
  for (int i = 0; i < NUM_BOTONES; i++) {
    startBuzzerPattern(i, now, PATTERN_SEISMIC);
  }
}

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

  // RESET reed
  pinMode(RESET1_PIN, INPUT_PULLUP);
  lastStateReset = digitalRead(RESET1_PIN);

  // --- MODIFICADO --- Se asegura que el pin del piezo esté configurado correctamente.
  pinMode(PIN_PIEZ, INPUT_PULLUP);

  // reeds rutas (solo lectura inicial)
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++) {
    pinMode(ROUTE1_PINS[i], INPUT_PULLUP);
  }
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++) {
    pinMode(ROUTE2_PINS[i], INPUT_PULLUP);
  }
}

void loop() {
  unsigned long now = millis();

  manejarSerial();
  updateTrafficLights(now);
  
  // sonar round-robin
  for (uint8_t i = 0; i < NUM_SENSORS; i++) {
    if (now >= pingTimer[i]) {
      pingTimer[i] += PING_INTERVAL * NUM_SENSORS;
      sensors[currentSensor].sonar->timer_stop();
      currentSensor = i;
      distances[currentSensor] = 0;
      sensors[currentSensor].sonar->ping_timer(echoCheck);
    }
  }

  manejarReeds();
  manejarResetReed();
  manejarBotones();
  controlarBuzzer(); // Gestiona patrones Y AHORA TAMBIÉN apaga SISMO=0 cuando corresponde

  if (now - lastSmokeCheck >= smokeInterval) {
    leerSensoresHumo();
    lastSmokeCheck = now;
  }

  // +++ LÓGICA DE PIEZO MODIFICADA Y SIMPLIFICADA +++
  // Se revisa el sensor piezoeléctrico en intervalos regulares.
  if (now - lastPiezoCheck >= piezoInterval) {
    // Si el pin está en BAJO (activado, ya que es PULLUP), se inicia la alarma.
    if (digitalRead(PIN_PIEZ) == LOW) {
      activarAlarmaSismica(); // Llama a la nueva función que activa los buzzers y pone SISMO=1
    }
    lastPiezoCheck = now; // Actualiza el tiempo de la última revisión en cualquier caso.
  }

  // emitir estado periódicamente (único Serial.println)
  if (now - lastEmitTime >= emitInterval) {
    emitirEstado();
    lastEmitTime = now;
  }
}

void manejarSerial() {
  while (Serial.available() > 0) {
    char receivedChar = Serial.read();

    if (receivedChar == ';') {
      serialBuffer.trim();
      int colonIndex = serialBuffer.indexOf(':');

      if (colonIndex > 0) {
        String command = serialBuffer.substring(0, colonIndex);
        int value = serialBuffer.substring(colonIndex + 1).toInt();

        if (value > 0 && value <= NUM_BOTONES) {
          int buzzerIndex = value - 1;
          SoundPattern patternToPlay = PATTERN_NONE;

          if (command.equalsIgnoreCase("armaBlanca")) {
            patternToPlay = PATTERN_ARMABLANCA;
          } else if (command.equalsIgnoreCase("antiRobo")) {
            patternToPlay = PATTERN_ANTIROBO;
          }

          if (patternToPlay != PATTERN_NONE) {
            startBuzzerPattern(buzzerIndex, millis(), patternToPlay);
          }
        }
      }
      
      serialBuffer = "";
    } else {
      if (receivedChar != '\n' && receivedChar != '\r') {
        serialBuffer += receivedChar;
      }
    }
  }
}

void manejarReeds() {
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++) {
    int pin = ROUTE1_PINS[i];
    int lectura = digitalRead(pin);
    if (lectura == LOW) {
      int newDist = (i + 1) * DIST1_INCREMENT;
      if (newDist != dist1) dist1 = newDist;
    }
  }

  for (uint8_t i = 0; i < ROUTE2_COUNT; i++) {
    int pin = ROUTE2_PINS[i];
    int lectura = digitalRead(pin);
    if (lectura == LOW) {
      int newDist = (i + 1) * DIST2_INCREMENT;
      if (i > 2) newDist = newDist + 20;
      if (newDist != dist2) dist2 = newDist;
    }
  }
}

void manejarResetReed() {
  int lectura = digitalRead(RESET1_PIN);
  if (lastStateReset == HIGH && lectura == LOW) {
    dist1 = 0;
    dist2 = 0;
  }
  lastStateReset = lectura;
}

void inicializarPerifericos() {
  for (int i = 0; i < NUM_BOTONES; i++) {
    pinMode(PINES_BOTONES[i], INPUT_PULLUP);
    pinMode(PINES_BUZZER[i], OUTPUT);
    digitalWrite(PINES_BUZZER[i], LOW);
    buzzerStates[i].currentPattern = PATTERN_NONE;
  }
  pinMode(MQ2_SENSOR_1, INPUT);
  pinMode(MQ2_SENSOR_2, INPUT);
}

void startBuzzerPattern(int buzzerIndex, unsigned long now, SoundPattern pattern) {
  if (buzzerIndex < 0 || buzzerIndex >= NUM_BOTONES) return;

  BuzzerState& state = buzzerStates[buzzerIndex];
  state.currentPattern = pattern;
  state.patternStep = 0;
  state.lastStepTime = now;

  if (pattern == PATTERN_PANIC) {
    PANICO[buzzerIndex] = 1;
    PANICO_a_enviar[buzzerIndex] = 1; // Marcar para envío
  } else {
    // Si se activa otro patrón, el estado de pánico se apaga.
    // El apagado final se gestiona en controlarBuzzer.
    PANICO[buzzerIndex] = 0; 
  }

  

  // PANICO[buzzerIndex] = (pattern == PATTERN_PANIC) ? 1 : 0;

  switch (pattern) {
    case PATTERN_PANIC:
      state.durations = PATTERN_PANIC_DURATIONS;
      state.patternLength = sizeof(PATTERN_PANIC_DURATIONS) / sizeof(int);
      break;
    case PATTERN_SMOKE:
      state.durations = PATTERN_SMOKE_DURATIONS;
      state.patternLength = sizeof(PATTERN_SMOKE_DURATIONS) / sizeof(int);
      break;
    case PATTERN_INFRA:
      state.durations = PATTERN_INFRA_DURATIONS;
      state.patternLength = sizeof(PATTERN_INFRA_DURATIONS) / sizeof(int);
      break;
    case PATTERN_SEISMIC:
      state.durations = PATTERN_SEISMIC_DURATIONS;
      state.patternLength = sizeof(PATTERN_SEISMIC_DURATIONS) / sizeof(int);
      break;
    case PATTERN_ARMABLANCA:
      state.durations = PATTERN_ARMABLANCA_DURATIONS;
      state.patternLength = sizeof(PATTERN_ARMABLANCA_DURATIONS) / sizeof(int);
      break;
    case PATTERN_ANTIROBO:
      state.durations = PATTERN_ANTIROBO_DURATIONS;
      state.patternLength = sizeof(PATTERN_ANTIROBO_DURATIONS) / sizeof(int);
      break;
    default:
      state.currentPattern = PATTERN_NONE;
      PANICO[buzzerIndex] = 0;
      digitalWrite(PINES_BUZZER[buzzerIndex], LOW);
      return;
  }
  
  digitalWrite(PINES_BUZZER[buzzerIndex], HIGH);
}

void sonarBuzzer(int buzzerIndex, unsigned long now) {
  startBuzzerPattern(buzzerIndex, now, PATTERN_SEISMIC);
}

// --- MODIFICADO --- Se añade la lógica para apagar la bandera SISMO.
void controlarBuzzer() {
  unsigned long now = millis();
  for (int i = 0; i < NUM_BOTONES; i++) {
    BuzzerState& state = buzzerStates[i];
    if (state.currentPattern == PATTERN_NONE) continue;

    if (now - state.lastStepTime >= state.durations[state.patternStep]) {
      state.patternStep++;
      state.lastStepTime = now;

      if (state.patternStep >= state.patternLength) {
        digitalWrite(PINES_BUZZER[i], LOW);
        state.currentPattern = PATTERN_NONE;
        PANICO[i] = 0;
      } else {
        digitalWrite(PINES_BUZZER[i], (state.patternStep % 2 == 0) ? HIGH : LOW);
      }
    }
  }

  // +++ NUEVA LÓGICA PARA APAGAR LA BANDERA SISMO +++
  // Después de actualizar todos los buzzers, verificamos si la alarma sísmica debe terminar.
  if (SISMO == 1) {
    bool sismoSigueActivo = false;
    for (int i = 0; i < NUM_BOTONES; i++) {
      if (buzzerStates[i].currentPattern == PATTERN_SEISMIC) {
        sismoSigueActivo = true;
        break; // Si encontramos al menos un buzzer sísmico, no necesitamos buscar más.
      }
    }
    
    // Si recorrimos todos los buzzers y ninguno tiene el patrón sísmico,
    // significa que la alarma ha terminado y podemos poner la bandera en 0.
    if (!sismoSigueActivo) {
      SISMO = 0;
    }
  }
}

void manejarBotones() {
  unsigned long now = millis();
  for (int i = 0; i < NUM_BOTONES; i++) {
    bool estadoActual = digitalRead(PINES_BOTONES[i]) == LOW;
    if (estadoActual != estadoAnteriorBotones[i] && (now - ultimaLecturaBoton[i] >= debounceTime)) {
      if (estadoActual) {
        startBuzzerPattern(i, now, PATTERN_PANIC);
      }
      estadoAnteriorBotones[i] = estadoActual;
      ultimaLecturaBoton[i] = now;
    }
  }
}

void leerSensoresHumo() {
  PM1 = analogRead(MQ2_SENSOR_1);
  PM2 = analogRead(MQ2_SENSOR_2);
  unsigned long now = millis();

  // +++ CAMBIO 4: Lógica para detectar el cambio de estado de 0 a 1 en el humo +++
  bool smoke1_detected = (PM1 > SMOKE_THRESHOLD);
  if (smoke1_detected && INC1 == 0) { // Si se detecta humo y ANTES no había...
    INC1 = 1;                         // ...activa el estado interno...
    INC1_a_enviar = 1;                // ...marca para envío...
    startBuzzerPattern(2, now, PATTERN_SMOKE); // ...y suena la alarma.
  } else if (!smoke1_detected) {
    INC1 = 0; // Si no hay humo, resetea el estado interno.
  }

  bool smoke2_detected = (PM2 > SMOKE_THRESHOLD);
  if (smoke2_detected && INC2 == 0) {
    INC2 = 1;
    INC2_a_enviar = 1;
    startBuzzerPattern(3, now, PATTERN_SMOKE);
  } else if (!smoke2_detected) {
    INC2 = 0;
  }
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
      case 1: case 2: INFRAA = 1; buzzerIdx = 0; break;
      case 4: case 5: INFRAB = 1; buzzerIdx = 0; break;
      case 6: case 7: INFRAC = 1; buzzerIdx = 3; break;
      case 8: case 9: INFRAD = 1; buzzerIdx = 2; break;
    }
    if (buzzerIdx >= 0) startBuzzerPattern(buzzerIdx, millis(), PATTERN_INFRA);
  }

  if (sensors[currentSensor].purpose == SENSOR_ARRIVAL) {
    if (sensors[currentSensor].id == RESET_SENSOR_ID) {
      dist2 = 0;
    } else if (sensors[currentSensor].id == 13) {
      dist2 = 80;
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

void emitirEstado() {
  // Usar las variables _a_enviar para la salida serial +++
  snprintf(salidaBuffer, sizeof(salidaBuffer),
           "SEM1=%s;SEM2=%s;BUS1=%d;BUS2=%d;PM1=%d;PM2=%d;INC1=%d;INC2=%d;"
           "PANICO1=%d;PANICO2=%d;PANICO3=%d;PANICO4=%d;PANICO5=%d;"
           "SISMO=%d;INFRAA=%d;INFRAB=%d;INFRAC=%d;INFRAD=%d;DIST1=%d;DIST2=%d",
           SEM1.c_str(), SEM2.c_str(),
           BUS1, BUS2, PM1, PM2, INC1_a_enviar, INC2_a_enviar,
           PANICO_a_enviar[0], PANICO_a_enviar[1], PANICO_a_enviar[2], PANICO_a_enviar[3], PANICO_a_enviar[4],
           SISMO_a_enviar, INFRAA, INFRAB, INFRAC, INFRAD,
           dist1, dist2);
  Serial.println(salidaBuffer);

  // Resetear las banderas de envío después de mandarlas +++
  SISMO_a_enviar = 0;
  INC1_a_enviar = 0;
  INC2_a_enviar = 0;
  for (int i = 0; i < 5; i++) {
    PANICO_a_enviar[i] = 0;
  }
}