import processing.serial.*;
Serial myPort; 
String datosSerial = "";

// VARIABLES DE SEMILLADO INICIALES
boolean semaforoInfraccion1 = false;
boolean semaforoInfraccion2 = false;
boolean semaforoInfraccion3 = false;
boolean semaforoInfraccion4 = false;

String estadoSem1 = "VERDE"; // cara 1
String estadoSem2 = "ROJO";  // cara 2 

int[] configCaras = {0, 1, 0, 1}; // Intersecciones A, B, C, D

// Sensores de incendio
boolean incendio1 = false;
boolean incendio2 = false;

// Variables para partículas (ppm)
float nivelParticulas1 = 150; 
float nivelParticulas2 = 150;
String alertaExtra = "Sin alertas";

// Se mapea directamente desde distancia 0..MAX 
final float MAX_BUS = 120.0; // maqueta

float distanciaParada1 = 0; // iniciar en 0 
float distanciaParada2 = 0;

float progresoBus1 = 0;
float progresoBus2 = 0;

float velocidadBus = 0.005; // no usado directamente para cálculo de posición ahora

// Estado para reconocer ciclos 
float prevDistBus1 = -1;
float prevDistBus2 = -1;
int halfIndexBus1 = 0; // 0 or 1 -> dos semiperímetros
int halfIndexBus2 = 0;

boolean[] panicoBtns = {false, false, false, false, false};
long[] panicoTimestamps = new long[5];
long lastSismoTimestamp = 0;
long[] incendioTimestamps = new long[2];
long[] semaforoInfraccionTimestamps = new long[4];
boolean sismo = false;

// Variables visuales
final int ALERT_HOLD_MS = 5000; // ms para mantener visible una alerta
float pulsoAlerta = 0;
int tiempoUltimaInfraccion = 0;
String ultimaInfraccionSemaforo = ""; 

void setup() {
  size(1200, 790);
  surface.setTitle("Dashboard IoT - Sistema de Monitoreo Urbano");

  println("Puertos serie disponibles:");
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) println(i + ": " + ports[i]);

  if (ports.length > 0) {
    String portName = "COM4"; // ajusta si necesitas otro puerto
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
    println("Conectado a: " + portName);
  } else {
    println("No se encontró puerto serie. Inicia Arduino o conecta la placa.");
  }

  textFont(createFont("Arial", 12));
}

// main loop
void draw() {
  dibujarFondoGradiente();
  pulsoAlerta += 0.1;
  actualizarEstadosAlertas();
  dibujarTitulo();

  float topPanelX1 = 30;
  float topPanelY = 80;     
  float topPanelW1 = 540;
  float topPanelW2 = 300;
  float topPanelW3 = 220;
  float topPanelH = 300;

  dibujarSemaforos(topPanelX1, topPanelY, topPanelW1, topPanelH);
  dibujarMonitoreoIncendios(topPanelX1 + topPanelW1 + 30, topPanelY, topPanelW2, topPanelH);
  dibujarAlertas(topPanelX1 + topPanelW1 + 30 + topPanelW2 + 20, topPanelY, topPanelW3, topPanelH);

  dibujarMapaBuses(30, 400, 1110, 320);

  dibujarBarraEstado();
}

// ---------- UI functions ----------
void dibujarTitulo() {
  for (int i = 0; i < 60; i++) {
    float alpha = map(i, 0, 60, 100, 0);
    stroke(50, 150, 255, alpha);
    line(0, i, width, i);
  }
  fill(255);
  textSize(42);
  textAlign(CENTER, CENTER);
  fill(0, 0, 0, 100);
  text("Sistema de Monitoreo Urbano", width/2 + 3, 33);
  fill(100, 200, 255);
  text("Sistema de Monitoreo Urbano", width/2, 30);
  stroke(100, 200, 255);
  strokeWeight(4);
  line(width/2 - 300, 55, width/2 + 300, 55);
  fill(100, 200, 255);
  noStroke();
  ellipse(width/2 - 310, 55, 8, 8);
  ellipse(width/2 + 310, 55, 8, 8);
}

void dibujarFondoGradiente() {
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(25, 25, 35), color(45, 45, 60), inter);
    stroke(c);
    line(0, i, width, i);
  }
}

