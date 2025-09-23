#include <Wire.h>

char estadosSemaforos[5];
uint16_t estadosSensores = 0;

void setup() {
    Wire.begin(); // Maestro
    Serial.begin(9600);
}

void loop() {
    // Obtener estados de los semáforos (esclavo 8)
    Wire.requestFrom(8, 5);
    for (int i = 0; i < 5 && Wire.available(); i++) {
        estadosSemaforos[i] = Wire.read();
    }

    // Obtener estados de los sensores (esclavo 9)
    Wire.requestFrom(9, 2);
    if (Wire.available() == 2) {
        byte low = Wire.read();
        byte high = Wire.read();
        estadosSensores = (high << 8) | low;
    }

    // Mostrar estados de semáforos
    Serial.println("Semáforos:");
    for (int i = 0; i < 5; i++) {
        Serial.print("S");
        Serial.print(i + 1);
        Serial.print(": ");
        Serial.println(estadosSemaforos[i]);
    }

    // Mostrar estados de sensores
    Serial.println("Sensores:");
    for (int i = 0; i < 14; i++) {
        Serial.print("Sensor ");
        Serial.print(i);
        Serial.print(": ");
        Serial.println((estadosSensores & (1 << i)) ? "MOVIMIENTO" : "Libre");
    }

    Serial.println("----------------------------");
    delay(3000);
}
