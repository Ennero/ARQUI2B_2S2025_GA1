import serial
import time

# Asegúrate de que el puerto ('/dev/ttyACM0') y el baudrate (9600) coincidan
try:
    arduino = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
    time.sleep(2) # Espera a que se establezca la conexión
    print("Conexión con Arduino establecida.")

    # --- Envía los comandos ---
    print("Enviando alerta ANTI-ROBO al buzzer 2...")
    comando = "antiRobo:2;"
    arduino.write(comando.encode())
    time.sleep(5)

    print("Enviando alerta ARMA BLANCA al buzzer 4...")
    comando = "armaBlanca:4;"
    arduino.write(comando.encode())
    time.sleep(5)
    
    print("Enviando alerta de PLACAS al buzzer 1...")
    comando = "placas:1;"
    arduino.write(comando.encode())
    time.sleep(5)

    arduino.close()
    print("Comandos enviados. Conexión cerrada.")

except serial.SerialException as e:
    print(f"Error al conectar con Arduino: {e}")