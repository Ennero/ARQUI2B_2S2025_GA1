#ifndef MELODIES_H
#define MELODIES_H

#include <Arduino.h>

extern int PANICO[5];

// Enum para identificar las canciones de forma legible.
// ¡Añadimos una para cada buzzer/evento!
enum MelodyID
{
    NO_MELODY = 0,
    SONG_NOKIA,
    SONG_TETRIS,
    SONG_PACMAN,
    SONG_TAKEONME,
    SONG_MARIO
};

// --- FUNCIONES PÚBLICAS ---
// Estas son las únicas funciones que necesitarás llamar desde tu archivo .ino

// Llama a esta función UNA VEZ en tu setup() principal.
void setupMelodies();

// Llama a esta función en CADA ciclo de tu loop() principal.
// Se encarga de gestionar la reproducción de las notas sin usar delay().
void loopMelodies();

// Llama a esta función para empezar a reproducir una canción en un buzzer específico.
// Ejemplo: startMelody(0, SONG_PACMAN);
void startMelody(int buzzerIndex, MelodyID song);

// Llama a esta función para detener el sonido en un buzzer específico.
void stopMelody(int buzzerIndex);

#endif // MELODIES_H