void dibujarSemaforos(float x, float y, float w, float h) {
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE SEMAFOROS", x + 15, y + 15);
  stroke(100, 200, 255);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);
  fill(150, 200, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Control Sincronizado: SEM1=" + estadoSem1 + " | SEM2=" + estadoSem2, x + 15, y + 55);

  float semaforoW = (w - 60) / 2;
  float semaforoH = (h - 100) / 2;

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

void dibujarSemaforoDobleIndividual(float x, float y, float w, float h, String id, String estadoCara1, String estadoCara2, boolean infraccion) {
  if (infraccion) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text(id, x + 8, y + 8);

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

  fill(255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("C1: " + estadoCara1 + " | C2: " + estadoCara2, x + 8, y + 28);

  if (infraccion) {
    float brillo = 150 + sin(pulsoAlerta) * 50;
    fill(brillo, 50, 50);
    text("INFRACCION", x + 8, y + 45);
  } else {
    fill(100, 255, 100);
    text("Normal", x + 8, y + 45);
  }
}

void dibujarLucesSemaforo(float centerX, float centerY, String estado) {
  if (estado.equals("ROJO")) fill(255, 50, 50); else fill(50, 20, 20);
  ellipse(centerX, centerY + 12, 15, 15);
  if (estado.equals("AMARILLO")) fill(255, 255, 50); else fill(50, 50, 20);
  ellipse(centerX, centerY + 32, 15, 15);
  if (estado.equals("VERDE")) fill(50, 255, 50); else fill(20, 50, 20);
  ellipse(centerX, centerY + 52, 15, 15);
}

void dibujarMonitoreoIncendios(float x, float y, float w, float h) {
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("MONITOREO DE INCENDIOS", x + 15, y + 15);
  stroke(150, 255, 150);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);
  fill(200, 220, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("SENSORES DE GAS/HUMO MQ-02", x + 15, y + 60);

  float sensorW = w - 30;
  float sensorH = 85;
  boolean alto1 = (millis() - incendioTimestamps[0] < ALERT_HOLD_MS);
  boolean alto2 = (millis() - incendioTimestamps[1] < ALERT_HOLD_MS);
  dibujarSensorParticulas(x + 15, y + 85, sensorW, sensorH, "M-1", nivelParticulas1, alto1);
  dibujarSensorParticulas(x + 15, y + 85 + sensorH + 15, sensorW, sensorH, "M-2", nivelParticulas2, alto2);
}

void dibujarSensorParticulas(float x, float y, float w, float h, String id, float nivel, boolean altoNivel) {
  if (altoNivel) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);
  fill(200, 220, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text(id, x + 10, y + 10);
  float iconX = x + w - 50;
  float iconY = y + 35;
  if (altoNivel) {
    fill(255, 100 + sin(pulsoAlerta * 2) * 50, 100);
    noStroke();
    ellipse(iconX, iconY, 35, 35);
    fill(255, 50, 50);
    textSize(12);
    textAlign(CENTER, TOP);
    text("INCENDIO", iconX, iconY + 20);
  } else {
    fill(100, 255, 100);
    stroke(150, 255, 150);
    strokeWeight(2);
    ellipse(iconX, iconY, 30, 30);
    fill(150, 255, 150);
    textSize(12);
    textAlign(CENTER, TOP);
    text("SIN INCENDIO", iconX, iconY + 20);
  }
  fill(255);
  textSize(18);
  textAlign(LEFT, CENTER);
  text(nf(nivel, 1, 1) + " ppm", x + 10, iconY);
}

void dibujarMapaBuses(float x, float y, float w, float h) {
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15);
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE TRANSPORTE PUBLICO", x + 15, y + 15);
  stroke(100, 255, 150);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);

  float rutaOuterX = x + 60;
  float rutaOuterY = y + 90;
  float rutaOuterW = w - 400;   
  float rutaOuterH = 185;       

  stroke(50, 150, 255);
  strokeWeight(6);
  noFill();
  rect(rutaOuterX, rutaOuterY, rutaOuterW, rutaOuterH, 10);
  stroke(100, 200, 255, 100);
  strokeWeight(10);
  rect(rutaOuterX, rutaOuterY, rutaOuterW, rutaOuterH, 10);

  float perOuter = 2 * (rutaOuterW + rutaOuterH);
  float stationTopOuter = rutaOuterW * 0.75;
  float stationTopOuterFrac = (perOuter > 0) ? (stationTopOuter / perOuter) : 0;

  PVector posBus1 = calcularPosicionEnRutaRect(rutaOuterX, rutaOuterY, rutaOuterW, rutaOuterH, (progresoBus1 + stationTopOuterFrac) % 1.0);

  fill(0, 0, 0, 100);
  noStroke();
  ellipse(posBus1.x + 2, posBus1.y + 2, 20, 20);
  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(posBus1.x, posBus1.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("T", posBus1.x, posBus1.y);

  fill(100, 200, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA TRANSMETRO", rutaOuterX, rutaOuterY - 20);

  fill(200, 220, 255);
  textSize(12);
  text("Distancia a parada: " + nf(distanciaParada1, 1, 0) + " cm", rutaOuterX, rutaOuterY + rutaOuterH + 15);

  float rutaInnerW = rutaOuterW * 0.40;  
  float rutaInnerH = rutaOuterH * 0.50; 
  float rutaInnerX = rutaOuterX + (rutaOuterW - rutaInnerW) / 2;
  float rutaInnerY = rutaOuterY + (rutaOuterH - rutaInnerH) / 2;

  stroke(255, 100, 100);
  strokeWeight(6);
  noFill();
  rect(rutaInnerX, rutaInnerY, rutaInnerW, rutaInnerH, 8);
  stroke(255, 150, 150, 100);
  strokeWeight(8);
  rect(rutaInnerX, rutaInnerY, rutaInnerW, rutaInnerH, 8);

  float perInner = 2 * (rutaInnerW + rutaInnerH);
  float stationRightInner = rutaInnerW + (rutaInnerH / 2.0);
  float stationRightInnerFrac = (perInner > 0) ? (stationRightInner / perInner) : 0;

  PVector posBus2 = calcularPosicionEnRutaRect(rutaInnerX, rutaInnerY, rutaInnerW, rutaInnerH, (progresoBus2 + stationRightInnerFrac) % 1.0);

  fill(0, 0, 0, 100);
  noStroke();
  ellipse(posBus2.x + 2, posBus2.y + 2, 20, 20);
  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(posBus2.x, posBus2.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("U", posBus2.x, posBus2.y);

  fill(255, 150, 150);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA TRANSURBANO", rutaInnerX, rutaInnerY - 20);

  fill(255, 200, 200);
  textSize(12);
  text("Distancia a parada: " + nf(distanciaParada2, 1, 0) + " cm", rutaInnerX, rutaInnerY + rutaInnerH + 15);

  fill(255, 255, 100);
  stroke(255, 255, 200);
  strokeWeight(2);
  ellipse(rutaOuterX + rutaOuterW * 0.75, rutaOuterY + 10, 12, 12);
  ellipse(rutaOuterX + rutaOuterW * 0.25, rutaOuterY + rutaOuterH - 10, 12, 12);

  float marginInner = 12;
  ellipse(rutaInnerX + marginInner, rutaInnerY + rutaInnerH/2, 12, 12);
  ellipse(rutaInnerX + rutaInnerW - marginInner, rutaInnerY + rutaInnerH/2, 12, 12);

  float leyendaW = 240;
  float leyendaH = 200;
  float leyendaX = x + w - leyendaW - 20;
  float leyendaY = y + 90;
  fill(30, 35, 40);
  stroke(60, 70, 80);
  strokeWeight(1);
  rect(leyendaX, leyendaY, leyendaW, leyendaH, 8);
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("LEYENDA", leyendaX + 12, leyendaY + 12);

  fill(255, 255, 100);
  stroke(255, 255, 200);
  strokeWeight(2);
  ellipse(leyendaX + 24, leyendaY + 52, 14, 14);
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Estación (parada)", leyendaX + 44, leyendaY + 46);

  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 24, leyendaY + 86, 20, 20);
  fill(255);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("T", leyendaX + 24, leyendaY + 86);
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Bus Transmetro", leyendaX + 44, leyendaY + 78);

  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 24, leyendaY + 114, 20, 20);
  fill(255);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("U", leyendaX + 24, leyendaY + 114);
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Bus Transurbano", leyendaX + 44, leyendaY + 106);

  fill(100, 255, 100);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Sistema Operativo", leyendaX + 12, leyendaY + 144);
  fill(150, 200, 255);
  textSize(13);
  text("Buses en circulacion: 2", leyendaX + 12, leyendaY + 160);
}

float minimalCircularDistance(float a, float b, float per) {
  float diff = abs(a - b);
  return min(diff, per - diff);
}

PVector calcularPosicionEnRutaRect(float x, float y, float ancho, float alto, float progreso) {
  PVector pos = new PVector();
  progreso = progreso % 1.0;
  if (progreso < 0) progreso += 1.0;
  float per = 2 * (ancho + alto);
  float dist = progreso * per;
  if (dist <= ancho) {
    pos.x = x + dist;
    pos.y = y;
  } else if (dist <= ancho + alto) {
    pos.x = x + ancho;
    pos.y = y + (dist - ancho);
  } else if (dist <= ancho + alto + ancho) {
    pos.x = x + ancho - (dist - (ancho + alto));
    pos.y = y + alto;
  } else {
    pos.x = x;
    pos.y = y + alto - (dist - (2*ancho + alto));
  }
  return pos;
}

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

void registrarInfraccion(int idx) {
  if (idx >= 0 && idx < semaforoInfraccionTimestamps.length) {
    semaforoInfraccionTimestamps[idx] = millis();
  }
}

void actualizarEstadosAlertas() {
  for (int i = 0; i < panicoBtns.length; i++) {
    panicoBtns[i] = (millis() - panicoTimestamps[i] < ALERT_HOLD_MS);
  }
  sismo = (millis() - lastSismoTimestamp < ALERT_HOLD_MS);
  incendio1 = (millis() - incendioTimestamps[0] < ALERT_HOLD_MS);
  incendio2 = (millis() - incendioTimestamps[1] < ALERT_HOLD_MS);
  semaforoInfraccion1 = (millis() - semaforoInfraccionTimestamps[0] < ALERT_HOLD_MS);
  semaforoInfraccion2 = (millis() - semaforoInfraccionTimestamps[1] < ALERT_HOLD_MS);
  semaforoInfraccion3 = (millis() - semaforoInfraccionTimestamps[2] < ALERT_HOLD_MS);
  semaforoInfraccion4 = (millis() - semaforoInfraccionTimestamps[3] < ALERT_HOLD_MS);
}

void dibujarBarraEstado() {
  fill(30, 35, 40);
  stroke(60, 70, 80);
  strokeWeight(1);
  rect(0, height - 40, width, 40);
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("Sistema Conectado  |  Recibiendo datos  |  " + nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), 15, height - 20);
  textAlign(RIGHT, CENTER);
  text("Dashboard IoT v2.0 - Creado por el Grupo 1 ", width - 15, height - 20);
}

