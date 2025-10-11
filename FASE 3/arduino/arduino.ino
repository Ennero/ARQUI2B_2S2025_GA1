#include <NewPing.h>
#include "TrafficLight.h"
<<<<<<< HEAD
#include "AlarmController.h"
#include "SerialCommander.h"

// ======================= CONFIGURACIÓN GENERAL =======================
// --- Botones y Buzzers ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = {48, 52, A15, A13, A11};
const int PINES_BUZZER[NUM_BOTONES] = {49, 53, A14, A12, A10};
const unsigned long DEBOUNCE_TIME = 50;

// --- Semáforos ---
const unsigned long GREEN_TIME = 8000;
const unsigned long YELLOW_TIME = 3000;

// --- Sensores Ultrasónicos ---
#define MAX_DISTANCE 50
#define PING_INTERVAL 33
#define RESET_SENSOR_ID 10
enum SensorPurpose
{
  SENSOR_PASS,
  SENSOR_ARRIVAL
};

// --- Rutas y Distancias ---
#define RESET1_PIN 4
const int ROUTE1_PINS[] = {5, 6, A3, A4, A5, A6, A7, A8};
const int ROUTE2_PINS[] = {17, 16, 15, 14, 2, 13};
const uint8_t ROUTE1_COUNT = sizeof(ROUTE1_PINS) / sizeof(ROUTE1_PINS[0]);
const uint8_t ROUTE2_COUNT = sizeof(ROUTE2_PINS) / sizeof(ROUTE2_PINS[0]);
#define DIST1_INCREMENT 40
#define DIST2_INCREMENT 20

// --- Sensores Adicionales ---
#define PIEZO_PIN 3
#define PIN_PIEZ A9
#define MQ2_SENSOR_1 A0
#define MQ2_SENSOR_2 A1
#define SMOKE_THRESHOLD 5000
const unsigned long SMOKE_INTERVAL = 1000;
const unsigned long PIEZO_INTERVAL = 500;

// --- Comunicación ---
const unsigned long EMIT_INTERVAL = 500;

// ======================= ESTADOS GLOBALES =======================
// Estos son los datos que tu sistema necesita compartir y enviar
String SEM1 = "ROJO", SEM2 = "ROJO";
int PM1 = 0, PM2 = 0, INC1 = 0, INC2 = 0, SISMO = 0;
int INFRAA = 0, INFRAB = 0, INFRAC = 0, INFRAD = 0;
int dist1 = 0, dist2 = 0;
int BUS1 = 0, BUS2 = 0; // Estas no se usaban pero las mantengo por si acaso
int PANICO[NUM_BOTONES] = {0};

// ======================= INSTANCIAS DE OBJETOS =======================
AlarmController alarmController(PINES_BUZZER, NUM_BOTONES);
SerialCommander serialCommander(alarmController, PANICO);
TrafficLight trafficA(12, 11, 10);
TrafficLight trafficB(9, 8, 7);

