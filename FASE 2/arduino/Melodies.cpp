#include "Melodies.h"

// --- CONFIGURACIÓN INTERNA DEL MÓDULO DE MELODÍAS ---
// Corresponden a los PINES_BUZZER[0] a PINES_BUZZER[4]
const int PINES_BUZZER[] = {49, 53, A14, A12, A10};
const uint8_t NUM_BUZZERS = sizeof(PINES_BUZZER) / sizeof(PINES_BUZZER[0]);

// --- Definición de todas las notas musicales ---
#define NOTE_B0 31
#define NOTE_C1 33
#define NOTE_CS1 35
#define NOTE_D1 37
#define NOTE_DS1 39
#define NOTE_E1 41
#define NOTE_F1 44
#define NOTE_FS1 46
#define NOTE_G1 49
#define NOTE_GS1 52
#define NOTE_A1 55
#define NOTE_AS1 58
#define NOTE_B1 62
#define NOTE_C2 65
#define NOTE_CS2 69
#define NOTE_D2 73
#define NOTE_DS2 78
#define NOTE_E2 82
#define NOTE_F2 87
#define NOTE_FS2 93
#define NOTE_G2 98
#define NOTE_GS2 104
#define NOTE_A2 110
#define NOTE_AS2 117
#define NOTE_B2 123
#define NOTE_C3 131
#define NOTE_CS3 139
#define NOTE_D3 147
#define NOTE_DS3 156
#define NOTE_E3 165
#define NOTE_F3 175
#define NOTE_FS3 185
#define NOTE_G3 196
#define NOTE_GS3 208
#define NOTE_A3 220
#define NOTE_AS3 233
#define NOTE_B3 247
#define NOTE_C4 262
#define NOTE_CS4 277
#define NOTE_D4 294
#define NOTE_DS4 311
#define NOTE_E4 330
#define NOTE_F4 349
#define NOTE_FS4 370
#define NOTE_G4 392
#define NOTE_GS4 415
#define NOTE_A4 440
#define NOTE_AS4 466
#define NOTE_B4 494
#define NOTE_C5 523
#define NOTE_CS5 554
#define NOTE_D5 587
#define NOTE_DS5 622
#define NOTE_E5 659
#define NOTE_F5 698
#define NOTE_FS5 740
#define NOTE_G5 784
#define NOTE_GS5 831
#define NOTE_A5 880
#define NOTE_AS5 932
#define NOTE_B5 988
#define NOTE_C6 1047
#define NOTE_CS6 1109
#define NOTE_D6 1175
#define NOTE_DS6 1245
#define NOTE_E6 1319
#define NOTE_F6 1397
#define NOTE_FS6 1480
#define NOTE_G6 1568
#define NOTE_GS6 1661
#define NOTE_A6 1760
#define NOTE_AS6 1865
#define NOTE_B6 1976
#define NOTE_C7 2093
#define NOTE_CS7 2217
#define NOTE_D7 2349
#define NOTE_DS7 2489
#define NOTE_E7 2637
#define NOTE_F7 2794
#define NOTE_FS7 2960
#define NOTE_G7 3136
#define NOTE_GS7 3322
#define NOTE_A7 3520
#define NOTE_AS7 3729
#define NOTE_B7 3951
#define NOTE_C8 4186
#define NOTE_CS8 4435
#define NOTE_D8 4699
#define NOTE_DS8 4978
#define REST 0

