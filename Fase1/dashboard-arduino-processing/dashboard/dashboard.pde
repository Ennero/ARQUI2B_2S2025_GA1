import processing.serial.*;

// ====== Comunicación Serial ======
Serial myPort; 
String datosSerial = "";

// ====== Variables de simulación ======
boolean semaforoInfraccion = false;
float nivelHumo = 50; // valor inicial MQ-02
float umbralHumo = 150;
String alertaExtra = "Sin alertas";

// ====== Variables para dos buses ======
// Bus 1 (Ruta Azul)
float distanciaParada1 = 300;
float progresoBus1 = 0; // 0-1 para completar el circuito cuadrado

// Bus 2 (Ruta Roja)
float distanciaParada2 = 150;
float progresoBus2 = 0.5; // Inicia en la mitad del circuito

// ====== Control de simulación ======
float humoIncremento = 0.5;
boolean humoSubiendo = true;
float velocidadBus = 0.005; // Velocidad de movimiento de los buses

boolean panico = false;
boolean sismo = false;
boolean infraccion = false;

void setup() {
  size(1000, 650);
  surface.setTitle("Dashboard - Proyecto IoT - Dos Rutas");

  // ====== Configuración Serial (comentada por ahora) ======
  
  println(Serial.list()[0]);
  String portName = Serial.list()[0]; // Cambiar índice si es necesario
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(230);

  // === Panel Estado de Semáforos ===
  dibujarSemaforos(20, 20, 380, 120);

  // === Panel Monitor de Incendios ===
  dibujarMonitorIncendios(420, 20, 380, 120);

  // === Panel Mapa de Rutas de Buses ===
  dibujarMapaBuses(20, 160, 760, 300);

  // === Panel de Alertas ===
  dibujarAlertas(800, 20, 180, 440);

  // === Simulación temporal de datos ===
 // simularDatos();
}

// ====== Funciones de Paneles ======
void dibujarSemaforos(float x, float y, float w, float h) {
  fill(50);
  rect(x, y, w, h, 10);

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Estado de Semaforos", x + 10, y + 10);

  // Estado gráfico
  if (semaforoInfraccion) {
    fill(255, 0, 0);
    text("Infraccion detectada", x + 10, y + 40);
  } else {
    fill(0, 200, 0);
    text("Todo en orden", x + 10, y + 40);
  }
}

void dibujarMonitorIncendios(float x, float y, float w, float h) {
  fill(50);
  rect(x, y, w, h, 10);

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Monitor de Incendios (MQ-02)", x + 10, y + 10);

  // Barra de fondo
  fill(100);
  rect(x + 20, y + 40, 30, h - 60);

  // Barra de humo
  float barraAltura = map(nivelHumo, 0, 300, 0, h - 60);
  if (nivelHumo >= umbralHumo) {
    fill(255, 0, 0);
  } else {
    fill(0, 200, 0);
  }
  rect(x + 20, y + h - 20 - barraAltura, 30, barraAltura);
  
  // Valor actual
  fill(255);
  textSize(12);
  text(nf(nivelHumo, 1, 1) + " ppm", x + 60, y + h/2);
  
  // Estado
  if (nivelHumo >= umbralHumo) {
    fill(255, 100, 100);
    text("ALERTA", x + 60, y + h/2 + 15);
  } else {
    fill(100, 255, 100);
    text("NORMAL", x + 60, y + h/2 + 15);
  }
}

