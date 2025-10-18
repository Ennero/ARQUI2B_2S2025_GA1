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

- [1. Resumen](#1-resumen)  
- [2. Introducción](#2-introducción)  
  - [2.1. Justificación y Planteamiento del Problema](#21-justificación-y-planteamiento-del-problema)  
  - [2.2. Objetivos del Proyecto](#22-objetivos-del-proyecto)  
- [3. Alcance y Delimitaciones (Fase 3)](#3-alcance-y-delimitaciones-fase-3)  
  - [3.1. Alcance Funcional](#31-alcance-funcional)  
  - [3.2. Delimitaciones y Exclusiones](#32-delimitaciones-y-exclusiones)  
- [4. Arquitectura del Sistema](#4-arquitectura-del-sistema)  
  - [4.1. Arquitectura de Hardware](#41-arquitectura-de-hardware)  
  - [4.2. Visualización de datos en Grafana](#42-visualizacion-de-datos-en-grafana)  
  - [4.3. Flujo de Datos y Comunicación](#43-flujo-de-datos-y-comunicación)  
- [5. Descripción del Trabajo de Software Implementado](#5-descripción-del-trabajo-de-software-implementado)  
  - [5.1. Detalles de Funcionamiento](#51-detalles-de-funcionamiento)  
  - [5.2. Usos y Beneficios del Prototipo (Fase 3)](#52-usos-y-beneficios-del-prototipo-fase-3)  
- [6. Diagramas](#6-diagramas)  
- [7. Modelo 3D Implementado en Maqueta Física](#7-modelo-3d-implementado-en-maqueta-física)  
- [8. Link de GitHub (Repositorio general y de Sitio Web)](#8-link-de-github-repositorio-general-y-de-sitio-web)  
- [9. Anexos](#9-anexos)  

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


