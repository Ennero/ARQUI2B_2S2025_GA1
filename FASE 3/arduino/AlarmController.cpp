#include "AlarmController.h"

AlarmController::AlarmController(const int *buzzerPins, uint8_t numBuzzers)
{
    _buzzerPins = buzzerPins;
    _numBuzzers = numBuzzers;
    _activeAlarms = new AlarmType[numBuzzers];
    _tiempoInicioBuzzer = new unsigned long[numBuzzers];
    _ultimaAccionAlarm = new unsigned long[numBuzzers];
    _estadoPatronAlarm = new bool[numBuzzers];
}

void AlarmController::begin()
{
    for (int i = 0; i < _numBuzzers; i++)
    {
        pinMode(_buzzerPins[i], OUTPUT);
        digitalWrite(_buzzerPins[i], LOW);
        _activeAlarms[i] = NONE;
    }
}

void AlarmController::activarAlarm(int buzzerIndex, AlarmType type, int *panicArray)
{
    if (buzzerIndex < 0 || buzzerIndex >= _numBuzzers)
        return;

    if (_activeAlarms[buzzerIndex] == NONE)
    {
        unsigned long now = millis();
        _activeAlarms[buzzerIndex] = type;
        _tiempoInicioBuzzer[buzzerIndex] = now;
        _ultimaAccionAlarm[buzzerIndex] = now;
        _estadoPatronAlarm[buzzerIndex] = false;
        
        // Solo actualizar panicArray si es un botón de pánico Y se pasó el array
        if (panicArray && type == PANICO_BTN)
            panicArray[buzzerIndex] = 1;
    }
}

void AlarmController::controlarAlarms(int *panicArray)
{
    unsigned long now = millis();
    for (int i = 0; i < _numBuzzers; i++)
    {
        if (_activeAlarms[i] == NONE)
            continue;

        if (now - _tiempoInicioBuzzer[i] >= _duracionBuzzer)
        {
            noTone(_buzzerPins[i]);
            
            // Solo apagar panicArray si era un botón de pánico Y se pasó el array
            if (panicArray && _activeAlarms[i] == PANICO_BTN)
                panicArray[i] = 0;
                
            _activeAlarms[i] = NONE;
            continue;
        }

        switch (_activeAlarms[i])
        {
        case PANICO_BTN:
            tone(_buzzerPins[i], FREQ_PANICO);
            break;
        case INCENDIO:
            if (now - _ultimaAccionAlarm[i] > 300)
            {
                _estadoPatronAlarm[i] = !_estadoPatronAlarm[i];
                _ultimaAccionAlarm[i] = now;
            }
            tone(_buzzerPins[i], _estadoPatronAlarm[i] ? FREQ_INCENDIO_A : FREQ_INCENDIO_B);
            break;
        case INFRACCION:
        {
            unsigned long t = now - _tiempoInicioBuzzer[i];
            if ((t > 0 && t < 150) || (t > 300 && t < 450))
                tone(_buzzerPins[i], FREQ_INFRACCION);
            else
                noTone(_buzzerPins[i]);
        }
        break;
        case SISMO_ALARM:
            if ((now - _tiempoInicioBuzzer[i]) % 1000 < 500)
                tone(_buzzerPins[i], FREQ_SISMO);
            else
                noTone(_buzzerPins[i]);
            break;
        case ANTI_ROBO:
            if ((now - _tiempoInicioBuzzer[i]) % 400 < 200)
                tone(_buzzerPins[i], FREQ_ROBO_A);
            else
                tone(_buzzerPins[i], FREQ_ROBO_B);
            break;
        case ARMA_BLANCA:
            if ((now - _tiempoInicioBuzzer[i]) % 800 < 700)
                tone(_buzzerPins[i], FREQ_ARMA);
            else
                noTone(_buzzerPins[i]);
            break;
        case PLACAS:
        {
            unsigned long t = now - _tiempoInicioBuzzer[i];
            if ((t > 0 && t < 100) || (t > 200 && t < 300))
                tone(_buzzerPins[i], FREQ_PLACAS);
            else
                noTone(_buzzerPins[i]);
        }
        break;
        default:
            noTone(_buzzerPins[i]);
            break;
        }
    }
}

AlarmController::~AlarmController()
{
    delete[] _activeAlarms;
    delete[] _tiempoInicioBuzzer;
    delete[] _ultimaAccionAlarm;
    delete[] _estadoPatronAlarm;
}