void dibujarMapaBuses(float x, float y, float w, float h) {
  fill(50);
  rect(x, y, w, h, 10);

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Mapa de Rutas de Buses", x + 10, y + 10);

  // Dimensiones de las rutas cuadradas
  float rutaSize = 120;
  
  // === RUTA 1 (Azul) ===
  float ruta1X = x + 50;
  float ruta1Y = y + 50;
  
  // Dibujar ruta cuadrada 1
  stroke(0, 100, 255);
  strokeWeight(4);
  noFill();
  rect(ruta1X, ruta1Y, rutaSize, rutaSize);
  
  // Calcular posición del Bus 1
  PVector posBus1 = calcularPosicionEnRuta(ruta1X, ruta1Y, rutaSize, progresoBus1);
  
  // Dibujar Bus 1
  fill(0, 100, 255);
  noStroke();
  ellipse(posBus1.x, posBus1.y, 15, 15);
  
  // Etiquetas Ruta 1
  fill(0, 100, 255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Ruta Azul", ruta1X, ruta1Y - 5);
  fill(255);
  textSize(11);
  text("Distancia: " + nf(distanciaParada1, 1, 0) + "m", ruta1X, ruta1Y + rutaSize + 15);

  // === RUTA 2 (Roja) ===
  float ruta2X = x + 250;
  float ruta2Y = y + 50;
  
  // Dibujar ruta cuadrada 2
  stroke(255, 50, 50);
  strokeWeight(4);
  noFill();
  rect(ruta2X, ruta2Y, rutaSize, rutaSize);
  
  // Calcular posición del Bus 2
  PVector posBus2 = calcularPosicionEnRuta(ruta2X, ruta2Y, rutaSize, progresoBus2);
  
  // Dibujar Bus 2
  fill(255, 50, 50);
  noStroke();
  ellipse(posBus2.x, posBus2.y, 15, 15);
  
  // Etiquetas Ruta 2
  fill(255, 50, 50);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Ruta Roja", ruta2X, ruta2Y - 5);
  fill(255);
  textSize(11);
  text("Distancia: " + nf(distanciaParada2, 1, 0) + "m", ruta2X, ruta2Y + rutaSize + 15);

  // === PARADAS ===
  // Paradas en las esquinas
  fill(255, 255, 0);
  stroke(0);
  strokeWeight(2);
  
  // Paradas Ruta 1
  ellipse(ruta1X, ruta1Y, 8, 8); // esquina superior izquierda
  ellipse(ruta1X + rutaSize, ruta1Y, 8, 8); // esquina superior derecha
  ellipse(ruta1X + rutaSize, ruta1Y + rutaSize, 8, 8); // esquina inferior derecha
  ellipse(ruta1X, ruta1Y + rutaSize, 8, 8); // esquina inferior izquierda
  
  // Paradas Ruta 2
  ellipse(ruta2X, ruta2Y, 8, 8);
  ellipse(ruta2X + rutaSize, ruta2Y, 8, 8);
  ellipse(ruta2X + rutaSize, ruta2Y + rutaSize, 8, 8);
  ellipse(ruta2X, ruta2Y + rutaSize, 8, 8);

  // === INFORMACIÓN ADICIONAL ===
  noStroke();
  fill(255);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Paradas de Bus", x + 450, y + 50);
  
  fill(0, 100, 255);
  ellipse(x + 430, y + 70, 15, 15);
  fill(255);
  text("Bus Ruta Azul", x + 450, y + 75);
  
  fill(255, 50, 50);
  ellipse(x + 430, y + 90, 15, 15);
  fill(255);
  text("Bus Ruta Roja", x + 450, y + 95);
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
  fill(50);
  rect(x, y, w, h, 10);

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Alertas", x + 10, y + 10);

  fill(255);
  textSize(12);
  text(alertaExtra, x + 10, y + 40);
  
  // Mostrar estado de humo como alerta
  if (nivelHumo >= umbralHumo) {
    fill(255, 100, 100);
    text("HUMO DETECTADO", x + 10, y + 70);
    text("Nivel: " + nf(nivelHumo, 1, 1) + " ppm", x + 10, y + 85);
  }
  
  // Mostrar infracciones como alerta
  if (semaforoInfraccion) {
    fill(255, 200, 100);
    text("INFRACCION", x + 10, y + 110);
    text("Semaforo violado", x + 10, y + 125);
  }
}

// ====== Lectura Serial (comentada por ahora) ======
/*
void serialEvent(Serial myPort) {
  datosSerial = myPort.readStringUntil('\n');
  if (datosSerial != null) {
    datosSerial = trim(datosSerial);
    String[] valores = split(datosSerial, ',');
    if (valores.length >= 6) {
      semaforoInfraccion = valores[0].equals("1");
      nivelHumo = float(valores[1]);
      distanciaParada1 = float(valores[2]);
      distanciaParada2 = float(valores[3]);
      progresoBus1 = float(valores[4]) / 100.0; // Esperamos un valor 0-100
      progresoBus2 = float(valores[5]) / 100.0; // Esperamos un valor 0-100
      if (valores.length > 6) {
        alertaExtra = valores[6];
      }
    }
  }
}
*/

// ====== Simulación de datos ======
/*void simularDatos() {
  // Simular infracción aleatoria
  if (frameCount % 300 == 0) {
    semaforoInfraccion = random(1) > 0.7;
  }

  // Simular niveles de humo
  if (humoSubiendo) {
    nivelHumo += humoIncremento;
    if (nivelHumo > 250) humoSubiendo = false;
  } else {
    nivelHumo -= humoIncremento;
    if (nivelHumo < 20) humoSubiendo = true;
  }

  // Simular movimiento de buses en rutas cuadradas
  progresoBus1 += velocidadBus;
  if (progresoBus1 >= 1.0) progresoBus1 = 0.0;
  
  progresoBus2 += velocidadBus * 0.8; // Bus 2 va un poco más lento
  if (progresoBus2 >= 1.0) progresoBus2 = 0.0;

  // Simular distancia a parada basada en el progreso
  float distanciaMinima1 = abs((progresoBus1 * 4) % 1.0 - 0.5) * 400;
  float distanciaMinima2 = abs((progresoBus2 * 4) % 1.0 - 0.5) * 400;
  
  distanciaParada1 = distanciaMinima1;
  distanciaParada2 = distanciaMinima2;

  // Simular alertas extra
  if (frameCount % 600 == 0) {
    float r = random(1);
    if (r > 0.8) alertaExtra = "Sismo detectado";
    else if (r > 0.6) alertaExtra = "Boton de panico";
    else if (r > 0.4) alertaExtra = "Trabajo en via";
    else alertaExtra = "Sin alertas";
  }
}*/

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

        if (key.equals("SEM1")) {
          semaforoInfraccion = val.equals("ROJO"); // si es ROJO, permitir evaluar infracción
        } else if (key.equals("BUS1")) {
          distanciaParada1 = float(val);
          progresoBus1 = map(distanciaParada1, 100, 0, 0.0, 1.0); // cuanto más cerca, más avanza
        } else if (key.equals("BUS2")) {
          distanciaParada2 = float(val);
          progresoBus2 = map(distanciaParada2, 100, 0, 0.0, 1.0);
        } else if (key.equals("INC1")) {
          nivelHumo = float(val);
        } else if (key.equals("PANICO")) {
          panico = val.equals("1");
        } else if (key.equals("SISMO")) {
          sismo = val.equals("1");
        } else if (key.equals("INFRACCION")) {
          infraccion = val.equals("1");
        }
      }
    }

    // Opcional: actualizar alertaExtra con prioridades
    if (sismo) alertaExtra = "Sismo detectado";
    else if (panico) alertaExtra = "Botón de pánico";
    else if (infraccion) alertaExtra = "Infracción de semáforo";
    else if (nivelHumo > umbralHumo) alertaExtra = "Incendio detectado";
    else alertaExtra = "Sin alertas";
  }
}
