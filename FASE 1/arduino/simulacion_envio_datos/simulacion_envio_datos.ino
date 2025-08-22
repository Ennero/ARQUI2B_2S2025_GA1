// Arduino - simulador serial FLEXIBLE
// Envía datos de forma independiente según diferentes intervalos y eventos
// Cada tipo de dato puede enviarse por separado sin esperar a los demás

const int MAX_BUS_CM = 120;
const unsigned long INFRA_DURATION_MS = 3000; // duración de infracciones simuladas

// INTERVALOS INDEPENDIENTES para diferentes tipos de datos
const unsigned long INTERVAL_SEMAFOROS = 4000;  // semáforos cada 4s
const unsigned long INTERVAL_BUSES = 200;       // buses cada 200ms (más frecuente)
const unsigned long INTERVAL_PARTICULAS = 1000; // partículas cada 1s
const unsigned long INTERVAL_EVENTOS = 500;     // check eventos cada 500ms

// Timestamps para controlar envíos independientes
unsigned long lastSemaforosMillis = 0;
unsigned long lastBusesMillis = 0;
unsigned long lastParticulasMillis = 0;
unsigned long lastEventosMillis = 0;

// BUSES - estado persistente
int distBus1 = 0;
int distBus2 = 40;
const int stepBus1 = 2;
const int stepBus2 = 1;
bool bus1_cambio = false;
bool bus2_cambio = false;

// PARTICULAS - estado persistente
float pm1 = 150.0;
float pm2 = 150.0;
bool pm1_cambio = false;
bool pm2_cambio = false;

// SEMAFOROS - estado persistente
int semPhase = 0;
unsigned long lastSemChange = 0;
bool sem_cambio = false;

// INFRACCIONES - estado persistente
bool infraA_active = false;
unsigned long infraA_since = 0;
bool infraB_active = false;
unsigned long infraB_since = 0;
bool infraC_active = false;
unsigned long infraC_since = 0;
bool infraD_active = false;
unsigned long infraD_since = 0;

// FLAGS para eventos puntuales
bool enviar_panico = false;
int panico_id = -1;
bool enviar_sismo = false;
bool enviar_infra = false;
int infra_mask = 0; // bits para A,B,C,D

void setup() {
  Serial.begin(9600);
  randomSeed(analogRead(A0));
  
  // Inicializar PM con valores distintos
  pm1 = random(120, 260);
  pm2 = random(120, 260);
  
  Serial.println("# Sistema iniciado - Envio flexible activado");
}

void loop() {
  unsigned long currentMillis = millis();
  
  // ACTUALIZAR SEMAFOROS (independiente)
  if (currentMillis - lastSemaforosMillis >= INTERVAL_SEMAFOROS) {
    lastSemaforosMillis = currentMillis;
    actualizarSemaforos();
  }
  
  // ACTUALIZAR BUSES (independiente, más frecuente)
  if (currentMillis - lastBusesMillis >= INTERVAL_BUSES) {
    lastBusesMillis = currentMillis;
    actualizarBuses();
  }
  
  // ACTUALIZAR PARTICULAS (independiente)
  if (currentMillis - lastParticulasMillis >= INTERVAL_PARTICULAS) {
    lastParticulasMillis = currentMillis;
    actualizarParticulas();
  }
  
  // CHEQUEAR EVENTOS (pánico, sismo, infracciones)
  if (currentMillis - lastEventosMillis >= INTERVAL_EVENTOS) {
    lastEventosMillis = currentMillis;
    chequearEventos();
  }
  
  // ENVIAR DATOS QUE HAN CAMBIADO
  enviarActualizaciones();
}

void actualizarSemaforos() {
  if (millis() - lastSemChange > 3000) {
    lastSemChange = millis();
    semPhase = (semPhase + 1) % 3;
    sem_cambio = true;
    Serial.println("# Cambio de semaforo detectado");
  }
}

void actualizarBuses() {
  // Bus 1
  int prevDist1 = distBus1;
  distBus1 += stepBus1;
  if (distBus1 >= MAX_BUS_CM) {
    distBus1 = 0; // reset al completar ciclo
  }
  if (distBus1 != prevDist1) {
    bus1_cambio = true;
  }
  
  // Bus 2
  int prevDist2 = distBus2;
  distBus2 += stepBus2;
  if (distBus2 >= MAX_BUS_CM) {
    distBus2 = 0; // reset al completar ciclo
  }
  if (distBus2 != prevDist2) {
    bus2_cambio = true;
  }
}

void actualizarParticulas() {
  float prevPM1 = pm1;
  float prevPM2 = pm2;
  
  // Cambio gradual con algo de aleatoriedad
  pm1 += random(-15, 16);
  pm2 += random(-15, 16);
  
  // Mantener en rango realista
  if (pm1 < 100) pm1 = 100;
  if (pm1 > 3000) pm1 = 3000;
  if (pm2 < 100) pm2 = 100;
  if (pm2 > 3000) pm2 = 3000;
  
  // Detectar cambios significativos (>5 ppm)
  if (abs(pm1 - prevPM1) > 5) {
    pm1_cambio = true;
  }
  if (abs(pm2 - prevPM2) > 5) {
    pm2_cambio = true;
  }
}

