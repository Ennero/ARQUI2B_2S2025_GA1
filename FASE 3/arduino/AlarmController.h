#ifndef ALARMCONTROLLER_H
#define ALARMCONTROLLER_H

#include <Arduino.h>

enum AlarmType
{
    NONE,
    PANICO_BTN,
    INCENDIO,
    INFRACCION,
    SISMO_ALARM,
    ANTI_ROBO,
    ARMA_BLANCA,
    PLACAS
};

class AlarmController
{
public:
    AlarmController(const int *buzzerPins, uint8_t numBuzzers);
    ~AlarmController();
    void begin();
    void activarAlarm(int buzzerIndex, AlarmType type, int *panicArray);
    void controlarAlarms(int *panicArray);

private:
    const int *_buzzerPins;
    uint8_t _numBuzzers;
    unsigned long _duracionBuzzer = 3000;

    AlarmType *_activeAlarms;
    unsigned long *_tiempoInicioBuzzer;
    unsigned long *_ultimaAccionAlarm;
    bool *_estadoPatronAlarm;

    static const int FREQ_PANICO = 1500;
    static const int FREQ_INCENDIO_A = 800;
    static const int FREQ_INCENDIO_B = 1200;
    static const int FREQ_INFRACCION = 2000;
    static const int FREQ_SISMO = 400;
    static const int FREQ_ROBO_A = 2500;
    static const int FREQ_ROBO_B = 1800;
    static const int FREQ_ARMA = 600;
    static const int FREQ_PLACAS = 3000;
};

#endif