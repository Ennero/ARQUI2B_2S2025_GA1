/*
  FASE 1 – Panic buttons + Buzzers + Serial JSON
  - Botones con INPUT_PULLUP (activo LOW)
  - Zumbadores activos (ON/OFF) con patrón no bloqueante
  - Mensajes a Processing como JSON por línea
  - Comandos de entrada: "SILENCE" o "SILENCE <id>"
*/

#include <Arduino.h>

// ===================== CONFIGURACIÓN =====================
const uint8_t NUM_POINTS = 5;              // Cambia según tu maqueta
const uint8_t buttonPins[NUM_POINTS] = {2, 3, 4, 5};
const uint8_t buzzerPins[NUM_POINTS] = {8, 9, 10, 11};

// Duraciones (ms)
const unsigned long DEBOUNCE_MS     = 30;
const unsigned long ALARM_MS        = 10000;   // Cada alarma dura 10 s (o hasta "SILENCE")
const unsigned long BEEP_ON_MS      = 200;
const unsigned long BEEP_OFF_MS     = 150;

// ===================== ESTRUCTURAS =====================
struct Button {
    uint8_t pin;
    bool    stable;          // Estado estable (HIGH/LOW)
    bool    lastReading;     // Lectura inmediata anterior
    unsigned long lastChange;
};

struct Alarm {
    uint8_t buzzerPin;
    bool    active;
    bool    buzzerOn;
    unsigned long endAt;
    unsigned long lastToggle;
};

// ===================== ESTADO =====================
Button buttons[NUM_POINTS];
Alarm  alarms[NUM_POINTS];

// ===================== UTILIDADES =====================
void buzzerWrite(uint8_t pin, bool on) {
    digitalWrite(pin, on ? HIGH : LOW); // Zumbador ACTIVO (on/off)
}

void sendEvent(const char* type, int id, const char* state) {
    // Mensaje JSON por línea (newline-delimited JSON)
    // Ej: {"type":"panic","id":2,"state":"pressed","ts":12345}
    Serial.print("{\"type\":\"");
    Serial.print(type);
    Serial.print("\",\"id\":");
    Serial.print(id);
    Serial.print(",\"state\":\"");
    Serial.print(state);
    Serial.print("\",\"ts\":");
    Serial.print(millis());
    Serial.println("}");
}

void triggerAlarm(uint8_t i, unsigned long durationMs) {
    alarms[i].active     = true;
    alarms[i].buzzerOn   = true;
    alarms[i].endAt      = millis() + durationMs;
    alarms[i].lastToggle = millis();
    buzzerWrite(alarms[i].buzzerPin, true);
}

void stopAlarm(uint8_t i) {
    alarms[i].active = false;
    alarms[i].buzzerOn = false;
    buzzerWrite(alarms[i].buzzerPin, false);
}

void stopAllAlarms() {
    sfor (uint8_t i = 0; i < NUM_POINTS; i++) stopAlarm(i);
}

void updateAlarms() {
    const unsigned long now = millis();
    for (uint8_t i = 0; i < NUM_POINTS; i++) {
        if (!alarms[i].active) continue;

        if (now >= alarms[i].endAt) {
            stopAlarm(i);
            sendEvent("panic", i, "auto_silenced");
            continue;
        }

        const unsigned long interval = alarms[i].buzzerOn ? BEEP_ON_MS : BEEP_OFF_MS;
        if (now - alarms[i].lastToggle >= interval) {
            alarms[i].buzzerOn = !alarms[i].buzzerOn;
            alarms[i].lastToggle = now;
            buzzerWrite(alarms[i].buzzerPin, alarms[i].buzzerOn);
        }
    }
}

void handleSerialCommands() {
    // Comandos de texto simples: "SILENCE" o "SILENCE <id>"
    if (!Serial.available()) return;

    String line = Serial.readStringUntil('\n');
    line.trim();
    if (line.length() == 0) return;

    line.toUpperCase();
    if (line == "SILENCE") {
        stopAllAlarms();
        sendEvent("cmd", -1, "silence_all");
        return;
    }

    if (line.startsWith("SILENCE ")) {
        int id = line.substring(8).toInt();
        if (id >= 0 && id < (int)NUM_POINTS) {
            stopAlarm((uint8_t)id);
            sendEvent("cmd", id, "silence_one");
        } else {
            sendEvent("error", id, "invalid_id");
        }
    }
}

// ===================== ARDUINO =====================
void setup() {
    Serial.begin(115200);
    // Botones
    for (uint8_t i = 0; i < NUM_POINTS; i++) {
        buttons[i].pin = buttonPins[i];
        pinMode(buttons[i].pin, INPUT_PULLUP);
        buttons[i].lastReading = HIGH;
        buttons[i].stable = HIGH;
        buttons[i].lastChange = 0;
    }
    // Zumbadores
    for (uint8_t i = 0; i < NUM_POINTS; i++) {
        alarms[i].buzzerPin = buzzerPins[i];
        pinMode(alarms[i].buzzerPin, OUTPUT);
        buzzerWrite(alarms[i].buzzerPin, false);
        alarms[i].active = false;
        alarms[i].buzzerOn = false;
        alarms[i].endAt = 0;
        alarms[i].lastToggle = 0;
    }

    delay(200);
    sendEvent("system", -1, "ready");
}

void loop() {
    handleSerialCommands();

    // Lectura + debounce + flanco de PRESIONADO/RELEASE
    const unsigned long now = millis();
    for (uint8_t i = 0; i < NUM_POINTS; i++) {
        bool reading = digitalRead(buttons[i].pin);

        if (reading != buttons[i].lastReading) {
            buttons[i].lastReading = reading;
            buttons[i].lastChange = now;
        }

        if ((now - buttons[i].lastChange) > DEBOUNCE_MS) {
            if (reading != buttons[i].stable) {
                buttons[i].stable = reading;
                // Activo en LOW (INPUT_PULLUP)
                if (buttons[i].stable == LOW) {
                    // PRESIONADO -> dispara alarma local y reporta
                    triggerAlarm(i, ALARM_MS);
                    sendEvent("panic", i, "pressed");
                } else {
                    // RELEASE (opcional informar)
                    sendEvent("panic", i, "released");
                }
            }
        }
    }

    updateAlarms();
}
