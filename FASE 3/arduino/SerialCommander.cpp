#include "SerialCommander.h"

SerialCommander::SerialCommander(AlarmController& alarmController, int* panicArray)
: _alarmController(alarmController), _panicArray(panicArray) {}

void SerialCommander::checkAndProcessCommands() {
  while (Serial.available() > 0) {
    char caracterEntrante = Serial.read();

    if (caracterEntrante == ';') {
      _comandoBuffer[_bufferPos] = '\0';

      char* comando = strtok(_comandoBuffer, ":");
      char* valorStr = strtok(NULL, "");

      if (comando != NULL && valorStr != NULL) {
        int buzzerIndex = atoi(valorStr) - 1;
        AlarmType alarmType = NONE;

        if (strcmp(comando, "antiRobo") == 0) alarmType = ANTI_ROBO;
        else if (strcmp(comando, "armaBlanca") == 0) alarmType = ARMA_BLANCA;
        else if (strcmp(comando, "placas") == 0) alarmType = PLACAS;
        
        if (alarmType != NONE) {
            _alarmController.activarAlarm(buzzerIndex, alarmType, _panicArray);
        }
      }
      _bufferPos = 0;
      memset(_comandoBuffer, 0, COMMAND_BUFFER_SIZE);
    } else if (_bufferPos < COMMAND_BUFFER_SIZE - 1) {
      _comandoBuffer[_bufferPos++] = caracterEntrante;
    }
  }
}