// --- Variables específicas de NewPing (se quedan aquí por su complejidad) ---
struct Sensor
{
  NewPing *sonar;
=======

// -------------------- CONFIGURACIÓN SENSORES ULTRASÓNICOS --------------------
#define MAX_DISTANCE 50
#define PING_INTERVAL 33

// ---- Pines y rutas ----  
#define RESET1_PIN 4  // reed que resetea (HIGH->LOW)
const int ROUTE1_PINS[] = { 5, 6, A3, A4, A5, A6, A7, A8 };
const int ROUTE2_PINS[] = { 17, 16, 15, 14, 2, 13 };
const uint8_t ROUTE1_COUNT = sizeof(ROUTE1_PINS) / sizeof(ROUTE1_PINS[0]);
const uint8_t ROUTE2_COUNT = sizeof(ROUTE2_PINS) / sizeof(ROUTE2_PINS[0]);
const int PIN_PIEZ = A9;

// Parámetros distancia
#define DIST1_INCREMENT 40  // cm por "paso" (40, 80, 120...)
#define DIST2_INCREMENT 20  // cm por "paso" (20, 40, 60...)

#define RESET_SENSOR_ID 10  // sensor ultrasónico que resetea dist2 al detectar llegada (<=3cm)

int dist1 = 0;
int dist2 = 0;

// --- PIEZO ---
#define PIEZO_PIN 3
unsigned long lastPiezoCheck = 0;
const unsigned long piezoInterval = 500;

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

enum SensorPurpose { SENSOR_PASS, SENSOR_ARRIVAL };

struct Sensor {
  NewPing* sonar;
>>>>>>> feature/ai
  SensorPurpose purpose;
  uint8_t id;
  uint8_t group;
};

NewPing sonar[] = {
<<<<<<< HEAD
    NewPing(22, 23, MAX_DISTANCE), NewPing(24, 25, MAX_DISTANCE),
    NewPing(26, 27, MAX_DISTANCE), NewPing(28, 29, MAX_DISTANCE),
    NewPing(30, 31, MAX_DISTANCE), NewPing(32, 33, MAX_DISTANCE),
    NewPing(34, 35, MAX_DISTANCE), NewPing(36, 37, MAX_DISTANCE),
    NewPing(38, 39, MAX_DISTANCE), NewPing(40, 41, MAX_DISTANCE),
    NewPing(42, 43, MAX_DISTANCE), NewPing(44, 45, MAX_DISTANCE),
    NewPing(46, 47, MAX_DISTANCE)};

Sensor sensors[] = {
    {&sonar[0], SENSOR_PASS, 1, 1},
    {&sonar[1], SENSOR_PASS, 2, 0},
    {&sonar[2], SENSOR_ARRIVAL, 3, 0},
    {&sonar[3], SENSOR_PASS, 4, 0},
    {&sonar[4], SENSOR_PASS, 5, 1},
    {&sonar[5], SENSOR_PASS, 6, 1},
    {&sonar[6], SENSOR_PASS, 7, 0},
    {&sonar[7], SENSOR_PASS, 8, 1},
    {&sonar[8], SENSOR_PASS, 9, 0},
    {&sonar[9], SENSOR_ARRIVAL, 10, 0},
    {&sonar[10], SENSOR_ARRIVAL, 11, 0},
    {&sonar[11], SENSOR_ARRIVAL, 12, 0},
    {&sonar[12], SENSOR_ARRIVAL, 13, 0}};
=======
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
>>>>>>> feature/ai

const uint8_t NUM_SENSORS = sizeof(sensors) / sizeof(sensors[0]);
unsigned long pingTimer[NUM_SENSORS];
uint16_t distances[NUM_SENSORS];
uint8_t currentSensor = 0;

<<<<<<< HEAD
// --- Variables para los semáforos ---
enum TrafficCycle
{
  GREEN_A,
  YELLOW_A,
  GREEN_B,
  YELLOW_B
};
TrafficCycle currentCycle = GREEN_A;

// ======================= SETUP =======================
void setup()
{
  Serial.begin(9600);

  verificarConfiguracionSensores();

  // Inicializar Módulos
  alarmController.begin();
  trafficA.begin();
  trafficB.begin();

  // Configurar Pines
  pinMode(PIEZO_PIN, INPUT);
  pinMode(PIN_PIEZ, INPUT_PULLUP);
  pinMode(RESET1_PIN, INPUT_PULLUP);
  pinMode(MQ2_SENSOR_1, INPUT);
  pinMode(MQ2_SENSOR_2, INPUT);

  for (int i = 0; i < NUM_BOTONES; i++)
  {
    pinMode(PINES_BOTONES[i], INPUT_PULLUP);
  }
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++)
  {
    pinMode(ROUTE1_PINS[i], INPUT_PULLUP);
  }
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++)
  {
    pinMode(ROUTE2_PINS[i], INPUT_PULLUP);
  }

  // Estado Inicial Semáforos
  trafficA.setState(TrafficLight::GREEN);
  trafficB.setState(TrafficLight::RED);

  // Configurar timers de NewPing
  unsigned long startTime = millis() + 75;
  for (uint8_t i = 0; i < NUM_SENSORS; i++)
  {
    pingTimer[i] = startTime + i * PING_INTERVAL;
  }
}

