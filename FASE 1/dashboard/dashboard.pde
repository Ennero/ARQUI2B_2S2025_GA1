import processing.serial.*;
Serial myPort; 
String datosSerial = "";

// ==================== VARIABLES DE SISTEMA ====================
// Variables booleanas para manejar infracciones de semáforos
boolean semaforoInfraccion1 = false;
boolean semaforoInfraccion2 = false;
boolean semaforoInfraccion3 = false;
boolean semaforoInfraccion4 = false;

// Estados de los semáforos principales
String estadoSem1 = "VERDE"; // cara 1
String estadoSem2 = "ROJO";  // cara 2 

// Configuración de caras para las intersecciones A, B, C, D
int[] configCaras = {0, 1, 0, 1}; 

// ==================== SENSORES DE INCENDIO ====================
// Variables para partículas (ppm) - actualizadas desde Arduino
float nivelParticulas1 = 150; 
float nivelParticulas2 = 150;
// Umbral para detectar incendio automáticamente
final float UMBRAL_INCENDIO = 1000.0; // ppm
String alertaExtra = "Sin alertas";

// ==================== SISTEMA DE TRANSPORTE ====================
// TRANSURBANO: Nueva configuración - 200cm total con estaciones específicas
final float MAX_BUS_TRANSURBANO = 200.0; // Distancia máxima para transurbano
float distanciaParada2 = 0; // Distancia actual del transurbano
float progresoBus2 = 0; // Progreso 0-1 para transurbano
// Estados para reconocer ciclos del transurbano
float prevDistBus2 = -1;
int halfIndexBus2 = 0; // 0 or 1 para dos semiperímetros

// TRANSMETRO: Nueva configuración - 360cm total con estación cada 120cm
final float MAX_BUS_TRANSMETRO = 360.0; // Distancia máxima para transmetro
float distanciaParada1 = 0; // Distancia actual del transmetro
float progresoBus1 = 0; // Progreso 0-1 para transmetro
// Estados para reconocer ciclos del transmetro
float prevDistBus1 = -1;
int halfIndexBus1 = 0;

// Velocidad de animación (no se usa para cálculo de posición real)
float velocidadBus = 0.005; 

// ==================== SISTEMA DE ALERTAS ====================
// Botones de pánico y sus timestamps
boolean[] panicoBtns = {false, false, false, false, false};
long[] panicoTimestamps = new long[5];

// Sistema sísmico
long lastSismoTimestamp = 0;
boolean sismo = false;

// Timestamps para incendios (ahora manejados por umbral)
long[] incendioTimestamps = new long[2];

// Timestamps para infracciones de semáforos
long[] semaforoInfraccionTimestamps = new long[4];

// ==================== VARIABLES VISUALES ====================
final int ALERT_HOLD_MS = 5000; // Tiempo en ms para mantener visible una alerta
float pulsoAlerta = 0; // Variable para animación de pulso
int tiempoUltimaInfraccion = 0;
String ultimaInfraccionSemaforo = ""; 

// ==================== CONFIGURACIÓN INICIAL ====================
void setup() {
  size(1200, 790);
  surface.setTitle("Dashboard IoT - Sistema de Monitoreo Urbano");

  // Mostrar puertos serie disponibles para debugging
  println("Puertos serie disponibles:");
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) println(i + ": " + ports[i]);

  // Intentar conexión serial
  if (ports.length > 0) {
    String portName = "COM4"; // Ajustar según el puerto del Arduino
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
    println("Conectado a: " + portName);
  } else {
    println("No se encontró puerto serie. Verificar conexión del Arduino.");
  }

  // Configurar fuente por defecto
  textFont(createFont("Arial", 12));
}

// ==================== BUCLE PRINCIPAL ====================
void draw() {
  // Dibujar elementos de la interfaz
  dibujarFondoGradiente();
  pulsoAlerta += 0.1; // Incrementar animación de pulso
  actualizarEstadosAlertas(); // Actualizar estados basados en timestamps
  dibujarTitulo();

  // Configuración de paneles principales
  float topPanelX1 = 30;
  float topPanelY = 80;     
  float topPanelW1 = 540;   // Ancho panel semáforos
  float topPanelW2 = 300;   // Ancho panel incendios
  float topPanelW3 = 220;   // Ancho panel alertas
  float topPanelH = 300;    // Altura paneles superiores

  // Dibujar paneles principales
  dibujarSemaforos(topPanelX1, topPanelY, topPanelW1, topPanelH);
  dibujarMonitoreoIncendios(topPanelX1 + topPanelW1 + 30, topPanelY, topPanelW2, topPanelH);
  dibujarAlertas(topPanelX1 + topPanelW1 + 30 + topPanelW2 + 20, topPanelY, topPanelW3, topPanelH);

  // Dibujar mapa de buses (panel inferior)
  dibujarMapaBuses(30, 400, 1110, 320);

  // Dibujar barra de estado inferior
  dibujarBarraEstado();
}