// --- Datos de cada melodía (Tempo y Notas) ---
static const int tempoNokia = 180;
static const int melodyNokia[] = {NOTE_E5, 8, NOTE_D5, 8, NOTE_FS4, 4, NOTE_GS4, 4, NOTE_CS5, 8, NOTE_B4, 8, NOTE_D4, 4, NOTE_E4, 4, NOTE_B4, 8, NOTE_A4, 8, NOTE_CS4, 4, NOTE_E4, 4, NOTE_A4, 2};
static const int tempoTetris = 144;
static const int melodyTetris[] = {NOTE_E5, 4, NOTE_B4, 8, NOTE_C5, 8, NOTE_D5, 4, NOTE_C5, 8, NOTE_B4, 8, NOTE_A4, 4, NOTE_A4, 8, NOTE_C5, 8, NOTE_E5, 4, NOTE_D5, 8, NOTE_C5, 8, NOTE_B4, -4, NOTE_C5, 8, NOTE_D5, 4, NOTE_E5, 4, NOTE_C5, 4, NOTE_A4, 4, NOTE_A4, 4, REST, 4};
static const int tempoPacman = 105;
static const int melodyPacman[] = {NOTE_B4, 16, NOTE_B5, 16, NOTE_FS5, 16, NOTE_DS5, 16, NOTE_B5, 32, NOTE_FS5, -16, NOTE_DS5, 8, NOTE_C5, 16, NOTE_C6, 16, NOTE_G6, 16, NOTE_E6, 16, NOTE_C6, 32, NOTE_G6, -16, NOTE_E6, 8, NOTE_B4, 16, NOTE_B5, 16, NOTE_FS5, 16, NOTE_DS5, 16, NOTE_B5, 32, NOTE_FS5, -16, NOTE_DS5, 8, NOTE_DS5, 32, NOTE_E5, 32, NOTE_F5, 32, NOTE_F5, 32, NOTE_FS5, 32, NOTE_G5, 32, NOTE_G5, 32, NOTE_GS5, 32, NOTE_A5, 16, NOTE_B5, 8};
static const int tempoTakeOnMe = 140;
static const int melodyTakeOnMe[] = {NOTE_FS5, 8, NOTE_FS5, 8, NOTE_D5, 8, NOTE_B4, 8, REST, 8, NOTE_B4, 8, REST, 8, NOTE_E5, 8, REST, 8, NOTE_E5, 8, REST, 8, NOTE_E5, 8, NOTE_GS5, 8, NOTE_GS5, 8, NOTE_A5, 8, NOTE_B5, 8, NOTE_A5, 8, NOTE_A5, 8, NOTE_A5, 8, NOTE_E5, 8, REST, 8, NOTE_D5, 8, REST, 8, NOTE_FS5, 8, REST, 8, NOTE_FS5, 8, REST, 8, NOTE_FS5, 8, NOTE_E5, 8, NOTE_E5, 8, NOTE_FS5, 8, NOTE_E5, 8};
static const int tempoMario = 200;
static const int melodyMario[] = {NOTE_E5, 8, NOTE_E5, 8, REST, 8, NOTE_E5, 8, REST, 8, NOTE_C5, 8, NOTE_E5, 8, NOTE_G5, 4, REST, 4, NOTE_G4, 8, REST, 4, NOTE_C5, -4, NOTE_G4, 8, REST, 4, NOTE_E4, -4, NOTE_A4, 4, NOTE_B4, 4, NOTE_AS4, 8, NOTE_A4, 4, NOTE_G4, -8, NOTE_E5, -8, NOTE_G5, -8, NOTE_A5, 4, NOTE_F5, 8, NOTE_G5, 8, REST, 8, NOTE_E5, 4, NOTE_C5, 8, NOTE_D5, 8, NOTE_B4, -4};

// Estructura para almacenar la información de cada canción
struct SongInfo
{
    const int *melody;
    int tempo;
    int noteCount;
};

// Arreglo de TODAS las canciones disponibles
static const SongInfo songbook[] = {
    {nullptr, 0, 0}, // NO_MELODY
    {melodyNokia, tempoNokia, sizeof(melodyNokia) / sizeof(int) / 2},
    {melodyTetris, tempoTetris, sizeof(melodyTetris) / sizeof(int) / 2},
    {melodyPacman, tempoPacman, sizeof(melodyPacman) / sizeof(int) / 2},
    {melodyTakeOnMe, tempoTakeOnMe, sizeof(melodyTakeOnMe) / sizeof(int) / 2},
    {melodyMario, tempoMario, sizeof(melodyMario) / sizeof(int) / 2}};

