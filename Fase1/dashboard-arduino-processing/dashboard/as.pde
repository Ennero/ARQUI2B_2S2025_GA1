import processing.serial.*;

// ====== Comunicación Serial ======
Serial myPort; 
String datosSerial = "";

// ====== Variables de simulación ======
// Semáforos (4 semáforos con 2 caras cada uno)
boolean semaforoInfraccion1 = false;
boolean semaforoInfraccion2 = false;
boolean semaforoInfraccion3 = false;
boolean semaforoInfraccion4 = false;

// Estados de las dos caras principales que controlan todos los semáforos
String estadoSem1 = "VERDE"; // Controla cara 1 de todos los semáforos
String estadoSem2 = "ROJO";  // Controla cara 2 de todos los semáforos

// Sensores de incendio (2 sensores)
boolean incendio1 = false;
boolean incendio2 = false;

String alertaExtra = "Sin alertas";

// ====== Variables para dos buses ======
// Bus 1 (Ruta Azul)
float distanciaParada1 = 300;
float progresoBus1 = 0; // 0-1 para completar el circuito cuadrado

// Bus 2 (Ruta Roja)
float distanciaParada2 = 150;
float progresoBus2 = 0.5; // Inicia en la mitad del circuito

// ====== Control de simulación ======
float velocidadBus = 0.005; // Velocidad de movimiento de los buses

boolean panico = false;
boolean sismo = false;

// Variables para efectos visuales
float pulsoAlerta = 0;
int tiempoUltimaInfraccion = 0;
String ultimaInfraccionSemaforo = "";

void setup() {
  size(1200, 750); // Aumenté altura para el título
  //surface.setTitle("Dashboard IoT - Sistema de Monitoreo Urbano");

  // ====== Configuración Serial ======
  /*
  println(Serial.list()[0]);
  String portName = Serial.list()[0]; // Cambiar índice si es necesario
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  */
}

void draw() {
  // Fondo con gradiente
  dibujarFondoGradiente();

  pulsoAlerta += 0.1;

  // === Título Principal ===
  dibujarTitulo();

  // === Panel Estado de Semáforos ===
  dibujarSemaforos(30, 80, 540, 200); // Ajusté posición Y y altura

  // === Panel Monitor de Incendios ===
  dibujarMonitorIncendios(600, 80, 540, 200); // Ajusté posición Y y altura

  // === Panel Mapa de Rutas de Buses ===
  dibujarMapaBuses(30, 310, 820, 350); // Ajusté posición Y

  // === Panel de Alertas ===
  dibujarAlertas(880, 310, 260, 350); // Ajusté posición Y

  // === Barra de estado inferior ===
  dibujarBarraEstado();
  
  // Simulación para testing (comentar cuando uses serial real)
  simularDatos();
}

// ====== Función para dibujar título principal ======
void dibujarTitulo() {
  // Fondo del título con gradiente
  for (int i = 0; i < 60; i++) {
    float alpha = map(i, 0, 60, 100, 0);
    stroke(50, 150, 255, alpha);
    line(0, i, width, i);
  }
  
  // Título principal con efectos
  fill(255, 255, 255);
  textSize(42);
  textAlign(CENTER, CENTER);
  
  // Sombra del texto
  fill(0, 0, 0, 100);
  text("DASHBOARD", width/2 + 3, 33);
  
  // Texto principal con gradiente simulado
  fill(100, 200, 255);
  text("DASHBOARD", width/2, 30);
  
  // Línea decorativa inferior
  stroke(100, 200, 255);
  strokeWeight(4);
  line(width/2 - 150, 55, width/2 + 150, 55);
  
  // Puntos decorativos
  fill(100, 200, 255);
  noStroke();
  ellipse(width/2 - 160, 55, 8, 8);
  ellipse(width/2 + 160, 55, 8, 8);
}

// ====== Función para fondo con gradiente ======
void dibujarFondoGradiente() {
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(color(25, 25, 35), color(45, 45, 60), inter);
    stroke(c);
    line(0, i, width, i);
  }
}

