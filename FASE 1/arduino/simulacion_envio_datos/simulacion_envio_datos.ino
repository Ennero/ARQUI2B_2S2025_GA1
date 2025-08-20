// Arduino - simulador serial actualizado (con INFRAA..INFRAD)
// Envía: SEM1, SEM2, BUS1, BUS2, PM1, PM2, INC1, INC2, PANICO1..PANICO5, SISMO, INFRAA, INFRAB, INFRAC, INFRAD
// Distancias: 0..120 (ciclan 0->MAX->0)
// PM simulados: valores en ppm, cambian gradualmente (100..3000)

const unsigned long INTERVAL_MS = 300; // envía cada 300 ms
const int MAX_BUS_CM = 120; // 120 cm (maqueta)
const unsigned long INFRA_DURATION_MS = 3000; // duración simulated infracción (3s)

unsigned long lastMillis = 0;

// buses
int distBus1 = 0;
int distBus2 = 40;
const int step1 = 2;
const int step2 = 1;

// PM (partículas) en ppm
float pm1 = 150.0;
float pm2 = 150.0;

// semáforos
static unsigned long lastSemChange = 0;
static int semPhase = 0;

// simulación de infracciones (A, B, C, D)
bool infraA_active = false;
unsigned long infraA_since = 0;
bool infraB_active = false;
unsigned long infraB_since = 0;
bool infraC_active = false;
unsigned long infraC_since = 0;
bool infraD_active = false;
unsigned long infraD_since = 0;

void setup() {
  Serial.begin(9600);
  randomSeed(analogRead(A0));
  // iniciar PM con valores distintos para variedad
  pm1 = random(120, 260);
  pm2 = random(120, 260);
}

void loop() {
  if (millis() - lastMillis < INTERVAL_MS) return;
  lastMillis = millis();

  // --- SEMAFOROS (solo SEM1 y SEM2 para dashboard) ---
  if (millis() - lastSemChange > 3000) {
    lastSemChange = millis();
    semPhase = (semPhase + 1) % 3;
  }
  const char* estados[3] = {"ROJO", "AMARILLO", "VERDE"};
  String estadoSem1 = String(estados[semPhase]);
  String estadoSem2 = String(estados[(semPhase + 2) % 3]);

  // --- BUSES: incrementan 0->MAX, al llegar a MAX vuelven a 0 (ciclo)
  distBus1 += step1;
  if (distBus1 >= MAX_BUS_CM) {
    distBus1 = MAX_BUS_CM;
    distBus1 = 0;
  }

  distBus2 += step2;
  if (distBus2 >= MAX_BUS_CM) {
    distBus2 = MAX_BUS_CM;
    distBus2 = 0;
  }

  // --- PM: actualizar gradualmente ---
  pm1 += random(-15, 16); // [-15,15]
  pm2 += random(-15, 16);

  // mantener en rango realista
  if (pm1 < 100) pm1 = 100;
  if (pm1 > 3000) pm1 = 3000;
  if (pm2 < 100) pm2 = 100;
  if (pm2 > 3000) pm2 = 3000;

  // --- INCENDIO derivado (para compatibilidad): 1 si pm>1000 ---
  int incendio1 = (pm1 > 1000.0) ? 1 : 0;
  int incendio2 = (pm2 > 1000.0) ? 1 : 0;

  // --- PANICO: rara activación puntual ---
  int pan[5] = {0,0,0,0,0};
  if (random(0, 1000) > 990) {
    int idx = random(0,5);
    pan[idx] = 1;
  }

  // --- SISMO (muy raro) ---
  int sismo = (random(0, 2000) > 1995) ? 1 : 0;

  // --- SIMULAR INFRAECCIONES (activación aleatoria corta) ---
  if (!infraA_active && random(0, 2000) > 1995) {
    infraA_active = true;
    infraA_since = millis();
  }
  if (infraA_active && (millis() - infraA_since > INFRA_DURATION_MS)) {
    infraA_active = false;
  }

  if (!infraB_active && random(0, 2000) > 1995) {
    infraB_active = true;
    infraB_since = millis();
  }
  if (infraB_active && (millis() - infraB_since > INFRA_DURATION_MS)) {
    infraB_active = false;
  }

  if (!infraC_active && random(0, 2000) > 1995) {
    infraC_active = true;
    infraC_since = millis();
  }
  if (infraC_active && (millis() - infraC_since > INFRA_DURATION_MS)) {
    infraC_active = false;
  }

  if (!infraD_active && random(0, 2000) > 1995) {
    infraD_active = true;
    infraD_since = millis();
  }
  if (infraD_active && (millis() - infraD_since > INFRA_DURATION_MS)) {
    infraD_active = false;
  }

  int infraA_val = infraA_active ? 1 : 0;
  int infraB_val = infraB_active ? 1 : 0;
  int infraC_val = infraC_active ? 1 : 0;
  int infraD_val = infraD_active ? 1 : 0;

  // --- ENVIO SERIAL (una línea, campos separados por ';') ---
  Serial.print("SEM1="); Serial.print(estadoSem1);
  Serial.print(";SEM2="); Serial.print(estadoSem2);

  Serial.print(";BUS1="); Serial.print(distBus1);
  Serial.print(";BUS2="); Serial.print(distBus2);

  Serial.print(";PM1="); Serial.print((int)pm1);
  Serial.print(";PM2="); Serial.print((int)pm2);

  // También enviamos INC1/INC2 derivadas por compatibilidad
  Serial.print(";INC1="); Serial.print(incendio1);
  Serial.print(";INC2="); Serial.print(incendio2);

  Serial.print(";PANICO1="); Serial.print(pan[0]);
  Serial.print(";PANICO2="); Serial.print(pan[1]);
  Serial.print(";PANICO3="); Serial.print(pan[2]);
  Serial.print(";PANICO4="); Serial.print(pan[3]);
  Serial.print(";PANICO5="); Serial.print(pan[4]);

  Serial.print(";SISMO="); Serial.print(sismo);

  // NUEVOS CAMPOS: INFRAA..INFRAD
  Serial.print(";INFRAA="); Serial.print(infraA_val);
  Serial.print(";INFRAB="); Serial.print(infraB_val);
  Serial.print(";INFRAC="); Serial.print(infraC_val);
  Serial.print(";INFRAD="); Serial.print(infraD_val);

  Serial.println();

  // DEBUG opcional
  if (pan[0]||pan[1]||pan[2]||pan[3]||pan[4]) {
    Serial.print("# PANICO: ");
    for (int i=0;i<5;i++) if (pan[i]) { Serial.print(i+1); Serial.print(" "); }
    Serial.println();
  }
  if (infraA_val || infraB_val || infraC_val || infraD_val) {
    Serial.print("# INFRA: A="); Serial.print(infraA_val);
    Serial.print(" B="); Serial.print(infraB_val);
    Serial.print(" C="); Serial.print(infraC_val);
    Serial.print(" D="); Serial.println(infraD_val);
  }
}