// ======================= LOOP PRINCIPAL =======================
void loop()
{
  // --- Módulos de Control y Lectura ---
  serialCommander.checkAndProcessCommands();
  alarmController.controlarAlarms(PANICO);

  updateTrafficLights(millis());
  handleSonarSensors(millis());

  handleBotones();
  handleSensoresHumo();
  handleSismo();
  handleReeds();
  handleResetReed();

  // --- Comunicación de Salida ---
  emitirEstado();
}

// ======================= FUNCIONES DE MANEJO (Handlers) =======================

void handleBotones()
{
  static unsigned long lastRead[NUM_BOTONES] = {0};
  static bool prevState[NUM_BOTONES] = {false};
  unsigned long now = millis();

  for (int i = 0; i < NUM_BOTONES; i++)
  {
    if (now - lastRead[i] > DEBOUNCE_TIME)
    {
      bool currentState = (digitalRead(PINES_BOTONES[i]) == LOW);
      if (currentState && !prevState[i])
      {
        alarmController.activarAlarm(i, PANICO_BTN, PANICO);
      }
      // El apagado del pánico lo maneja el controlador de alarm
      prevState[i] = currentState;
      lastRead[i] = now;
    }
  }
}

void handleSensoresHumo()
{
  static unsigned long lastCheck = 0;
  if (millis() - lastCheck < SMOKE_INTERVAL)
    return;

  PM1 = analogRead(MQ2_SENSOR_1);
  PM2 = analogRead(MQ2_SENSOR_2);
  INC1 = (PM1 > SMOKE_THRESHOLD);
  INC2 = (PM2 > SMOKE_THRESHOLD);

  if (INC1)
    alarmController.activarAlarm(2, INCENDIO);
  if (INC2)
    alarmController.activarAlarm(3, INCENDIO);
  lastCheck = millis();
}

void handleSismo()
{
  static unsigned long lastCheck = 0;
  if (millis() - lastCheck < PIEZO_INTERVAL)
    return;

  SISMO = (digitalRead(PIEZO_PIN) == HIGH);
  if (digitalRead(PIN_PIEZ) == LOW && SISMO)
  { // Activa solo si ambos sensores lo detectan
    for (int i = 0; i < NUM_BOTONES; i++)
    {
      alarmController.activarAlarm(i, SISMO_ALARM);
    }
  }
  lastCheck = millis();
}

