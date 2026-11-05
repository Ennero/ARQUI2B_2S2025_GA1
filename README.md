# Sistema por fases de sensores, visión artificial y aplicación móvil

Tres fases de Arquitectura de Computadoras 2 con control Arduino, dashboards Processing, API Python/MongoDB/MQTT y, en la tercera fase, reconocimiento visual y una aplicación Flutter.

## Requisitos

Arduino IDE y hardware de cada fase; Processing para archivos .pde; Python y dependencias propias de cada API/servicio; MongoDB y MQTT. Fase3 también requiere Flutter y recursos de cámara/inferencia indicados en sus manuales.

## Ejecución

Los comandos parten de la raíz del repositorio, salvo donde se indica otra terminal.

```bash
# API de Fase2: copiar .env.example a .env y ajustar valores
cd "FASE 2/api"
python -m pip install -r requirements.txt
python -m uvicorn main:app --host 127.0.0.1 --port 8000

# Aplicación móvil, desde la raíz:
cd "FASE 3/flutter/flutter_application"
flutter pub get
flutter run
```

## Recorrido de demostración

Elegir una fase completa: cargar su sketch Arduino, iniciar MQTT/API y abrir el dashboard o cliente correspondiente. Consultar DocumentacionFase y los reportes semanales para el montaje y las pruebas; el manual Flutter explica el cliente de la tercera fase.

## Organización

Carpetas de la entrega: [`FASE 1/`](FASE%201/), [`FASE 2/`](FASE%202/), [`FASE 3/`](FASE%203/).

## Documentación

- [DocumentacionFase1](FASE%201/docs/DocumentacionFase1.md)
- [DocumentacionFase2](FASE%202/docs/fase2/DocumentacionFase2.md)
- [DocumentacionFase3](FASE%203/docs/fase3/DocumentacionFase3.md)
- [ManualFlutter](FASE%203/docs/fase3/ManualFlutter.md)

## Alcance y límites

No todas las fases comparten entorno ni plataforma. Los modelos de visión incluidos se conservan como recursos de la entrega; deben revisarse su procedencia y las condiciones de uso antes de redistribuirlos fuera del proyecto académico. No se incluyen entornos virtuales.

## Contexto y licencia

Trabajo académico o de aprendizaje conservado en el portafolio de [Enner Mendizabal](https://github.com/Ennero). Los créditos de los trabajos en grupo se conservan en sus entregas y manuales.

Consultar [LICENSE](LICENSE) para la licencia de la raíz. Las dependencias y los componentes con avisos o licencias propios conservan sus condiciones.

Para el servicio de visión de Fase3, copiar `FASE 3/ai/.env.example` a `.env` en esa carpeta. El target Docker disponible se llama `development`; después seguir FASE 3/ai/readme.md para cámara, modelos y servicios relacionados.
