#ifndef MELODIES_H
#define MELODIES_H

#include <Arduino.h>

extern int PANICO[5];

// Enum para identificar las canciones de forma legible.
enum MelodyID
{
    NO_MELODY = 0,
    SONG_NOKIA,
    SONG_TETRIS,
    SONG_PACMAN,
    SONG_TAKEONME,
    SONG_MARIO,
    SONG_SIREN 
};

// Enum para los tipos de alarma
enum AlarmType
{
    ALARM_INFRACTION, // Nokia
    ALARM_PANIC,      // Pacman
    ALARM_SISMO,      // Mario
    ALARM_GAS,        // Tetris    
    ALARM_STARTUP     // Take On Me
};


// --- FUNCIONES PÚBLICAS ---
void setupMelodies();
void loopMelodies();

// Acepta un tipo de alarma en lugar de una canción.
void startMelody(int buzzerIndex, AlarmType type);

void stopMelody(int buzzerIndex);

#endif // MELODIES_H