void handleReeds()
{
  // Variables estáticas para recordar el estado entre llamadas a la función
  static int lastStateRoute1[ROUTE1_COUNT];
  static int lastStateRoute2[ROUTE2_COUNT];
  static bool initialized = false;

  // Este bloque se ejecuta solo una vez para inicializar los estados
  if (!initialized)
  {
    for (uint8_t i = 0; i < ROUTE1_COUNT; i++)
      lastStateRoute1[i] = HIGH;
    for (uint8_t i = 0; i < ROUTE2_COUNT; i++)
      lastStateRoute2[i] = HIGH;
    initialized = true;
  }

  // --- Ruta 1 ---
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++)
  {
    int lectura = digitalRead(ROUTE1_PINS[i]);
    // Detecta el flanco de bajada (cuando el pin pasa de HIGH a LOW)
    if (lastStateRoute1[i] == HIGH && lectura == LOW)
    {
      dist1 = (i + 1) * DIST1_INCREMENT;
    }
    // Guarda el estado actual para la próxima comprobación
    lastStateRoute1[i] = lectura;
  }

  // --- Ruta 2 ---
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++)
  {
    int lectura = digitalRead(ROUTE2_PINS[i]);
    // Detecta el flanco de bajada
    if (lastStateRoute2[i] == HIGH && lectura == LOW)
    {
      int newDist = (i + 1) * DIST2_INCREMENT;
      // Lógica especial para los últimos sensores de la ruta 2
      if (i > 3)
      {
        newDist += 20;
      }
      dist2 = newDist;
    }
    // Guarda el estado actual para la próxima comprobación
=======
// --- Semáforos ---
TrafficLight trafficA(12, 11, 10);
TrafficLight trafficB(9, 8, 7);
enum TrafficCycle { GREEN_A, YELLOW_A, GREEN_B, YELLOW_B };
TrafficCycle currentCycle = GREEN_A;
unsigned long stateStartTime = 0;
const unsigned long greenTime = 8000;
const unsigned long yellowTime = 3000;

// --- Botones / buzzers (sin cambios) ---
const uint8_t NUM_BOTONES = 5;
const int PINES_BOTONES[NUM_BOTONES] = { 48, 52, A15, A13, A11 };
const int PINES_BUZZER[NUM_BOTONES] = { 49, 53, A14, A12, A10 };
bool estadoAnteriorBotones[NUM_BOTONES] = { false };
unsigned long ultimaLecturaBoton[NUM_BOTONES] = { 0 };
const unsigned long debounceTime = 50;
unsigned long tiempoInicioBuzzer[NUM_BOTONES] = { 0 };
const unsigned long duracionBuzzer = 2000;

// --- MQ2 ---
#define MQ2_SENSOR_1 A0
#define MQ2_SENSOR_2 A1
#define SMOKE_THRESHOLD 260

unsigned long lastSmokeCheck = 0;
const unsigned long smokeInterval = 1000;
int INFRAA = 0, INFRAB = 0, INFRAC = 0, INFRAD = 0;

// --- Emisión estado ---
unsigned long lastEmitTime = 0;
const unsigned long emitInterval = 500;
char salidaBuffer[320];

// --- Arrays de estado (solo flanco, sin debounce) ---
int lastStateRoute1[ROUTE1_COUNT];
int lastStateRoute2[ROUTE2_COUNT];

// --- Reset reed ---
int lastStateReset = HIGH;

// --- Para detectar el caso especial en ROUTE2 (índices) ---
int lastTriggeredIndexRoute2 = -1;  // -1 = ninguno todavía

void leerPiezoelectrico(bool makeItSound = false) {
  int piezoState = digitalRead(PIEZO_PIN);
  SISMO = (piezoState == HIGH) ? 1 : 0;
  if (SISMO == 1 || makeItSound) {
    unsigned long now = millis();
    for (int i = 0; i < NUM_BOTONES; i++) sonarBuzzer(i, now);
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

  pinMode(PIEZO_PIN, INPUT);

  // RESET reed
  pinMode(RESET1_PIN, INPUT_PULLUP);
  lastStateReset = digitalRead(RESET1_PIN);

  pinMode(PIN_PIEZ, INPUT_PULLUP);

  // reeds rutas (solo lectura inicial)
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++) {
    pinMode(ROUTE1_PINS[i], INPUT_PULLUP);
    lastStateRoute1[i] = digitalRead(ROUTE1_PINS[i]);
  }
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++) {
    pinMode(ROUTE2_PINS[i], INPUT_PULLUP);
    lastStateRoute2[i] = digitalRead(ROUTE2_PINS[i]);
  }
}

void loop() {
  unsigned long now = millis();

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
  controlarBuzzer();

  if (now - lastSmokeCheck >= smokeInterval) {
    leerSensoresHumo();
    lastSmokeCheck = now;
  }
  if (now - lastPiezoCheck >= piezoInterval) {
    leerPiezoelectrico();
    lastPiezoCheck = now;
  }else if(digitalRead(PIN_PIEZ) == LOW){
    leerPiezoelectrico(true);
    lastPiezoCheck = now;
  }


  // emitir estado periódicamente (único Serial.println)
  if (now - lastEmitTime >= emitInterval) {
    emitirEstado();
    lastEmitTime = now;
  }
}