// --- Variables de estado para la reproducción no bloqueante ---
struct BuzzerState
{
    MelodyID currentSong;
    int currentNoteIndex;
    unsigned long noteStartTime;
    bool isPlaying;
};

// Un estado para cada buzzer
static BuzzerState buzzerStates[NUM_BUZZERS];

// ---- IMPLEMENTACIÓN DE FUNCIONES ----

void setupMelodies()
{
    for (int i = 0; i < NUM_BUZZERS; i++)
    {
        pinMode(PINES_BUZZER[i], OUTPUT);
        digitalWrite(PINES_BUZZER[i], LOW);
        buzzerStates[i] = {NO_MELODY, 0, 0, false};
    }
}

void startMelody(int buzzerIndex, MelodyID song)
{

    if (buzzerIndex < 0 || buzzerIndex >= NUM_BUZZERS)
        return;
    PANICO[buzzerIndex] = 1;
    // Si ya está sonando, no la reinicies. Si quieres que se reinicie, quita esta línea.
    if (buzzerStates[buzzerIndex].isPlaying && buzzerStates[buzzerIndex].currentSong == song)
        return;

    buzzerStates[buzzerIndex].currentSong = song;
    buzzerStates[buzzerIndex].currentNoteIndex = 0;
    buzzerStates[buzzerIndex].noteStartTime = millis();
    buzzerStates[buzzerIndex].isPlaying = true;
}

void stopMelody(int buzzerIndex)
{
    if (buzzerIndex < 0 || buzzerIndex >= NUM_BUZZERS)
        return;
    noTone(PINES_BUZZER[buzzerIndex]);
    buzzerStates[buzzerIndex].isPlaying = false;
    buzzerStates[buzzerIndex].currentSong = NO_MELODY;
}

void loopMelodies()
{
    unsigned long now = millis();

    for (int i = 0; i < NUM_BUZZERS; i++)
    {
        if (!buzzerStates[i].isPlaying)
        {
            continue; // Si este buzzer no está sonando, pasa al siguiente
        }

        const SongInfo &currentSongInfo = songbook[buzzerStates[i].currentSong];
        int noteIndex = buzzerStates[i].currentNoteIndex;

        // Calcula la duración de la nota actual
        int wholenote = (60000 * 4) / currentSongInfo.tempo;
        int divider = currentSongInfo.melody[noteIndex * 2 + 1];
        int noteDuration = 0;
        if (divider > 0)
        {
            noteDuration = wholenote / divider;
        }
        else
        {
            noteDuration = (wholenote / abs(divider)) * 1.5;
        }

        // Comprueba si el tiempo de la nota ya pasó
        if (now - buzzerStates[i].noteStartTime >= noteDuration)
        {
            noTone(PINES_BUZZER[i]); // Detiene la nota actual

            buzzerStates[i].currentNoteIndex++; // Pasa a la siguiente nota

            // Si la canción terminó
            if (buzzerStates[i].currentNoteIndex >= currentSongInfo.noteCount)
            {
                buzzerStates[i].isPlaying = false;
                buzzerStates[i].currentSong = NO_MELODY;
                PANICO[i] = 0; // <-- AÑADIR ESTA LÍNEA AQUÍ
            }
            else
            {
                // Si no, prepara y toca la siguiente nota
                int nextNoteIndex = buzzerStates[i].currentNoteIndex;
                int pitch = currentSongInfo.melody[nextNoteIndex * 2];

                // El nuevo tiempo de inicio es ahora
                buzzerStates[i].noteStartTime = now;

                // Toca la nueva nota (con pausa del 10%)
                divider = currentSongInfo.melody[nextNoteIndex * 2 + 1];
                if (divider > 0)
                {
                    noteDuration = wholenote / divider;
                }
                else
                {
                    noteDuration = (wholenote / abs(divider)) * 1.5;
                }

                if (pitch != REST)
                {
                    tone(PINES_BUZZER[i], pitch, noteDuration * 0.9);
                }
            }
        }
    }
}