// ==================== FUNCIONES DE INTERFAZ VISUAL ====================
/**
 * Dibuja el título principal del dashboard con efectos visuales
 */
void dibujarTitulo() {
  // Efecto de gradiente en la parte superior
  for (int i = 0; i < 60; i++) {
    float alpha = map(i, 0, 60, 100, 0);
    stroke(50, 150, 255, alpha);
    line(0, i, width, i);
  }
  
  // Título principal con sombra
  fill(255);
  textSize(42);
  textAlign(CENTER, CENTER);
  fill(0, 0, 0, 100); // Sombra
  text("Sistema de Monitoreo Urbano", width/2 + 3, 33);
  fill(100, 200, 255); // Texto principal
  text("Sistema de Monitoreo Urbano", width/2, 30);
  
  // Línea decorativa
  stroke(100, 200, 255);
  strokeWeight(4);
  line(width/2 - 300, 55, width/2 + 300, 55);
  
  // Círculos decorativos en los extremos
  fill(100, 200, 255);
  noStroke();
  ellipse(width/2 - 310, 55, 8, 8);
  ellipse(width/2 + 310, 55, 8, 8);
}

/**
 * Crea un fondo con gradiente suave
 */
void dibujarFondoGradiente() {
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(25, 25, 35), color(45, 45, 60), inter);
    stroke(c);
    line(0, i, width, i);
  }
}

/**
 * Dibuja el panel de control de semáforos
 */
void dibujarSemaforos(float x, float y, float w, float h) {
  // Panel principal con sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);
  
  // Título del panel
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE SEMAFOROS", x + 15, y + 15);
  
  // Línea decorativa
  stroke(100, 200, 255);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);
  
  // Estado general del sistema
  fill(150, 200, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Control Sincronizado: SEM1=" + estadoSem1 + " | SEM2=" + estadoSem2, x + 15, y + 55);

  // Configuración de grid para semáforos individuales
  float semaforoW = (w - 60) / 2;
  float semaforoH = (h - 100) / 2;

  // Dibujar cada intersección con su configuración específica
  String sem1_A = (configCaras[0] == 0) ? estadoSem1 : estadoSem2;
  String sem2_A = (configCaras[0] == 0) ? estadoSem2 : estadoSem1;
  dibujarSemaforoDobleIndividual(x + 15, y + 80, semaforoW, semaforoH, "INTERSECCION A", sem1_A, sem2_A, semaforoInfraccion1);

  String sem1_B = (configCaras[1] == 0) ? estadoSem1 : estadoSem2;
  String sem2_B = (configCaras[1] == 0) ? estadoSem2 : estadoSem1;
  dibujarSemaforoDobleIndividual(x + 15 + semaforoW + 15, y + 80, semaforoW, semaforoH, "INTERSECCION B", sem1_B, sem2_B, semaforoInfraccion2);

  String sem1_C = (configCaras[2] == 0) ? estadoSem1 : estadoSem2;
  String sem2_C = (configCaras[2] == 0) ? estadoSem2 : estadoSem1;
  dibujarSemaforoDobleIndividual(x + 15, y + 80 + semaforoH + 15, semaforoW, semaforoH, "INTERSECCION C", sem1_C, sem2_C, semaforoInfraccion3);

  String sem1_D = (configCaras[3] == 0) ? estadoSem1 : estadoSem2;
  String sem2_D = (configCaras[3] == 0) ? estadoSem2 : estadoSem1;
  dibujarSemaforoDobleIndividual(x + 15 + semaforoW + 15, y + 80 + semaforoH + 15, semaforoW, semaforoH, "INTERSECCION D", sem1_D, sem2_D, semaforoInfraccion4);
}

/**
 * Dibuja un semáforo individual con dos caras
 */