// ---------- Manejo de reads SIN debounce (solo flanco HIGH->LOW) ----------
void manejarReeds() {
  // Ruta 1: si activa el reed en índice i -> dist1 = (i+1) * DIST1_INCREMENT
  for (uint8_t i = 0; i < ROUTE1_COUNT; i++) {
    int pin = ROUTE1_PINS[i];
    int lectura = digitalRead(pin);
    if (lastStateRoute1[i] == HIGH && lectura == LOW) {
      int newDist = (i + 1) * DIST1_INCREMENT;
      if (newDist != dist1) {
        dist1 = newDist;
      }
      // No debounce, actualización inmediata del estado interno (emitido periódicamente)
      lastTriggeredIndexRoute2 = lastTriggeredIndexRoute2; // sin efecto aquí, solo para mantener variable
    }
    lastStateRoute1[i] = lectura;
  }

  // Ruta 2: lógica con caso especial 16(index 1) -> 14(index 2)
  for (uint8_t i = 0; i < ROUTE2_COUNT; i++) {
    int pin = ROUTE2_PINS[i];
    int lectura = digitalRead(pin);
    if (lastStateRoute2[i] == HIGH && lectura == LOW) {
      int normalNewDist = (i + 1) * DIST2_INCREMENT;
      int newDist = normalNewDist;

      // Caso especial: si el anterior índice activado fue 1 (pin 16) y ahora es 2 (pin 14)
      if (lastTriggeredIndexRoute2 == 2 && i == 3) {
        newDist = normalNewDist + 20;  // aplica el salto extra sólo en ese caso
      }

      if (newDist != dist2) {
        dist2 = newDist;
      }

      // actualizar índice último activado en ROUTE2
      lastTriggeredIndexRoute2 = i;
    }
>>>>>>> feature/ai
    lastStateRoute2[i] = lectura;
  }
}

<<<<<<< HEAD
void resetReedStates()
{
  // Esta función parece no usarse, puedes dejarla o eliminarla.
  static int *lastStateRoute1 = nullptr;
  static int *lastStateRoute2 = nullptr;
}

void handleResetReed()
{
  static int lastStateReset = HIGH;
  int lectura = digitalRead(RESET1_PIN);

  // Detecta el flanco de bajada (cuando el pin pasa de HIGH a LOW)
  if (lastStateReset == HIGH && lectura == LOW)
  {
    // Resetea las distancias y los indicadores de infracción
    dist1 = 0;
    dist2 = 0;
    INFRAA = 0;
    INFRAB = 0;
    INFRAC = 0;
    INFRAD = 0;
  }
  // Guarda el estado actual para la próxima comprobación
  lastStateReset = lectura;
}




void handleSonarSensors(unsigned long now)
{
  for (uint8_t i = 0; i < NUM_SENSORS; i++)
  {
    if (now >= pingTimer[i])
    {
      pingTimer[i] += PING_INTERVAL * NUM_SENSORS;
      if (sensors[currentSensor].sonar)
        sensors[currentSensor].sonar->timer_stop();
      currentSensor = i;
      distances[currentSensor] = 0;
      if (sensors[currentSensor].sonar)
        sensors[currentSensor].sonar->ping_timer(echoCheck);
=======
// manejar RESET1_PIN como reed (HIGH->LOW), resetea ambas distancias
void manejarResetReed() {
  int lectura = digitalRead(RESET1_PIN);
  if (lastStateReset == HIGH && lectura == LOW) {
    // reset manual por reed: resetea distancias
    dist1 = 0;
    dist2 = 0;
    lastTriggeredIndexRoute2 = -1;  // limpiar historial de ruta2
  }
  lastStateReset = lectura;
}

// ---------- resto de funciones (mantengo tu base; NO imprimen salvo emitirEstado) ----------
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
>>>>>>> feature/ai
    }
  }
}

