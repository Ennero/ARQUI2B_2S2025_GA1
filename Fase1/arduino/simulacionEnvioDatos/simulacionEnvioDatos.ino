void setup() {
  Serial.begin(9600);
}

void loop() {
  // Simulamos los datos que normalmente leerías de sensores
  String estadoSemaforo = "ROJO"; // o VERDE, AMARILLO
  int distanciaBus = random(0, 100);  // Simula la distancia a la parada
  int nivelHumo = random(0, 300);     // Simula niveles del MQ-2
  int panico = random(0, 2);          // 0 o 1
  int sismo = random(0, 2);           // 0 o 1
  int infraccion = random(0, 2);      // 0 o 1

  // Enviamos los datos con el mismo formato que espera Processing
  Serial.print("SEM1=");
  Serial.print(estadoSemaforo);
  Serial.print(";BUS1=");
  Serial.print(distanciaBus);
  Serial.print(";INC1=");
  Serial.print(nivelHumo);
  Serial.print(";PANICO=");
  Serial.print(panico);
  Serial.print(";SISMO=");
  Serial.print(sismo);
  Serial.print(";INFRACCION=");
  Serial.print(infraccion);
  Serial.println();

  delay(1000); // Cada segundo
}