void dibujarSemaforoDobleIndividual(float x, float y, float w, float h, String id, String estadoCara1, String estadoCara2, boolean infraccion) {
  // Color de fondo según estado de infracción
  if (infraccion) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);
  
  // Etiqueta de identificación
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text(id, x + 8, y + 8);

  // Semáforo Cara 1
  float semaforo1X = x + w - 70;
  float semaforo1Y = y + 8;
  fill(20, 20, 25);
  stroke(100);
  strokeWeight(1);
  rect(semaforo1X, semaforo1Y, 25, 65, 5);
  fill(150, 200, 255);
  textSize(10);
  textAlign(CENTER, TOP);
  text("CARA 1", semaforo1X + 12.5, semaforo1Y + 70);
  dibujarLucesSemaforo(semaforo1X + 12.5, semaforo1Y, estadoCara1);

  // Semáforo Cara 2
  float semaforo2X = x + w - 35;
  float semaforo2Y = y + 8;
  fill(20, 20, 25);
  stroke(100);
  strokeWeight(1);
  rect(semaforo2X, semaforo2Y, 25, 65, 5);
  fill(255, 150, 150);
  textSize(10);
  textAlign(CENTER, TOP);
  text("CARA 2", semaforo2X + 12.5, semaforo2Y + 70);
  dibujarLucesSemaforo(semaforo2X + 12.5, semaforo2Y, estadoCara2);

  // Información de estado
  fill(255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("C1: " + estadoCara1 + " | C2: " + estadoCara2, x + 8, y + 28);

  // Indicador de infracción con animación
  if (infraccion) {
    float brillo = 150 + sin(pulsoAlerta) * 50;
    fill(brillo, 50, 50);
    text("INFRACCION", x + 8, y + 45);
  } else {
    fill(100, 255, 100);
    text("Normal", x + 8, y + 45);
  }
}

/**
 * Dibuja las luces individuales de un semáforo
 */
void dibujarLucesSemaforo(float centerX, float centerY, String estado) {
  // Luz roja
  if (estado.equals("ROJO")) fill(255, 50, 50); else fill(50, 20, 20);
  ellipse(centerX, centerY + 12, 15, 15);
  
  // Luz amarilla
  if (estado.equals("AMARILLO")) fill(255, 255, 50); else fill(50, 50, 20);
  ellipse(centerX, centerY + 32, 15, 15);
  
  // Luz verde
  if (estado.equals("VERDE")) fill(50, 255, 50); else fill(20, 50, 20);
  ellipse(centerX, centerY + 52, 15, 15);
}

/**
 * Dibuja el panel de monitoreo de incendios con sensores MQ-02
 */
void dibujarMonitoreoIncendios(float x, float y, float w, float h) {
  // Panel principal con sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);
  
  // Título del panel
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("MONITOREO DE INCENDIOS", x + 15, y + 15);
  
  // Línea decorativa
  stroke(150, 255, 150);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);
  
  // Subtítulo
  fill(200, 220, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("SENSORES DE GAS/HUMO MQ-02", x + 15, y + 60);

  // Configuración de sensores
  float sensorW = w - 30;
  float sensorH = 85;
  
  // Determinar estado de alerta basado en umbral (no en señales INC1/INC2)
  boolean alto1 = (nivelParticulas1 > UMBRAL_INCENDIO);
  boolean alto2 = (nivelParticulas2 > UMBRAL_INCENDIO);
  
  // Si se detecta nivel alto, actualizar timestamp para mantener alerta visible
  if (alto1) incendioTimestamps[0] = millis();
  if (alto2) incendioTimestamps[1] = millis();
  
  // Verificar si la alerta debe mantenerse visible
  boolean mostrarAlerta1 = (millis() - incendioTimestamps[0] < ALERT_HOLD_MS);
  boolean mostrarAlerta2 = (millis() - incendioTimestamps[1] < ALERT_HOLD_MS);
  
  // Dibujar sensores individuales
  dibujarSensorParticulas(x + 15, y + 85, sensorW, sensorH, "M-1", nivelParticulas1, mostrarAlerta1);
  dibujarSensorParticulas(x + 15, y + 85 + sensorH + 15, sensorW, sensorH, "M-2", nivelParticulas2, mostrarAlerta2);
}

/**
 * Dibuja un sensor de partículas individual con su estado
 */
