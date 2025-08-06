#include <Wire.h>
#include "Semaforo.h"

Semaforo semaforos[5] = {
    Semaforo(2, 3, 4, 'R'),
    Semaforo(5, 6, 7, 'A'),
    Semaforo(8, 9, 10, 'V'),
    Semaforo(11, 12, 13, 'R'),
    Semaforo(A0, A1, A2, 'V')
};

void setup() {
    Wire.begin(8); // Esclavo dirección 8
    Wire.onRequest(requestEvent);

    for (int i = 0; i < 5; i++) semaforos[i].init();
}

void loop() {
    for (int i = 0; i < 5; i++) {
        semaforos[i].cambiarEstado();
        semaforos[i].actualizar();
    }
    delay(3000);
}

void requestEvent() {
    char estados[5];
    for (int i = 0; i < 5; i++) {
        estados[i] = semaforos[i].getEstado();
    }
    Wire.write(estados, 5);
}
