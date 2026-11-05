# Documento de Desarrollo y Resultados del Proyecto
## Proyecto: Gestión Inteligente de Tráfico y Seguridad Ciudadana (Fase 3)

**Ingeniero**: JURGEN ANDONI RAMIREZ RAMÍREZ

**Tutor:** AXEL ELÍ CALDERÓN BARRIENTOS

**Fecha:** 17 de Septiembre de 2025  

**Clase:** (779) Arquitectura de Computadoras y Ensambladores 2. Seccion B.

## Grupo A - Tutor 1

#
**Miembros del equipo:**
#

| Nombre del integrante                       | Carnet                           |
|---------------------------------------------|----------------------------------|
| MARCOS DANIEL BONIFASI DE LEÓN              | 202202410 | 
| ALFREDO EMMANUEL DOMINGUEZ RODRIGUEZ        | 202300535 | 
| ALVARO HUMBERTO GARCIA OLIVAREZ             | 199817948 | 
| ESTEBAN SANCHEZ TUCHEZ                      | 202300710 | 
| JUAN JOSE SANDOVAL RUIZ                     | 202300769 | 
| DAVID ESTUARDO BARRIOS RAMIREZ              | 202300670 | 
| ENNER ESAÍ MENDIZABAL CASTRO                | 202302220 | 

---

# MANUAL DE FLUTTER 

---

## Índice

- [Introducción](#introducci%C3%B3n)
- [Pestaña "Principal" (Acerca del Proyecto)](#pesta%C3%B1a-principal-acerca-del-proyecto)
- [Pestaña "Control" (Panel de Control)](#pesta%C3%B1a-control-panel-de-control)
  - [Panel Operacional](#panel-operacional)
  - [Panel Analítico](#panel-anal%C3%ADtico)
- [Pestaña "Notificaciones" (Alertas y Notificaciones)](#pesta%C3%B1a-notificaciones-alertas-y-notificaciones)
- [Pestaña "Mapa"](#pesta%C3%B1a-mapa)

---

## Introducción

Bienvenido a la aplicación "Gestión de Tráfico", su centro integral para la monitorización de la ciudad inteligente. Esta herramienta tecnológica avanzada no solo muestra este, sino que también integra datos de seguridad, transporte público y calidad del aire para permitir una toma de decisiones informada y eficiente.

Este manual le guiará a través de las cuatro secciones principales de la aplicación, accesibles desde la barra de navegación inferior:

* **Principal:** Conozca la misión y visión del proyecto.

* **Control:** Acceda a los paneles de datos operativos y analíticos.

* **Notificaciones:** Revise las alertas críticas en tiempo real.

* **Mapa:** Visualice la ubicación y estado del transporte público.

## Pestaña "Principal" (Acerca del Proyecto)

La pestaña "Principal" (icono de casa) es la pantalla de inicio de la aplicación. Aquí encontrará la información fundamental sobre el propósito y el funcionamiento del proyecto.

![1](../img/fase%203/flutterManual/1.jpeg)

Esta sección se divide en tres partes clave:

* **Nuestra Misión:** Ofrecer a los ciudadanos una herramienta tecnológica para visualizar datos complejos de forma sencilla, permitiendo tomar decisiones informadas.

* **Visión del Proyecto:** Contribuir a la creación de ciudades más seguras, eficientes e inteligentes mediante el uso de tecnologías como el Internet de las Cosas (IoT).

* **¿Cómo Funciona?:** Nuestra app se conecta a una red de sensores simulados que recopilan datos sobre tráfico, alertas y transporte público en tiempo real.


## Pestaña "Control" (Panel de Control)

La pestaña "Control" (icono de monitor) es el centro neurálgico para el análisis de datos. Se divide en dos sub-pestañas: "Operacional" y "Analítico".


### Panel Operacional

Muestra los datos en tiempo real de las operaciones diarias de la ciudad. Puede filtrar la vista por "Hoy", "Semana" o "Mes".

![2](../img/fase%203/flutterManual/2.jpeg)

Los indicadores clave en este panel incluyen:

* **Recorrido Transmetro:** Kilómetros totales recorridos por las unidades de Transmetro.

* **Recorrido Transurbano:** Kilómetros totales recorridos por las unidades de Transurbano.

* **Calidad Aire (PM)**: Nivel actual de partículas (PM) en el aire, indicando la calidad del mismo.

* **Alertas Críticas:** Contador de alertas de alta prioridad generadas.

### Panel Analítico

Ofrece un resumen estadístico de los eventos detectados por el sistema, como las infracciones y la detección de objetos.

![3](../img/fase%203/flutterManual/3.jpeg)

* **Top de Armas Detectadas:** Un ranking de los tipos de armas detectadas por los sistemas de videovigilancia, mostrando el número de "Vistas" o detecciones para cada una (ej. rifle, pistol, knife).

![4](../img/fase%203/flutterManual/4.jpeg)

* **Infracciones del Día (Semáforo):** Un registro de las infracciones de tráfico capturadas, específicamente las relacionadas con semáforos. Si no se han registrado infracciones, mostrará el mensaje "No hay infracciones registradas hoy".

## Pestaña "Notificaciones" (Alertas y Notificaciones)

La pestaña "Notificaciones" (icono de campana) es donde recibirá y podrá revisar todas las alertas generadas por los diferentes sensores y sistemas de inteligencia artificial de la red.

![5](../img/fase%203/flutterManual/5.jpeg)

Cada notificación le informa sobre:

* **El tipo de alerta:** Por ejemplo, "Persona en lista negra detectada", "Arma blanca detectada" o "Alerta de calidad de aire".

* **Una breve descripción:** Detalla el evento (ej. "Se detectó una persona con record criminal en la ciudad.").

* **La fuente:** Indica qué sistema o sensor generó la alerta (ej. "IA-DETECTION-SYSTEM", "IA-DETECTION-CAM-04", "AQM-SENSOR-01").

* **La hora:** Muestra qué tan reciente es la alerta (ej. "Hace 1 días").


## Pestaña "Mapa"

La pestaña "Mapa" (icono de mapa) proporciona una visualización geoespacial en tiempo real de los activos de transporte público.

![6](../img/fase%203/flutterManual/6.jpeg)

Las características principales de esta pantalla son:

* **Seguimiento de Autobuses:** Muestra el estado de las líneas "TRANSMETRO" y "TRANSURBANO", indicando la "próxima parada", la "Distancia aprox." y el "Tiempo aprox." de llegada.

* **Mapa Interactivo:** Un plano de la ciudad con iconos que representan diferentes puntos de interés y la ubicación actual de las unidades de transporte.