void dibujarSensorParticulas(float x, float y, float w, float h, String id, float nivel, boolean altoNivel) {
  // Color de fondo según nivel de alerta
  if (altoNivel) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);
  
  // Identificador del sensor
  fill(200, 220, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text(id, x + 10, y + 10);
  
  // Icono de estado
  float iconX = x + w - 50;
  float iconY = y + 35;
  if (altoNivel) {
    // Estado de alerta con animación
    fill(255, 100 + sin(pulsoAlerta * 2) * 50, 100);
    noStroke();
    ellipse(iconX, iconY, 35, 35);
    fill(255, 50, 50);
    textSize(12);
    textAlign(CENTER, TOP);
    text("INCENDIO", iconX, iconY + 20);
  } else {
    // Estado normal
    fill(100, 255, 100);
    stroke(150, 255, 150);
    strokeWeight(2);
    ellipse(iconX, iconY, 30, 30);
    fill(150, 255, 150);
    textSize(12);
    textAlign(CENTER, TOP);
    text("SIN INCENDIO", iconX, iconY + 20);
  }
  
  // Mostrar valor actual en ppm
  fill(255);
  textSize(18);
  textAlign(LEFT, CENTER);
  text(nf(nivel, 1, 1) + " ppm", x + 10, iconY);
}

/**
 * Dibuja el mapa del sistema de transporte público
 */