<<<<<<< HEAD
// ======================= Lógica Central =======================
// Estas funciones son llamadas por los handlers o el loop

void echoCheck()
{
  // Verificación de seguridad
  if (currentSensor >= NUM_SENSORS)
    return;

  if (!sensors[currentSensor].sonar || !sensors[currentSensor].sonar->check_timer())
    return;
=======
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

  unsigned long now = millis();
  // activar buzzer correspondiente si hay humo
  if (INC1) sonarBuzzer(2, now); // buzzer más cercano al sensor 1
  if (INC2) sonarBuzzer(3, now); // buzzer más cercano al sensor 2
}

// echoCheck: recibe resultado del sonar; aquí reaccionamos sin imprimir
void echoCheck() {
  if (!sensors[currentSensor].sonar->check_timer()) return;
>>>>>>> feature/ai

  distances[currentSensor] = sensors[currentSensor].sonar->ping_result / US_ROUNDTRIP_CM;
  uint16_t dist = distances[currentSensor];

<<<<<<< HEAD
  if (sensors[currentSensor].purpose == SENSOR_PASS)
  {
    int *infraVar = nullptr;
    int buzzerIdx = -1;

    // Mapeo correcto de sensores PASS a variables de infracción
    // Verifica que el sensor SÍ sea SENSOR_PASS antes de asignar
    uint8_t id = sensors[currentSensor].id;

    if (id == 1 || id == 2)
    {
      infraVar = &INFRAA;
      buzzerIdx = 0;
    }
    else if (id == 4 || id == 5) // Saltamos id=3 porque es ARRIVAL
    {
      infraVar = &INFRAB;
      buzzerIdx = 0;
    }
    else if (id == 6 || id == 7)
    {
      infraVar = &INFRAC;
      buzzerIdx = 3;
    }
    else if (id == 8 || id == 9)
    {
      infraVar = &INFRAD;
      buzzerIdx = 2;
    }

    if (infraVar)
    {
      // Mantener el estado de infracción
      if (dist > 0 && dist <= 3)
      {
        *infraVar = 1;

        // Verificar si hay luz roja
        bool isRedLight = (sensors[currentSensor].group == 0 &&
                           (currentCycle == GREEN_B || currentCycle == YELLOW_B)) ||
                          (sensors[currentSensor].group == 1 &&
                           (currentCycle == GREEN_A || currentCycle == YELLOW_A));

        if (isRedLight && buzzerIdx != -1)
        {
          alarmController.activarAlarm(buzzerIdx, INFRACCION);
        }
      }
      else
      {
        *infraVar = 0;
      }
    }
  }
  else if (sensors[currentSensor].purpose == SENSOR_ARRIVAL)
  {
    if (dist > 0 && dist <= 3)
    {
      uint8_t id = sensors[currentSensor].id;
      if (id == RESET_SENSOR_ID)
        dist2 = 0;
      else if (id == 13)
        dist2 = 80;
      // Agrega casos para otros sensores ARRIVAL (ids: 3, 11, 12)
      else if (id == 3)
        dist2 = 0; // O el valor que corresponda
      else if (id == 11)
        dist2 = 0; // O el valor que corresponda
      else if (id == 12)
        dist2 = 0; // O el valor que corresponda
    }
  }
}

void verificarConfiguracionSensores()
{
  Serial.println(F("=== Verificando Sensores ==="));

  for (uint8_t i = 0; i < NUM_SENSORS; i++)
  {
    Serial.print(F("Sensor "));
    Serial.print(i);
    Serial.print(F(" - ID: "));
    Serial.print(sensors[i].id);
    Serial.print(F(", Grupo: "));
    Serial.print(sensors[i].group);
    Serial.print(F(", Tipo: "));
    Serial.println(sensors[i].purpose == SENSOR_PASS ? F("PASS") : F("ARRIVAL"));
  }

  Serial.println(F("=== Verificación Completa ==="));
}

