#ifndef SEMAFORO_H
#define SEMAFORO_H

class Semaforo {
    private:
        int pinRojo, pinAmarillo, pinVerde;
        char estado;

    public:
        Semaforo(int r, int a, int v, char inicial);
        void init();
        void cambiarEstado();
        void actualizar();
        char getEstado();
        void setEstado(char nuevoEstado);
};

#endif