void dibujarMapaBuses(float x, float y, float w, float h) {
  // Panel principal con sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  // Título del panel
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE TRANSPORTE PUBLICO", x + 15, y + 15);
  
  // Línea decorativa
  stroke(100, 255, 150);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);

  // ==================== RUTA TRANSMETRO (EXTERIOR) ====================
  float rutaTransmetroX = x + 60;
  float rutaTransmetroY = y + 90;
  float rutaTransmetroW = w - 450;   // Reducido para dar más espacio a la leyenda
  float rutaTransmetroH = 185;       

  // Dibujar ruta principal
  stroke(50, 150, 255);
  strokeWeight(6);
  noFill();
  rect(rutaTransmetroX, rutaTransmetroY, rutaTransmetroW, rutaTransmetroH, 10);
  stroke(100, 200, 255, 100);
  strokeWeight(10);
  rect(rutaTransmetroX, rutaTransmetroY, rutaTransmetroW, rutaTransmetroH, 10);

  // Ajuste de shift opuesto al ciclo: -40 cm
  float shiftCm = -40.0;
  float shiftFrac = shiftCm / MAX_BUS_TRANSMETRO;
  float progreso360 = ((distanciaParada1 % MAX_BUS_TRANSMETRO) / MAX_BUS_TRANSMETRO + shiftFrac + 1.0) % 1.0;
  PVector posBusTransmetro = calcularPosicionEnRutaRectTransmetro(rutaTransmetroX, rutaTransmetroY, rutaTransmetroW, rutaTransmetroH, progreso360);

  // Dibujar bus Transmetro
  fill(0, 0, 0, 100); // Sombra
  noStroke();
  ellipse(posBusTransmetro.x + 2, posBusTransmetro.y + 2, 20, 20);
  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(posBusTransmetro.x, posBusTransmetro.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("T", posBusTransmetro.x, posBusTransmetro.y);

  // Información de la ruta Transmetro
  fill(100, 200, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA TRANSMETRO", rutaTransmetroX, rutaTransmetroY - 20);

  fill(200, 220, 255);
  textSize(12);
  text("Distancia recorrida: " + nf(distanciaParada1, 1, 0) + " cm / 360 cm", rutaTransmetroX, rutaTransmetroY + rutaTransmetroH + 15);

  // ==================== RUTA TRANSURBANO (INTERIOR) ====================
  float rutaTransurbanoW = rutaTransmetroW * 0.40;  
  float rutaTransurbanoH = rutaTransmetroH * 0.50; 
  float rutaTransurbanoX = rutaTransmetroX + (rutaTransmetroW - rutaTransurbanoW) / 2;
  float rutaTransurbanoY = rutaTransmetroY + (rutaTransmetroH - rutaTransurbanoH) / 2;

  // Dibujar ruta interior
  stroke(255, 100, 100);
  strokeWeight(6);
  noFill();
  rect(rutaTransurbanoX, rutaTransurbanoY, rutaTransurbanoW, rutaTransurbanoH, 8);
  stroke(255, 150, 150, 100);
  strokeWeight(8);
  rect(rutaTransurbanoX, rutaTransurbanoY, rutaTransurbanoW, rutaTransurbanoH, 8);

  // Calcular posición del bus Transurbano con nueva configuración: inicia en esquina superior derecha, 100 cm en esquina inferior izquierda
  float progresoTransurbano = calcularProgresoTransurbano(distanciaParada2);
  PVector posBusTransurbano = calcularPosicionEnRutaRectTransurbano(rutaTransurbanoX, rutaTransurbanoY, rutaTransurbanoW, rutaTransurbanoH, progresoTransurbano);

  // Dibujar bus Transurbano
  fill(0, 0, 0, 100); // Sombra
  noStroke();
  ellipse(posBusTransurbano.x + 2, posBusTransurbano.y + 2, 20, 20);
  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(posBusTransurbano.x, posBusTransurbano.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("U", posBusTransurbano.x, posBusTransurbano.y);

  // Información de la ruta Transurbano
  fill(255, 150, 150);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA TRANSURBANO", rutaTransurbanoX, rutaTransurbanoY - 20);

  fill(255, 200, 200);
  textSize(12);
  text("Distancia recorrida: " + nf(distanciaParada2, 1, 0) + " cm / 200 cm", rutaTransurbanoX, rutaTransurbanoY + rutaTransurbanoH + 15);

  // ==================== ESTACIONES MEJORADAS ====================
  // Estaciones Transmetro: Ajustadas para mayor separación visual, con shift
  fill(255, 255, 100);
  stroke(255, 255, 200);
  strokeWeight(2);
  
  // Estación E1 (0cm ajustado por shift) - Esquina superior derecha ajustada
  float estacion1Frac = (0.0 / MAX_BUS_TRANSMETRO + shiftFrac + 1.0) % 1.0;
  PVector estacion1Pos = calcularPosicionEnRutaRectTransmetro(rutaTransmetroX, rutaTransmetroY, rutaTransmetroW, rutaTransmetroH, estacion1Frac);
  ellipse(estacion1Pos.x, estacion1Pos.y, 14, 14);
  
  // Estación E2 (120cm ajustado por shift)
  float estacion2Frac = (120.0 / MAX_BUS_TRANSMETRO + shiftFrac + 1.0) % 1.0;
  PVector estacion2Pos = calcularPosicionEnRutaRectTransmetro(rutaTransmetroX, rutaTransmetroY, rutaTransmetroW, rutaTransmetroH, estacion2Frac);
  ellipse(estacion2Pos.x, estacion2Pos.y, 14, 14);

  // Estaciones Transurbano: Justo en 0 y 100 cm
  float estacionTU1Frac = 0.0 / MAX_BUS_TRANSURBANO;
  PVector estacionTU1Pos = calcularPosicionEnRutaRectTransurbano(rutaTransurbanoX, rutaTransurbanoY, rutaTransurbanoW, rutaTransurbanoH, estacionTU1Frac);
  ellipse(estacionTU1Pos.x, estacionTU1Pos.y, 12, 12);

  float estacionTU2Frac = 100.0 / MAX_BUS_TRANSURBANO;
  PVector estacionTU2Pos = calcularPosicionEnRutaRectTransurbano(rutaTransurbanoX, rutaTransurbanoY, rutaTransurbanoW, rutaTransurbanoH, estacionTU2Frac);
  ellipse(estacionTU2Pos.x, estacionTU2Pos.y, 12, 12);

  // Etiquetas para las estaciones con mejor posicionamiento
  fill(255, 255, 200);
  textSize(11);
  textAlign(CENTER, CENTER);

  // Etiquetas Transmetro mejoradas
  text("E1", estacion1Pos.x - 20, estacion1Pos.y - 12);  // Movida hacia la izquierda
  text("E2", estacion2Pos.x + 20, estacion2Pos.y + 12);  // Movida hacia la derecha

  // Etiquetas Transurbano
  text("U1", estacionTU1Pos.x, estacionTU1Pos.y - 15);
  text("U2", estacionTU2Pos.x, estacionTU2Pos.y + 15);

  // ==================== LEYENDA EXPANDIDA ====================
  dibujarLeyendaTransporte(x, y, w);
}

/**
 * Calcula el progreso del Transurbano según la nueva configuración
 */
float calcularProgresoTransurbano(float distancia) {
  distancia = distancia % MAX_BUS_TRANSURBANO; 
  return distancia / MAX_BUS_TRANSURBANO;
}

/**
 * Calcula la posición de un bus en una ruta rectangular para Transmetro
 */
PVector calcularPosicionEnRutaRectTransmetro(float x, float y, float ancho, float alto, float progreso) {
  PVector pos = new PVector();
  progreso = progreso % 1.0;
  if (progreso < 0) progreso += 1.0;
  
  float perimetro = 2 * (ancho + alto);
  float distancia = progreso * perimetro;
  
  if (distancia <= alto) {
    // Lado derecho: arriba a abajo (desde esquina superior derecha)
    pos.x = x + ancho;
    pos.y = y + distancia;
  } else if (distancia <= alto + ancho) {
    // Lado inferior: derecha a izquierda
    pos.x = x + ancho - (distancia - alto);
    pos.y = y + alto;
  } else if (distancia <= alto + ancho + alto) {
    // Lado izquierdo: abajo a arriba
    pos.x = x;
    pos.y = y + alto - (distancia - (alto + ancho));
  } else {
    // Lado superior: izquierda a derecha
    pos.x = x + (distancia - (2*alto + ancho));
    pos.y = y;
  }
  return pos;
}

/**
 * Calcula la posición de un bus en una ruta rectangular para Transurbano: inicia en superior derecha, 100cm en inferior izquierda
 */
PVector calcularPosicionEnRutaRectTransurbano(float x, float y, float ancho, float alto, float progreso) {
  PVector pos = new PVector();
  progreso = progreso % 1.0;
  if (progreso < 0) progreso += 1.0;
  
  float perimetro = 2 * (ancho + alto);
  float distancia = progreso * perimetro;
  
  if (distancia <= alto) {
    // Lado derecho: arriba a abajo (desde esquina superior derecha)
    pos.x = x + ancho;
    pos.y = y + distancia;
  } else if (distancia <= alto + ancho) {
    // Lado inferior: derecha a izquierda
    pos.x = x + ancho - (distancia - alto);
    pos.y = y + alto;
  } else if (distancia <= alto + ancho + alto) {
    // Lado izquierdo: abajo a arriba
    pos.x = x;
    pos.y = y + alto - (distancia - (alto + ancho));
  } else {
    // Lado superior: izquierda a derecha
    pos.x = x + (distancia - (2*alto + ancho));
    pos.y = y;
  }
  return pos;
}

/**
 * Dibuja la leyenda expandida del sistema de transporte
 */
void dibujarLeyendaTransporte(float x, float y, float w) {
  float leyendaX = x + w - 230; // Más ancha
  float leyendaY = y + 60;
  float leyendaW = 210; // Expandida de 160 a 210
  float leyendaH = 220; // Expandida de 180 a 220
  
  // Panel de leyenda con mejor estilo
  fill(20, 25, 30);
  stroke(60, 70, 80);
  strokeWeight(2);
  rect(leyendaX, leyendaY, leyendaW, leyendaH, 10);
  
  // Título de leyenda más grande
  fill(200, 220, 255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("LEYENDA", leyendaX + 15, leyendaY + 15);
  
  // Línea decorativa
  stroke(100, 150, 200);
  strokeWeight(2);
  line(leyendaX + 15, leyendaY + 40, leyendaX + leyendaW - 15, leyendaY + 40);
  
  float itemY = leyendaY + 50;
  textSize(13); // Texto ligeramente más grande
  
  // Estaciones
  fill(255, 255, 100);
  noStroke();
  ellipse(leyendaX + 25, itemY + 6, 10, 10);
  fill(255);
  textAlign(LEFT, TOP);
  text("Estación (parada)", leyendaX + 40, itemY);
  itemY += 22;
  
  // Bus Transmetro
  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 25, itemY + 6, 14, 14);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(9);
  text("T", leyendaX + 25, itemY + 6);
  textAlign(LEFT, TOP);
  textSize(13);
  fill(255);
  text("Bus Transmetro", leyendaX + 40, itemY);
  textSize(11);
  fill(150, 200, 255);
  text("Ruta: 360cm", leyendaX + 40, itemY + 15);
  itemY += 35;
  
  // Bus Transurbano
  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 25, itemY + 6, 14, 14);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(9);
  text("U", leyendaX + 25, itemY + 6);
  textAlign(LEFT, TOP);
  textSize(13);
  fill(255);
  text("Bus Transurbano", leyendaX + 40, itemY);
  textSize(11);
  fill(255, 150, 150);
  text("Ruta: 200cm", leyendaX + 40, itemY + 15);
  itemY += 35;
  
  // Separador
  stroke(80, 90, 100);
  strokeWeight(1);
  line(leyendaX + 15, itemY, leyendaX + leyendaW - 15, itemY);
  itemY += 15;
  
  // Estado del sistema expandido
  fill(100, 255, 150);
  textSize(13);
  text("Sistema Operativo", leyendaX + 15, itemY);
  itemY += 18;
  fill(200, 220, 255);
  textSize(11);
  text("Buses en circulación: 2", leyendaX + 15, itemY);
  itemY += 15;
  text("Conexión: Activa", leyendaX + 15, itemY);
  itemY += 15;
}

/**
 * Dibuja el panel de alertas del sistema
 */
void dibujarAlertas(float x, float y, float w, float h) {
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("ALERTAS", x + 15, y + 15);
  stroke(255, 200, 100);
  strokeWeight(3);
  line(x + 15, y + 40, x + w - 15, y + 40);

  float alertaY = y + 60;
  boolean anyPanico = false;
  for (int i = 0; i < panicoBtns.length; i++) {
    if (panicoBtns[i]) {
      anyPanico = true;
      fill(80, 60, 20);
      stroke(255, 200, 100);
      strokeWeight(2);
      rect(x + 10, alertaY, w - 20, 40, 8);
      float brillo = 200 + sin(pulsoAlerta * (1 + i)) * 55;
      fill(brillo, brillo * 0.7, 50);
      textSize(14);
      textAlign(CENTER, TOP);
      text("BOTON DE PANICO " + (i+1), x + w/2, alertaY + 8);
      textSize(10);
      fill(255, 220, 150);
      text("Solicitud de ayuda entrante", x + w/2, alertaY + 24);
      alertaY += 52;
    }
  }

  if (sismo) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
    strokeWeight(2);
    rect(x + 10, alertaY, w - 20, 60, 8);
    float brillo = 200 + sin(pulsoAlerta * 2) * 55;
    fill(brillo, 100, 100);
    textSize(14);
    textAlign(CENTER, TOP);
    text("SISMO DETECTADO", x + w/2, alertaY + 10);
    fill(255, 200, 200);
    textSize(10);
    text("Activar protocolo", x + w/2, alertaY + 28);
    text("de emergencia", x + w/2, alertaY + 40);
    alertaY += 80;
  }

  if (!anyPanico && !sismo) {
    fill(30, 60, 30);
    stroke(100, 200, 100);
    strokeWeight(1);
    rect(x + 10, alertaY, w - 20, 50, 8);
    fill(150, 255, 150);
    textSize(12);
    textAlign(CENTER, CENTER);
    text("Sin Alertas", x + w/2, alertaY + 25);
  }

  fill(200, 220, 255);
  textSize(9);
  textAlign(LEFT, BOTTOM);
  text("Ultima actualizacion:", x + 10, y + h - 20);
  text(nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), x + 10, y + h - 8);
}