void chequearEventos() {
  // PANICO - evento raro y puntual
  if (random(0, 1000) > 995) {
    enviar_panico = true;
    panico_id = random(1, 6); // 1-5
    Serial.print("# PANICO "); Serial.print(panico_id); Serial.println(" generado");
  }
  
  // SISMO - evento muy raro
  if (random(0, 2000) > 1998) {
    enviar_sismo = true;
    Serial.println("# SISMO generado");
  }
  
  // INFRACCIONES - gestión de estado
  actualizarInfracciones();
}

void actualizarInfracciones() {
  bool cambio_infra = false;
  
  // Infracción A
  if (!infraA_active && random(0, 2000) > 1995) {
    infraA_active = true;
    infraA_since = millis();
    cambio_infra = true;
  }
  if (infraA_active && (millis() - infraA_since > INFRA_DURATION_MS)) {
    infraA_active = false;
    // No enviamos cuando se desactiva, solo cuando se activa
  }
  
  // Infracción B
  if (!infraB_active && random(0, 2000) > 1995) {
    infraB_active = true;
    infraB_since = millis();
    cambio_infra = true;
  }
  if (infraB_active && (millis() - infraB_since > INFRA_DURATION_MS)) {
    infraB_active = false;
  }
  
  // Infracción C
  if (!infraC_active && random(0, 2000) > 1995) {
    infraC_active = true;
    infraC_since = millis();
    cambio_infra = true;
  }
  if (infraC_active && (millis() - infraC_since > INFRA_DURATION_MS)) {
    infraC_active = false;
  }
  
  // Infracción D
  if (!infraD_active && random(0, 2000) > 1995) {
    infraD_active = true;
    infraD_since = millis();
    cambio_infra = true;
  }
  if (infraD_active && (millis() - infraD_since > INFRA_DURATION_MS)) {
    infraD_active = false;
  }
  
  // Solo marcamos para envío si hay activaciones nuevas
  if (cambio_infra) {
    enviar_infra = true;
    infra_mask = 0;
    if (infraA_active) infra_mask |= 1;
    if (infraB_active) infra_mask |= 2;
    if (infraC_active) infra_mask |= 4;
    if (infraD_active) infra_mask |= 8;
  }
}

void enviarActualizaciones() {
  // SEMAFOROS - solo cuando cambian
  if (sem_cambio) {
    sem_cambio = false;
    const char* estados[3] = {"ROJO", "AMARILLO", "VERDE"};
    String estadoSem1 = String(estados[semPhase]);
    String estadoSem2 = String(estados[(semPhase + 2) % 3]);
    
    Serial.print("SEM1="); Serial.print(estadoSem1);
    Serial.print(";SEM2="); Serial.println(estadoSem2);
  }
  
  // BUSES - solo cuando cambian (pueden ir por separado)
  if (bus1_cambio) {
    bus1_cambio = false;
    Serial.print("BUS1="); Serial.println(distBus1);
  }
  
  if (bus2_cambio) {
    bus2_cambio = false;
    Serial.print("BUS2="); Serial.println(distBus2);
  }
  
  // PARTICULAS - solo cuando cambian significativamente
  if (pm1_cambio && pm2_cambio) {
    // Enviar ambas juntas si cambiaron al mismo tiempo
    pm1_cambio = false;
    pm2_cambio = false;
    Serial.print("PM1="); Serial.print((int)pm1);
    Serial.print(";PM2="); Serial.println((int)pm2);
  } else if (pm1_cambio) {
    pm1_cambio = false;
    Serial.print("PM1="); Serial.println((int)pm1);
  } else if (pm2_cambio) {
    pm2_cambio = false;
    Serial.print("PM2="); Serial.println((int)pm2);
  }
  
  // EVENTOS PUNTUALES
  if (enviar_panico) {
    enviar_panico = false;
    Serial.print("PANICO"); Serial.print(panico_id); Serial.println("=1");
  }
  
  if (enviar_sismo) {
    enviar_sismo = false;
    Serial.println("SISMO=1");
  }
  
  if (enviar_infra) {
    enviar_infra = false;
    // Enviar solo las infracciones activas
    bool primera = true;
    String mensaje = "";
    
    if (infra_mask & 1) {
      if (!primera) mensaje += ";";
      mensaje += "INFRAA=1";
      primera = false;
    }
    if (infra_mask & 2) {
      if (!primera) mensaje += ";";
      mensaje += "INFRAB=1";
      primera = false;
    }
    if (infra_mask & 4) {
      if (!primera) mensaje += ";";
      mensaje += "INFRAC=1";
      primera = false;
    }
    if (infra_mask & 8) {
      if (!primera) mensaje += ";";
      mensaje += "INFRAD=1";
      primera = false;
    }
    
    if (mensaje.length() > 0) {
      Serial.println(mensaje);
    }
  }
}