#include "Semaforo.h"
#include <Arduino.h>

Semaforo::Semaforo(int r, int a, int v, char inicial) {
    pinRojo = r;
    pinAmarillo = a;
    pinVerde = v;
    estado = inicial;
}

void Semaforo::init() {
    pinMode(pinRojo, OUTPUT);
    pinMode(pinAmarillo, OUTPUT);
    pinMode(pinVerde, OUTPUT);
    actualizar();
}

void Semaforo::cambiarEstado() {
    switch (estado) {
        case 'R': estado = 'A'; break;
        case 'A': estado = 'V'; break;
        case 'V': estado = 'R'; break;
    }
}

void Semaforo::actualizar() {
    digitalWrite(pinRojo, estado == 'R' ? HIGH : LOW);
    digitalWrite(pinAmarillo, estado == 'A' ? HIGH : LOW);
    digitalWrite(pinVerde, estado == 'V' ? HIGH : LOW);
}

char Semaforo::getEstado() {
    return estado;
}

void Semaforo::setEstado(char nuevoEstado) {
    estado = nuevoEstado;
    actualizar();
}