/**
 * Actualiza los estados de las alertas basándose en timestamps
 */
void actualizarEstadosAlertas() {
  // Actualizar infracciones de semáforos
  semaforoInfraccion1 = (millis() - semaforoInfraccionTimestamps[0] < ALERT_HOLD_MS);
  semaforoInfraccion2 = (millis() - semaforoInfraccionTimestamps[1] < ALERT_HOLD_MS);
  semaforoInfraccion3 = (millis() - semaforoInfraccionTimestamps[2] < ALERT_HOLD_MS);
  semaforoInfraccion4 = (millis() - semaforoInfraccionTimestamps[3] < ALERT_HOLD_MS);
  
  // pánico: mantener visible ALERT_HOLD_MS ms desde la última vez que se activó
  for (int i = 0; i < panicoBtns.length; i++) {
    panicoBtns[i] = (millis() - panicoTimestamps[i] < ALERT_HOLD_MS);
  }
  
  // sismo
  sismo = (millis() - lastSismoTimestamp < ALERT_HOLD_MS);
}

/**
 * Dibuja la barra de estado inferior
 */
void dibujarBarraEstado() {
  // Barra de estado
  fill(20, 25, 30);
  stroke(60, 70, 80);
  strokeWeight(1);
  rect(0, height - 30, width, 30);
  
  // Información de estado
  fill(150, 200, 255);
  textSize(12);
  textAlign(LEFT, CENTER);
  
  String estadoConexion = (myPort != null) ? "Sistema Conectado" : "Sin Conexión";
  text(estadoConexion + " | Recibiendo datos | " + nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), 15, height - 15);
  
  // Logo o información adicional
  textAlign(RIGHT, CENTER);
  text("Dashboard IoT v2.0 - Creado por el Grupo 1", width - 15, height - 15);
}

