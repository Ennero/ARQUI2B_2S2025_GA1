#ifndef SERIALCOMMANDER_H
#define SERIALCOMMANDER_H

#include "AlarmController.h"

class SerialCommander
{
public:
    SerialCommander(AlarmController &alarmController, int *panicArray);
    void checkAndProcessCommands();

private:
    AlarmController &_alarmController;
    int *_panicArray;
    static const int COMMAND_BUFFER_SIZE = 50;
    char _comandoBuffer[COMMAND_BUFFER_SIZE];
    int _bufferPos = 0;
};

#endif