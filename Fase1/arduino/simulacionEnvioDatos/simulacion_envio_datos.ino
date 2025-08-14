void setup() {
  Serial.begin(9600);
  randomSeed(analogRead(0)); // Mejora la aleatoriedad
}

void loop() {
  // ====== SIMULACIÓN DE SEMÁFOROS ======
  String estadosSemaforos[] = {"ROJO", "AMARILLO", "VERDE"};
  
  String estadoSem1 = estadosSemaforos[random(0, 3)];
  String estadoSem2 = estadosSemaforos[random(0, 3)];
  String estadoSem3 = estadosSemaforos[random(0, 3)];
  String estadoSem4 = estadosSemaforos[random(0, 3)];
  
  // Simulación de infracciones (más probable cuando está en rojo)
  int infraccion1 = (estadoSem1 == "ROJO" && random(0, 10) > 7) ? 1 : 0;
  int infraccion2 = (estadoSem2 == "ROJO" && random(0, 10) > 8) ? 1 : 0;
  int infraccion3 = (estadoSem3 == "ROJO" && random(0, 10) > 8) ? 1 : 0;
  int infraccion4 = (estadoSem4 == "ROJO" && random(0, 10) > 7) ? 1 : 0;

  // ====== SIMULACIÓN DE BUSES ======
  int distanciaBus1 = random(0, 101);  // 0-100 metros
  int distanciaBus2 = random(0, 101);  // 0-100 metros

  // ====== SIMULACIÓN DE SENSORES DE INCENDIO ======
  // Los sensores envían 1 cuando detectan incendio, 0 cuando no
  int incendio1 = (random(0, 100) > 90) ? 1 : 0;  // 10% probabilidad
  int incendio2 = (random(0, 100) > 95) ? 1 : 0;  // 5% probabilidad

  // ====== SIMULACIÓN DE ALERTAS ======
  int panico = (random(0, 100) > 98) ? 1 : 0;     // 2% probabilidad
  int sismo = (random(0, 100) > 99) ? 1 : 0;      // 1% probabilidad

  // ====== ENVÍO DE DATOS AL DASHBOARD ======
  // Semáforos
  Serial.print("SEM1=");
  Serial.print(estadoSem1);
  Serial.print(";SEM2=");
  Serial.print(estadoSem2);
  Serial.print(";SEM3=");
  Serial.print(estadoSem3);
  Serial.print(";SEM4=");
  Serial.print(estadoSem4);
  
  // Infracciones de semáforos
  Serial.print(";INFRACCION1=");
  Serial.print(infraccion1);
  Serial.print(";INFRACCION2=");
  Serial.print(infraccion2);
  Serial.print(";INFRACCION3=");
  Serial.print(infraccion3);
  Serial.print(";INFRACCION4=");
  Serial.print(infraccion4);
  
  // Buses
  Serial.print(";BUS1=");
  Serial.print(distanciaBus1);
  Serial.print(";BUS2=");
  Serial.print(distanciaBus2);
  
  // Sensores de incendio
  Serial.print(";INC1=");
  Serial.print(incendio1);
  Serial.print(";INC2=");
  Serial.print(incendio2);
  
  // Alertas
  Serial.print(";PANICO=");
  Serial.print(panico);
  Serial.print(";SISMO=");
  Serial.print(sismo);
  
  Serial.println(); // Termina la línea

  // Información de debug (opcional)
  if (infraccion1 || infraccion2 || infraccion3 || infraccion4) {
    Serial.print("# INFRACCION DETECTADA: ");
    if (infraccion1) Serial.print("SEM1 ");
    if (infraccion2) Serial.print("SEM2 ");
    if (infraccion3) Serial.print("SEM3 ");
    if (infraccion4) Serial.print("SEM4 ");
    Serial.println();
  }
  
  if (incendio1 || incendio2) {
    Serial.print("# INCENDIO DETECTADO: ");
    if (incendio1) Serial.print("INC1 ");
    if (incendio2) Serial.print("INC2 ");
    Serial.println();
  }
  
  if (panico) {
    Serial.println("# BOTON DE PANICO ACTIVADO!");
  }
  
  if (sismo) {
    Serial.println("# SISMO DETECTADO!");
  }

  delay(2000); // Envía datos cada 2 segundos
}

// ====== FUNCIONES ADICIONALES PARA SIMULACIÓN MÁS REALISTA ======

// Función para simular un ciclo de semáforo más realista
void simularCicloSemaforo() {
  static unsigned long tiempoAnterior = 0;
  static int ciclo = 0;
  
  if (millis() - tiempoAnterior > 10000) { // Cambio cada 10 segundos
    tiempoAnterior = millis();
    ciclo = (ciclo + 1) % 3;
  }
}

// Función para generar eventos de emergencia temporales
void generarEventosEmergencia() {
  static unsigned long ultimoEvento = 0;
  
  if (millis() - ultimoEvento > 30000) { // Cada 30 segundos evalúa eventos
    if (random(0, 100) > 95) { // 5% probabilidad de evento
      ultimoEvento = millis();
      // Aquí podrías activar una secuencia de emergencia
    }
  }
}