void updateTrafficLights(unsigned long now)
{
  static unsigned long stateStartTime = 0;
  static bool firstRun = true;

  if (firstRun)
  {
    stateStartTime = now;
    firstRun = false;
  }

  unsigned long timeInState = now - stateStartTime;

  switch (currentCycle)
  {
  case GREEN_A:
    if (timeInState >= GREEN_TIME)
    {
      currentCycle = YELLOW_A;
      trafficA.setState(TrafficLight::YELLOW);
      stateStartTime = now;
    }
    break;
  case YELLOW_A:
    if (timeInState >= YELLOW_TIME)
    {
      currentCycle = GREEN_B;
      trafficA.setState(TrafficLight::RED);
      trafficB.setState(TrafficLight::GREEN);
      stateStartTime = now;
    }
    break;
  case GREEN_B:
    if (timeInState >= GREEN_TIME)
    {
      currentCycle = YELLOW_B;
      trafficB.setState(TrafficLight::YELLOW);
      stateStartTime = now;
    }
    break;
  case YELLOW_B:
    if (timeInState >= YELLOW_TIME)
    {
      currentCycle = GREEN_A;
      trafficA.setState(TrafficLight::GREEN);
      trafficB.setState(TrafficLight::RED);
      stateStartTime = now;
    }
    break;
  }
  // Actualizar estados de SEM1 y SEM2
  if (currentCycle == GREEN_A)
  {
    SEM1 = "VERDE";
    SEM2 = "ROJO";
  }
  else if (currentCycle == YELLOW_A)
  {
    SEM1 = "AMARILLO";
    SEM2 = "ROJO";
  }
  else if (currentCycle == GREEN_B)
  {
    SEM1 = "ROJO";
    SEM2 = "VERDE";
  }
  else if (currentCycle == YELLOW_B)
  {
    SEM1 = "ROJO";
    SEM2 = "AMARILLO";
  }
}

void emitirEstado()
{
  static unsigned long lastEmitTime = 0;
  if (millis() - lastEmitTime < EMIT_INTERVAL)
    return;

  char salidaBuffer[320];
=======
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
    if (buzzerIdx >= 0) sonarBuzzer(buzzerIdx, millis());
  }

  // Si el sensor es el RESET_SENSOR_ID y lee cerca (<=3 cm) -> resetea dist2 inmediatamente
  if (sensors[currentSensor].purpose == SENSOR_ARRIVAL) {
    if (sensors[currentSensor].id == RESET_SENSOR_ID) {
      dist2 = 0;
      lastTriggeredIndexRoute2 = -1;
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

// ÚNICO Serial.println: emitir todo el estado
void emitirEstado() {
>>>>>>> feature/ai
  snprintf(salidaBuffer, sizeof(salidaBuffer),
           "SEM1=%s;SEM2=%s;BUS1=%d;BUS2=%d;PM1=%d;PM2=%d;INC1=%d;INC2=%d;"
           "PANICO1=%d;PANICO2=%d;PANICO3=%d;PANICO4=%d;PANICO5=%d;"
           "SISMO=%d;INFRAA=%d;INFRAB=%d;INFRAC=%d;INFRAD=%d;DIST1=%d;DIST2=%d",
           SEM1.c_str(), SEM2.c_str(),
           BUS1, BUS2, PM1, PM2, INC1, INC2,
           PANICO[0], PANICO[1], PANICO[2], PANICO[3], PANICO[4],
           SISMO, INFRAA, INFRAB, INFRAC, INFRAD,
           dist1, dist2);
  Serial.println(salidaBuffer);
<<<<<<< HEAD
  lastEmitTime = millis();
}
=======
}
>>>>>>> feature/ai