/**
 * Manejo de datos serie recibidos desde Arduino - MEJORADO PARA COMPATIBILIDAD
 */
void serialEvent(Serial myPort) {
  datosSerial = myPort.readStringUntil('\n');
  
  if (datosSerial != null) {
    datosSerial = trim(datosSerial);
    println("Datos recibidos: " + datosSerial);
    
    // Manejar múltiples datos en una línea (separados por punto y coma)
    String[] partes = split(datosSerial, ';');
    
    for (String parte : partes) {
      parte = trim(parte);
      
      // Procesar formato KEY=VALUE del Arduino
      if (parte.contains("=")) {
        String[] keyValue = split(parte, '=');
        if (keyValue.length == 2) {
          String key = trim(keyValue[0]);
          String value = trim(keyValue[1]);
          
          // Procesar según el tipo de dato
          procesarDatoArduino(key, value);
        }
      }
      // Mantener compatibilidad con formato anterior
      else if (parte.startsWith("SEM1:")) {
        estadoSem1 = parte.substring(5).trim();
      } else if (parte.startsWith("SEM2:")) {
        estadoSem2 = parte.substring(5).trim();
      } else if (parte.startsWith("DIST1:")) {
        distanciaParada1 = float(parte.substring(6).trim());
      } else if (parte.startsWith("DIST2:")) {
        distanciaParada2 = float(parte.substring(6).trim());
      } else if (parte.startsWith("MQ1:")) {
        nivelParticulas1 = float(parte.substring(4).trim());
      } else if (parte.startsWith("MQ2:")) {
        nivelParticulas2 = float(parte.substring(4).trim());
      } else if (parte.startsWith("INF1")) {
        semaforoInfraccionTimestamps[0] = millis();
      } else if (parte.startsWith("INF2")) {
        semaforoInfraccionTimestamps[1] = millis();
      } else if (parte.startsWith("INF3")) {
        semaforoInfraccionTimestamps[2] = millis();
      } else if (parte.startsWith("INF4")) {
        semaforoInfraccionTimestamps[3] = millis();
      } else if (parte.startsWith("SISMO")) {
        lastSismoTimestamp = millis();
      } else if (parte.startsWith("PANIC")) {
        String[] panicPartes = split(parte, ":");
        if (panicPartes.length > 1) {
          int botonIndex = int(panicPartes[1]) - 1;
          if (botonIndex >= 0 && botonIndex < panicoBtns.length) {
            panicoTimestamps[botonIndex] = millis();
          }
        }
      }
    }
  }
}

