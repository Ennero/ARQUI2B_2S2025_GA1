// Arduino Simulator for Serial Data
// This code simulates various sensors and events, sending data in key=value format
// to test Processing's flexible data reception. Data is sent in individual lines
// or small groups, not all at once, to verify partial message handling.
// Alerts (PANICO, SISMO, INFRA) are only sent when activated (=1), and Processing
// handles timeout after 5 seconds without needing =0.

// Timing constants
const unsigned long INTERVAL_MS = 300;  // Main loop interval for updates (ms)
const int MAX_BUS1_CM = 360;            // Max distance for Transmetro bus (cm)
const int MAX_BUS2_CM = 200;            // Max distance for Transurbano bus (cm)
const unsigned long INFRA_DURATION_MS = 3000;  // Duration for simulated infractions (ms)

// Global variables for simulation state
unsigned long lastMillis = 0;           // Timestamp for last update

// Bus simulation variables
int distBus1 = 0;                       // Current distance for Bus 1 (Transmetro)
int distBus2 = 40;                      // Current distance for Bus 2 (Transurbano)
const int step = 20;                    // Increment step for bus distances (cm)

// Particle levels (ppm) for air quality sensors
float pm1 = 150.0;                      // PM level for sensor 1
float pm2 = 150.0;                      // PM level for sensor 2

// Traffic light simulation
static unsigned long lastSemChange = 0;  // Timestamp for last traffic light change
static int semPhase = 0;                 // Current phase for traffic lights (0-2)

// Infraction simulation for intersections A-D
bool infraA_active = false;             // Active state for infraction A
unsigned long infraA_since = 0;         // Start time for infraction A
bool infraB_active = false;             // Active state for infraction B
unsigned long infraB_since = 0;         // Start time for infraction B
bool infraC_active = false;             // Active state for infraction C
unsigned long infraC_since = 0;         // Start time for infraction C
bool infraD_active = false;             // Active state for infraction D
unsigned long infraD_since = 0;         // Start time for infraction D

void setup() {
  Serial.begin(9600);                   // Initialize serial communication at 9600 baud
  randomSeed(analogRead(A0));           // Seed random number generator using analog pin
  // Initialize PM levels with random starting values for variety
  pm1 = random(120, 260);
  pm2 = random(120, 260);
}

void loop() {
  // Check if it's time for the next update
  if (millis() - lastMillis < INTERVAL_MS) return;
  lastMillis = millis();

  // --- TRAFFIC LIGHTS SIMULATION ---
  // Update traffic light phase every 3 seconds
  if (millis() - lastSemChange > 3000) {
    lastSemChange = millis();
    semPhase = (semPhase + 1) % 3;
    // Define states: ROJO, AMARILLO, VERDE
    const char* estados[3] = {"ROJO", "AMARILLO", "VERDE"};
    String estadoSem1 = String(estados[semPhase]);
    String estadoSem2 = String(estados[(semPhase + 2) % 3]);
    // Send traffic light states on separate lines
    Serial.println("SEM1=" + estadoSem1);
    Serial.println("SEM2=" + estadoSem2);
  }

  // --- BUS DISTANCE SIMULATION ---
  // Increment bus distances and reset at max (cycle simulation)
  distBus1 += step;
  if (distBus1 >= MAX_BUS1_CM) {
    distBus1 = 0;
  }
  distBus2 += step;
  if (distBus2 >= MAX_BUS2_CM) {
    distBus2 = 0;
  }
  // Send bus distances on separate lines
  Serial.println("BUS1=" + String(distBus1));
  Serial.println("BUS2=" + String(distBus2));

  // --- PARTICLE LEVEL (PM) SIMULATION ---
  // Gradually update PM levels with random variation
  pm1 += random(-15, 16);  // Change in range [-15, 15]
  pm2 += random(-15, 16);
  // Clamp values to realistic range
  if (pm1 < 100) pm1 = 100;
  if (pm1 > 3000) pm1 = 3000;
  if (pm2 < 100) pm2 = 100;
  if (pm2 > 3000) pm2 = 3000;
  // Send PM levels on separate lines
  Serial.println("PM1=" + String((int)pm1));
  Serial.println("PM2=" + String((int)pm2));

  // --- INCENDIO (FIRE) DERIVED FROM PM ---
  // Derive INC1/INC2 for compatibility: 1 if PM > 1000
  int incendio1 = (pm1 > 1000.0) ? 1 : 0;
  int incendio2 = (pm2 > 1000.0) ? 1 : 0;
  // Send INC only if active (=1), to test timeout in Processing
  if (incendio1) Serial.println("INC1=1");
  if (incendio2) Serial.println("INC2=1");

  // --- PANICO (PANIC) BUTTON SIMULATION ---
  // Rarely activate a random panic button
  int pan[5] = {0, 0, 0, 0, 0};
  if (random(0, 1000) > 990) {
    int idx = random(0, 5);
    pan[idx] = 1;
    // Send only when activated (=1)
    Serial.println("PANICO" + String(idx + 1) + "=1");
  }

  // --- SISMO (EARTHQUAKE) SIMULATION ---
  // Very rare activation
  int sismo_val = (random(0, 2000) > 1995) ? 1 : 0;
  if (sismo_val) {
    // Send only when activated (=1)
    Serial.println("SISMO=1");
  }

  // --- INFRACTIONS SIMULATION FOR INTERSECTIONS A-D ---
  // Randomly activate short-duration infractions
  if (!infraA_active && random(0, 2000) > 1995) {
    infraA_active = true;
    infraA_since = millis();
    // Send activation
    Serial.println("INFRAA=1");
  }
  if (infraA_active && (millis() - infraA_since > INFRA_DURATION_MS)) {
    infraA_active = false;
    // Do not send =0; let Processing timeout
  }

  if (!infraB_active && random(0, 2000) > 1995) {
    infraB_active = true;
    infraB_since = millis();
    // Send activation
    Serial.println("INFRAB=1");
  }
  if (infraB_active && (millis() - infraB_since > INFRA_DURATION_MS)) {
    infraB_active = false;
    // Do not send =0
  }

  if (!infraC_active && random(0, 2000) > 1995) {
    infraC_active = true;
    infraC_since = millis();
    // Send activation
    Serial.println("INFRAC=1");
  }
  if (infraC_active && (millis() - infraC_since > INFRA_DURATION_MS)) {
    infraC_active = false;
    // Do not send =0
  }

  if (!infraD_active && random(0, 2000) > 1995) {
    infraD_active = true;
    infraD_since = millis();
    // Send activation
    Serial.println("INFRAD=1");
  }
  if (infraD_active && (millis() - infraD_since > INFRA_DURATION_MS)) {
    infraD_active = false;
    // Do not send =0
  }

  // Optional debug output for active alerts (commented out for clean serial)
  // if (pan[0]||pan[1]||pan[2]||pan[3]||pan[4]) {
  //   Serial.print("# PANICO: ");
  //   for (int i=0;i<5;i++) if (pan[i]) { Serial.print(i+1); Serial.print(" "); }
  //   Serial.println();
  // }
  // if (infraA_active || infraB_active || infraC_active || infraD_active) {
  //   Serial.print("# INFRA: A="); Serial.print(infraA_active ? 1 : 0);
  //   Serial.print(" B="); Serial.print(infraB_active ? 1 : 0);
  //   Serial.print(" C="); Serial.print(infraC_active ? 1 : 0);
  //   Serial.print(" D="); Serial.println(infraD_active ? 1 : 0);
  // }
}