// Serial parsing 
void serialEvent(Serial myPort) {
  datosSerial = myPort.readStringUntil('\n');
  if (datosSerial == null) return;
  datosSerial = trim(datosSerial);
  
  // Ignorar líneas de debug que empiecen con '#'
  if (datosSerial.startsWith("#")) {
    println("DEBUG: " + datosSerial);
    return;
  }

  // Cada línea puede tener cualquier combinación de datos
  String[] partes = split(datosSerial, ';');
  for (String parte : partes) {
    if (parte.trim().length() == 0) continue; // saltar partes vacías
    
    String[] kv = split(parte, '=');
    if (kv.length != 2) continue;
    String key = trim(kv[0]);
    String val = trim(kv[1]);

    // SEMAFOROS
    if (key.equals("SEM1")) {
      estadoSem1 = val;
      println("Actualizado SEM1: " + val);
    }
    else if (key.equals("SEM2")) {
      estadoSem2 = val;
      println("Actualizado SEM2: " + val);
    }

    // BUSES
    else if (key.equals("BUS1")) {
      String clean = val.replaceAll("[^0-9\\.\\-]", "");
      if (clean.length() > 0) {
        float d = float(clean);
        if (d < 0) d = 0;
        if (d > MAX_BUS) d = MAX_BUS;
        procesarBusComoDistancia(1, d);
        println("Actualizado BUS1: " + d + " cm");
      }
    }
    else if (key.equals("BUS2")) {
      String clean = val.replaceAll("[^0-9\\.\\-]", "");
      if (clean.length() > 0) {
        float d = float(clean);
        if (d < 0) d = 0;
        if (d > MAX_BUS) d = MAX_BUS;
        procesarBusComoDistancia(2, d);
        println("Actualizado BUS2: " + d + " cm");
      }
    }

    // PARTICULAS
    else if (key.equals("PM1")) {
      String clean = val.replaceAll("[^0-9\\.\\-]", "");
      if (clean.length() > 0) {
        nivelParticulas1 = float(clean);
        if (nivelParticulas1 > 1000) {
          incendioTimestamps[0] = millis();
          println("ALERTA INCENDIO 1: " + nivelParticulas1 + " ppm");
        }
      }
    } 
    else if (key.equals("PM2")) {
      String clean = val.replaceAll("[^0-9\\.\\-]", "");
      if (clean.length() > 0) {
        nivelParticulas2 = float(clean);
        if (nivelParticulas2 > 1000) {
          incendioTimestamps[1] = millis();
          println("ALERTA INCENDIO 2: " + nivelParticulas2 + " ppm");
        }
      }
    }

    // INCENDIOS (compatibilidad)
    else if (key.equals("INC1")) {
      if (val.equals("1")) {
        incendioTimestamps[0] = millis();
        println("ALERTA INCENDIO 1 activada");
      }
    }
    else if (key.equals("INC2")) {
      if (val.equals("1")) {
        incendioTimestamps[1] = millis();
        println("ALERTA INCENDIO 2 activada");
      }
    }

    // PANICO - pueden llegar individualmente
    else if (key.equals("PANICO1")) {
      if (val.equals("1")) {
        panicoTimestamps[0] = millis();
        println("PANICO 1 activado");
      }
    }
    else if (key.equals("PANICO2")) {
      if (val.equals("1")) {
        panicoTimestamps[1] = millis();
        println("PANICO 2 activado");
      }
    }
    else if (key.equals("PANICO3")) {
      if (val.equals("1")) {
        panicoTimestamps[2] = millis();
        println("PANICO 3 activado");
      }
    }
    else if (key.equals("PANICO4")) {
      if (val.equals("1")) {
        panicoTimestamps[3] = millis();
        println("PANICO 4 activado");
      }
    }
    else if (key.equals("PANICO5")) {
      if (val.equals("1")) {
        panicoTimestamps[4] = millis();
        println("PANICO 5 activado");
      }
    }

    // SISMO
    else if (key.equals("SISMO")) {
      if (val.equals("1")) {
        lastSismoTimestamp = millis();
        println("SISMO detectado");
      }
    }

    // INFRACCIONES - pueden llegar individualmente
    else if (key.equals("INFRAA")) {
      if (val.equals("1")) {
        semaforoInfraccionTimestamps[0] = millis();
        println("INFRACCION A activada");
      }
    }
    else if (key.equals("INFRAB")) {
      if (val.equals("1")) {
        semaforoInfraccionTimestamps[1] = millis();
        println("INFRACCION B activada");
      }
    }
    else if (key.equals("INFRAC")) {
      if (val.equals("1")) {
        semaforoInfraccionTimestamps[2] = millis();
        println("INFRACCION C activada");
      }
    }
    else if (key.equals("INFRAD")) {
      if (val.equals("1")) {
        semaforoInfraccionTimestamps[3] = millis();
        println("INFRACCION D activada");
      }
    }
    
    // Si llega algo no reconocido, simplemente lo ignoramos
    else {
      println("Campo desconocido ignorado: " + key + "=" + val);
    }
  }
}

// Procesa BUSx como distancia 0..MAX que cicla 0->MAX->0
void procesarBusComoDistancia(int busId, float newDist) {
  newDist = constrain(newDist, 0, MAX_BUS);

  if (busId == 1) {
    if (prevDistBus1 >= 0 && newDist < prevDistBus1 - 1.0) {
      halfIndexBus1 = (halfIndexBus1 + 1) & 1;
    }
    distanciaParada1 = newDist;
    prevDistBus1 = newDist;
    progresoBus1 = (halfIndexBus1 * 0.5) + ((MAX_BUS > 0 ? newDist / MAX_BUS : 0) * 0.5);
  } else {
    if (prevDistBus2 >= 0 && newDist < prevDistBus2 - 1.0) {
      halfIndexBus2 = (halfIndexBus2 + 1) & 1;
    }
    distanciaParada2 = newDist;
    prevDistBus2 = newDist;
    progresoBus2 = (halfIndexBus2 * 0.5) + ((MAX_BUS > 0 ? newDist / MAX_BUS : 0) * 0.5);
  }
}