/**
 * Procesa datos en formato KEY=VALUE del Arduino
 */
void procesarDatoArduino(String key, String value) {
  switch (key.toUpperCase()) {
    // Estados de semáforos
    case "SEM1":
      estadoSem1 = value.toUpperCase();
      break;
    case "SEM2":
      estadoSem2 = value.toUpperCase();
      break;
    
    // Posiciones de buses
    case "BUS1":
      distanciaParada1 = float(value);
      break;
    case "BUS2":
      distanciaParada2 = float(value);
      break;
    
    // Sensores de partículas
    case "PM1":
      nivelParticulas1 = float(value);
      break;
    case "PM2":
      nivelParticulas2 = float(value);
      break;
    
    // Infracciones de semáforos
    case "INFRAA":
      if (value.equals("1")) semaforoInfraccionTimestamps[0] = millis();
      break;
    case "INFRAB":
      if (value.equals("1")) semaforoInfraccionTimestamps[1] = millis();
      break;
    case "INFRAC":
      if (value.equals("1")) semaforoInfraccionTimestamps[2] = millis();
      break;
    case "INFRAD":
      if (value.equals("1")) semaforoInfraccionTimestamps[3] = millis();
      break;
    
    // Eventos de emergencia
    case "SISMO":
      if (value.equals("1")) lastSismoTimestamp = millis();
      break;
    
    // Botones de pánico (PANICO1, PANICO2, etc.)
    default:
      if (key.startsWith("PANICO") && value.equals("1")) {
        try {
          int botonNum = Integer.parseInt(key.substring(6)); // Extraer número
          int botonIndex = botonNum - 1;
          if (botonIndex >= 0 && botonIndex < panicoBtns.length) {
            panicoTimestamps[botonIndex] = millis();
          }
        } catch (NumberFormatException e) {
          println("Error procesando botón de pánico: " + key);
        }
      }
      break;
  }
}
