#include <Wire.h>

#define NUM_SENSORES 14
const uint8_t pinesSensores[NUM_SENSORES] = {
    2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, A0, A1
};

uint16_t estadosSensores = 0;

void setup() {
    Wire.begin(9); // Esclavo dirección 9
    Wire.onRequest(requestEvent);

    for (int i = 0; i < NUM_SENSORES; i++) {
        pinMode(pinesSensores[i], INPUT);
    }
}

void loop() {
    estadosSensores = 0;
    for (int i = 0; i < NUM_SENSORES; i++) {
        if (digitalRead(pinesSensores[i]) == HIGH) {
        estadosSensores |= (1 << i);
        }
    }
    delay(100);
}

void requestEvent() {
    Wire.write(estadosSensores & 0xFF);
    Wire.write((estadosSensores >> 8) & 0xFF);
}