// ====== Funciones de Paneles ======
void dibujarSemaforos(float x, float y, float w, float h) {
  // Panel con bordes redondeados y sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15); // Sombra
  
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  // Título con estilo
  fill(255, 255, 255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE SEMAFOROS", x + 15, y + 15);
  
  // Línea decorativa
  stroke(100, 200, 255);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);

  // Información de sincronización
  fill(150, 200, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Control Sincronizado: SEM1=" + estadoSem1 + " | SEM2=" + estadoSem2, x + 15, y + 55);

  // Dibujar los 4 semáforos en una cuadrícula 2x2
  float semaforoW = (w - 60) / 2;
  float semaforoH = (h - 100) / 2; // Reduje altura para dar espacio a la info
  
  dibujarSemaforoDobleIndividual(x + 15, y + 80, semaforoW, semaforoH, "INTERSECCION A", estadoSem1, estadoSem2, semaforoInfraccion1);
  dibujarSemaforoDobleIndividual(x + 15 + semaforoW + 15, y + 80, semaforoW, semaforoH, "INTERSECCION B", estadoSem1, estadoSem2, semaforoInfraccion2);
  dibujarSemaforoDobleIndividual(x + 15, y + 80 + semaforoH + 15, semaforoW, semaforoH, "INTERSECCION C", estadoSem1, estadoSem2, semaforoInfraccion3);
  dibujarSemaforoDobleIndividual(x + 15 + semaforoW + 15, y + 80 + semaforoH + 15, semaforoW, semaforoH, "INTERSECCION D", estadoSem1, estadoSem2, semaforoInfraccion4);
}

void dibujarSemaforoDobleIndividual(float x, float y, float w, float h, String id, String estadoCara1, String estadoCara2, boolean infraccion) {
  // Fondo del semáforo
  if (infraccion) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);

  // ID del semáforo
  fill(200, 220, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text(id, x + 8, y + 8);

  // Semáforo CARA 1 (izquierda)
  float semaforo1X = x + w - 70;
  float semaforo1Y = y + 8;
  
  // Marco del semáforo cara 1
  fill(20, 20, 25);
  stroke(100);
  strokeWeight(1);
  rect(semaforo1X, semaforo1Y, 25, 65, 5);
  
  // Etiqueta cara 1
  fill(150, 200, 255);
  textSize(10);
  textAlign(CENTER, TOP);
  text("CARA 1", semaforo1X + 12.5, semaforo1Y + 70);
  
  // Luces del semáforo cara 1
  dibujarLucesSemaforo(semaforo1X + 12.5, semaforo1Y, estadoCara1);

  // Semáforo CARA 2 (derecha)
  float semaforo2X = x + w - 35;
  float semaforo2Y = y + 8;
  
  // Marco del semáforo cara 2
  fill(20, 20, 25);
  stroke(100);
  strokeWeight(1);
  rect(semaforo2X, semaforo2Y, 25, 65, 5);
  
  // Etiqueta cara 2
  fill(255, 150, 150);
  textSize(10);
  textAlign(CENTER, TOP);
  text("CARA 2", semaforo2X + 12.5, semaforo2Y + 70);
  
  // Luces del semáforo cara 2
  dibujarLucesSemaforo(semaforo2X + 12.5, semaforo2Y, estadoCara2);

  // Estado y alertas
  fill(255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("C1: " + estadoCara1 + " | C2: " + estadoCara2, x + 8, y + 28);
  
  if (infraccion) {
    fill(255, 100, 100);
    float brillo = 150 + sin(pulsoAlerta) * 50;
    fill(brillo, 50, 50);
    text("INFRACCION", x + 8, y + 45);
  } else {
    fill(100, 255, 100);
    text("Normal", x + 8, y + 45);
  }
}

void dibujarLucesSemaforo(float centerX, float centerY, String estado) {
  // Rojo
  if (estado.equals("ROJO")) {
    fill(255, 50, 50);
  } else {
    fill(50, 20, 20);
  }
  ellipse(centerX, centerY + 12, 15, 15);
  
  // Amarillo
  if (estado.equals("AMARILLO")) {
    fill(255, 255, 50);
  } else {
    fill(50, 50, 20);
  }
  ellipse(centerX, centerY + 32, 15, 15);
  
  // Verde
  if (estado.equals("VERDE")) {
    fill(50, 255, 50);
  } else {
    fill(20, 50, 20);
  }
  ellipse(centerX, centerY + 52, 15, 15);
}

void dibujarMonitorIncendios(float x, float y, float w, float h) {
  // Panel con bordes redondeados y sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15); // Sombra
  
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  // Título con estilo
  fill(255, 255, 255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE DETECCION DE INCENDIOS", x + 15, y + 15);
  
  // Línea decorativa
  stroke(255, 150, 50);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);

  // Dibujar los 2 sensores de incendio
  float sensorW = (w - 45) / 2;
  float sensorH = h - 80;
  
  dibujarSensorIncendio(x + 15, y + 60, sensorW, sensorH, "INC-01", incendio1);
  dibujarSensorIncendio(x + 15 + sensorW + 15, y + 60, sensorW, sensorH, "INC-02", incendio2);
}

void dibujarSensorIncendio(float x, float y, float w, float h, String id, boolean incendio) {
  // Fondo del sensor
  if (incendio) {
    fill(80, 30, 20);
    stroke(255, 150, 100);
  } else {
    fill(30, 35, 40);
    stroke(60, 70, 80);
  }
  strokeWeight(1);
  rect(x, y, w, h, 8);

  // ID del sensor
  fill(200, 220, 255);
  textSize(16);
  textAlign(CENTER, TOP);
  text(id, x + w/2, y + 10);

  // Icono del sensor
  float iconX = x + w/2;
  float iconY = y + 45;
  
  if (incendio) {
    // Llamas animadas
    fill(255, 100 + sin(pulsoAlerta * 2) * 50, 0);
    noStroke();
    ellipse(iconX, iconY, 40, 40);
    
    fill(255, 150 + sin(pulsoAlerta * 3) * 50, 0);
    ellipse(iconX - 5, iconY - 5, 30, 30);
    ellipse(iconX + 5, iconY - 5, 30, 30);
    
    // Estado
    fill(255, 150, 150);
    textSize(14);
    textAlign(CENTER, TOP);
    text("INCENDIO", iconX, iconY + 25);
    text("DETECTADO", iconX, iconY + 42);
  } else {
    // Sensor normal
    fill(100, 100, 100);
    stroke(150);
    strokeWeight(2);
    ellipse(iconX, iconY, 30, 30);
    fill(50, 150, 50);
    noStroke();
    ellipse(iconX, iconY, 20, 20);
    
    // Estado
    fill(150, 255, 150);
    textSize(14);
    textAlign(CENTER, TOP);
    text("NORMAL", iconX, iconY + 25);
  }
}

void dibujarMapaBuses(float x, float y, float w, float h) {
  // Panel con bordes redondeados y sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15); // Sombra
  
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  // Título con estilo
  fill(255, 255, 255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("SISTEMA DE TRANSPORTE PUBLICO", x + 15, y + 15);
  
  // Línea decorativa
  stroke(100, 255, 150);
  strokeWeight(3);
  line(x + 15, y + 45, x + w - 15, y + 45);

  // Dimensiones de las rutas cuadradas
  float rutaSize = 140;
  
  // === RUTA 1 (Azul) ===
  float ruta1X = x + 60;
  float ruta1Y = y + 80;
  
  // Dibujar ruta cuadrada 1 con efectos
  stroke(50, 150, 255);
  strokeWeight(6);
  noFill();
  rect(ruta1X, ruta1Y, rutaSize, rutaSize, 10);
  
  // Efecto de brillo en la ruta
  stroke(100, 200, 255, 100);
  strokeWeight(10);
  rect(ruta1X, ruta1Y, rutaSize, rutaSize, 10);
  
  // Calcular posición del Bus 1
  PVector posBus1 = calcularPosicionEnRuta(ruta1X, ruta1Y, rutaSize, progresoBus1);
  
  // Dibujar Bus 1 con efectos
  // Sombra del bus
  fill(0, 0, 0, 100);
  noStroke();
  ellipse(posBus1.x + 2, posBus1.y + 2, 20, 20);
  // Bus
  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(posBus1.x, posBus1.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("1", posBus1.x, posBus1.y);
  
  // Etiquetas Ruta 1
  fill(100, 200, 255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA AZUL", ruta1X, ruta1Y - 25);
  fill(200, 220, 255);
  textSize(12);
  text("Distancia a parada: " + nf(distanciaParada1, 1, 0) + "m", ruta1X, ruta1Y + rutaSize + 20);

  // === RUTA 2 (Roja) ===
  float ruta2X = x + 350;
  float ruta2Y = y + 80;
  
  // Dibujar ruta cuadrada 2 con efectos
  stroke(255, 100, 100);
  strokeWeight(6);
  noFill();
  rect(ruta2X, ruta2Y, rutaSize, rutaSize, 10);
  
  // Efecto de brillo en la ruta
  stroke(255, 150, 150, 100);
  strokeWeight(10);
  rect(ruta2X, ruta2Y, rutaSize, rutaSize, 10);
  
  // Calcular posición del Bus 2
  PVector posBus2 = calcularPosicionEnRuta(ruta2X, ruta2Y, rutaSize, progresoBus2);
  
  // Dibujar Bus 2 con efectos
  // Sombra del bus
  fill(0, 0, 0, 100);
  noStroke();
  ellipse(posBus2.x + 2, posBus2.y + 2, 20, 20);
  // Bus
  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(posBus2.x, posBus2.y, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("2", posBus2.x, posBus2.y);
  
  // Etiquetas Ruta 2
  fill(255, 150, 150);
  textSize(16);
  textAlign(LEFT, TOP);
  text("RUTA ROJA", ruta2X, ruta2Y - 25);
  fill(255, 200, 200);
  textSize(12);
  text("Distancia a parada: " + nf(distanciaParada2, 1, 0) + "m", ruta2X, ruta2Y + rutaSize + 20);

  // === PARADAS ===
  // Paradas en las esquinas con efectos
  fill(255, 255, 100);
  stroke(255, 255, 200);
  strokeWeight(2);
  
  // Paradas Ruta 1
  ellipse(ruta1X, ruta1Y, 12, 12); // esquina superior izquierda
  ellipse(ruta1X + rutaSize, ruta1Y, 12, 12); // esquina superior derecha
  ellipse(ruta1X + rutaSize, ruta1Y + rutaSize, 12, 12); // esquina inferior derecha
  ellipse(ruta1X, ruta1Y + rutaSize, 12, 12); // esquina inferior izquierda
  
  // Paradas Ruta 2
  ellipse(ruta2X, ruta2Y, 12, 12);
  ellipse(ruta2X + rutaSize, ruta2Y, 12, 12);
  ellipse(ruta2X + rutaSize, ruta2Y + rutaSize, 12, 12);
  ellipse(ruta2X, ruta2Y + rutaSize, 12, 12);

  // === LEYENDA ===
  float leyendaX = x + 580;
  float leyendaY = y + 80;
  
  fill(30, 35, 40);
  stroke(60, 70, 80);
  strokeWeight(1);
  rect(leyendaX, leyendaY, 180, 160, 8);
  
  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("LEYENDA", leyendaX + 10, leyendaY + 10);
  
  // Parada
  fill(255, 255, 100);
  stroke(255, 255, 200);
  strokeWeight(2);
  ellipse(leyendaX + 20, leyendaY + 40, 12, 12);
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Parada de Bus", leyendaX + 35, leyendaY + 35);
  
  // Bus Azul
  fill(50, 150, 255);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 20, leyendaY + 65, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("1", leyendaX + 20, leyendaY + 65);
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Bus Ruta Azul", leyendaX + 35, leyendaY + 60);
  
  // Bus Rojo
  fill(255, 100, 100);
  stroke(255);
  strokeWeight(2);
  ellipse(leyendaX + 20, leyendaY + 90, 18, 18);
  fill(255);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("2", leyendaX + 20, leyendaY + 90);
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Bus Ruta Roja", leyendaX + 35, leyendaY + 85);
  
  // Estado del sistema
  fill(100, 255, 100);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Sistema Operativo", leyendaX + 10, leyendaY + 120);
  fill(150, 200, 255);
  text("Buses en circulacion: 2", leyendaX + 10, leyendaY + 135);
}

// Función para calcular la posición de un bus en una ruta cuadrada
PVector calcularPosicionEnRuta(float x, float y, float tamaño, float progreso) {
  PVector pos = new PVector();
  
  // El progreso va de 0 a 1, dividimos en 4 lados
  float progresoLado = (progreso * 4) % 1.0;
  int lado = (int)(progreso * 4) % 4;
  
  switch(lado) {
    case 0: // Lado superior (izquierda a derecha)
      pos.x = x + progresoLado * tamaño;
      pos.y = y;
      break;
    case 1: // Lado derecho (arriba a abajo)
      pos.x = x + tamaño;
      pos.y = y + progresoLado * tamaño;
      break;
    case 2: // Lado inferior (derecha a izquierda)
      pos.x = x + tamaño - progresoLado * tamaño;
      pos.y = y + tamaño;
      break;
    case 3: // Lado izquierdo (abajo a arriba)
      pos.x = x;
      pos.y = y + tamaño - progresoLado * tamaño;
      break;
  }
  
  return pos;
}

void dibujarAlertas(float x, float y, float w, float h) {
  // Panel con bordes redondeados y sombra
  fill(0, 0, 0, 50);
  rect(x + 5, y + 5, w, h, 15); // Sombra
  
  fill(40, 45, 55);
  stroke(80, 90, 110);
  strokeWeight(2);
  rect(x, y, w, h, 15);

  // Título con estilo
  fill(255, 255, 255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("ALERTAS", x + 15, y + 15);
  
  // Línea decorativa
  stroke(255, 200, 100);
  strokeWeight(3);
  line(x + 15, y + 40, x + w - 15, y + 40);

  float alertaY = y + 60;
  
  // Alerta de sismo
  if (sismo) {
    fill(80, 20, 20);
    stroke(255, 100, 100);
    strokeWeight(2);
    rect(x + 10, alertaY, w - 20, 80, 8);
    
    float brillo = 200 + sin(pulsoAlerta * 2) * 55;
    fill(brillo, 100, 100);
    textSize(16);
    textAlign(CENTER, TOP);
    text("SISMO DETECTADO", x + w/2, alertaY + 15);
    
    fill(255, 200, 200);
    textSize(12);
    text("Activar protocolo de", x + w/2, alertaY + 35);
    text("emergencia sismica", x + w/2, alertaY + 50);
    
    alertaY += 100;
  }
  
  // Alerta de pánico
  if (panico) {
    fill(80, 60, 20);
    stroke(255, 200, 100);
    strokeWeight(2);
    rect(x + 10, alertaY, w - 20, 80, 8);
    
    float brillo = 200 + sin(pulsoAlerta * 3) * 55;
    fill(brillo, brillo * 0.8, 0);
    textSize(16);
    textAlign(CENTER, TOP);
    text("BOTON DE PANICO", x + w/2, alertaY + 15);
    
    fill(255, 220, 150);
    textSize(12);
    text("Solicitud de ayuda", x + w/2, alertaY + 35);
    text("de emergencia", x + w/2, alertaY + 50);
    
    alertaY += 100;
  }
  
  // Si no hay alertas activas
  if (!sismo && !panico) {
    fill(30, 60, 30);
    stroke(100, 200, 100);
    strokeWeight(1);
    rect(x + 10, alertaY, w - 20, 60, 8);
    
    fill(150, 255, 150);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Sistema Normal", x + w/2, alertaY + 30);
  }
  
  // Información de estado del sistema
  fill(200, 220, 255);
  textSize(10);
  textAlign(LEFT, BOTTOM);
  text("Ultima actualizacion:", x + 10, y + h - 25);
  text(nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), x + 10, y + h - 10);
}

void dibujarBarraEstado() {
  // Barra inferior de estado
  fill(30, 35, 40);
  stroke(60, 70, 80);
  strokeWeight(1);
  rect(0, height - 40, width, 40);
  
  fill(200, 220, 255);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("Sistema Conectado  |  Recibiendo datos  |  " + 
       nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2), 
       15, height - 20);
       
  textAlign(RIGHT, CENTER);
  text("Dashboard IoT v2.0", width - 15, height - 20);
}

// ====== Simulación de datos para testing ======
void simularDatos() {
  // Simular cambios de semáforos cada cierto tiempo (solo SEM1 y SEM2)
  if (frameCount % 180 == 0) { // Cada 3 segundos aprox
    String[] estados = {"ROJO", "AMARILLO", "VERDE"};
    estadoSem1 = estados[(int)random(0, 3)];
    estadoSem2 = estados[(int)random(0, 3)];
    
    // Lógica para evitar que ambas caras estén en verde al mismo tiempo
    if (estadoSem1.equals("VERDE") && estadoSem2.equals("VERDE")) {
      estadoSem2 = "ROJO";
    }
  }
  
  // Simular infracciones (más probable cuando hay conflicto de luces)
  if (frameCount % 300 == 0) { // Cada 5 segundos aprox
    semaforoInfraccion1 = (estadoSem1.equals("ROJO") && random(1) > 0.7);
    semaforoInfraccion2 = (estadoSem2.equals("ROJO") && random(1) > 0.8);
    semaforoInfraccion3 = (estadoSem1.equals("ROJO") && random(1) > 0.8);
    semaforoInfraccion4 = (estadoSem2.equals("ROJO") && random(1) > 0.7);
  }

  // Simular incendios (eventos raros)
  if (frameCount % 600 == 0) { // Cada 10 segundos aprox
    incendio1 = random(1) > 0.95; // 5% probabilidad
    incendio2 = random(1) > 0.97; // 3% probabilidad
  }

  // Simular movimiento de buses
  progresoBus1 += velocidadBus;
  if (progresoBus1 >= 1.0) progresoBus1 = 0.0;
  
  progresoBus2 += velocidadBus * 0.8; // Bus 2 va un poco más lento
  if (progresoBus2 >= 1.0) progresoBus2 = 0.0;

  // Actualizar distancias basadas en progreso
  distanciaParada1 = (abs((progresoBus1 * 4) % 1.0 - 0.5) * 200);
  distanciaParada2 = (abs((progresoBus2 * 4) % 1.0 - 0.5) * 200);

  // Simular alertas de emergencia (eventos muy raros)
  if (frameCount % 900 == 0) { // Cada 15 segundos aprox
    sismo = random(1) > 0.98; // 2% probabilidad
    panico = random(1) > 0.97; // 3% probabilidad
  }
}

// ====== Lectura Serial ======
void serialEvent(Serial myPort) {
  datosSerial = myPort.readStringUntil('\n');
  if (datosSerial != null) {
    datosSerial = trim(datosSerial);
    println("Recibido: " + datosSerial); // Para debug

    String[] partes = split(datosSerial, ';');
    for (String parte : partes) {
      String[] kv = split(parte, '=');
      if (kv.length == 2) {
        String key = kv[0];
        String val = kv[1];

        // Estados de semáforos principales (solo SEM1 y SEM2)
        if (key.equals("SEM1")) {
          estadoSem1 = val; // Controla cara 1 de todos los semáforos
        } else if (key.equals("SEM2")) {
          estadoSem2 = val; // Controla cara 2 de todos los semáforos
        }
        
        // Infracciones de semáforos individuales
        else if (key.equals("INFRACCION1")) {
          semaforoInfraccion1 = val.equals("1");
        } else if (key.equals("INFRACCION2")) {
          semaforoInfraccion2 = val.equals("1");
        } else if (key.equals("INFRACCION3")) {
          semaforoInfraccion3 = val.equals("1");
        } else if (key.equals("INFRACCION4")) {
          semaforoInfraccion4 = val.equals("1");
        }
        
        // Buses
        else if (key.equals("BUS1")) {
          distanciaParada1 = float(val);
          progresoBus1 = map(distanciaParada1, 100, 0, 0.0, 1.0);
        } else if (key.equals("BUS2")) {
          distanciaParada2 = float(val);
          progresoBus2 = map(distanciaParada2, 100, 0, 0.0, 1.0);
        }
        
        // Sensores de incendio
        else if (key.equals("INC1")) {
          incendio1 = val.equals("1");
        } else if (key.equals("INC2")) {
          incendio2 = val.equals("1");
        }
        
        // Alertas
        else if (key.equals("PANICO")) {
          panico = val.equals("1");
        } else if (key.equals("SISMO")) {
          sismo = val.equals("1");
        }
      }
    }
  }
}
