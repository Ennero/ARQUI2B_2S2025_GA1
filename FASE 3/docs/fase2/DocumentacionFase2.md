# Documento de Desarrollo y Resultados del Proyecto
## Proyecto: Gestión Inteligente de Tráfico y Seguridad Ciudadana (Fase 2)

**Ingeniero**: JURGEN ANDONI RAMIREZ RAMÍREZ

**Tutor:** AXEL ELÍ CALDERÓN BARRIENTOS

**Fecha:** 06 de Septiembre de 2025  

**Clase:** (779) Arquitectura de Computadoras y Ensambladores 2. Seccion B.

**Fase:** Actualización de avances en lo planificado de la semana anterior

**Fecha:** 12 de Septiembre de 2025
## Grupo A,1 - Tutor 1

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
| CARLOS JEZEH GEDEONI TOSCANO PALACIOS       | 201532643 |

---

## Índice

- [1. Resumen](#1-resumen)
- [2. Introducción](#2-introducción)
  - [2.1. Justificación y Planteamiento del Problema](#21-justificación-y-planteamiento-del-problema)
  - [2.2. Objetivos del Proyecto](#22-objetivos-del-proyecto)
- [3. Alcance y Delimitaciones (Fase 2)](#3-alcance-y-delimitaciones-fase-2)
  - [3.1. Alcance Funcional](#31-alcance-funcional)
  - [3.2. Delimitaciones y Exclusiones](#32-delimitaciones-y-exclusiones)
- [4. Arquitectura del Sistema](#4-arquitectura-del-sistema)
  - [4.1. Arquitectura de Hardware](#41-arquitectura-de-hardware)
  - [4.2. Arquitectura de Software](#42-arquitectura-de-software)
  - [4.3. Flujo de Datos y Comunicación](#43-flujo-de-datos-y-comunicación)
- [Diagramas](#diagramas)
- [Link de Github](#link-de-github)
- [Modelo 3D implementado en Maqueta Física](#modelo-3d-implementado-en-maqueta-física)
- [6. Descripción Del trabajo de Software implementado](#6-descripción-del-trabajo-de-software-implementado)
  - [6.1. Detalles de Funcionamiento](#61-detalles-de-funcionamiento)
  - [6.2. Usos y Beneficios del Prototipo (Fase 2)](#62-usos-y-beneficios-del-prototipo-fase-2)

---

### 1. Resumen

Este documento presenta de manera detallada el desarrollo, resultados y aprendizajes obtenidos durante la Fase 2 del proyecto "Sistema de Gestión Inteligente de Tráfico y Seguridad Ciudadana". En esta etapa, el equipo se propuso evolucionar el prototipo inicial hacia una solución más robusta y funcional, integrando nuevas tecnologías y optimizando los procesos de monitoreo, comunicación y visualización de datos. La planeación fue exhaustiva, abarcando desde la definición de roles y tareas específicas para cada integrante, hasta la organización semanal de actividades y la gestión colaborativa en plataformas digitales.

Durante las tres semanas de trabajo, se abordaron retos técnicos y logísticos que requirieron una coordinación constante y la adaptación de estrategias. Se logró implementar una arquitectura distribuida basada en microcontroladores Arduino y Raspberry Pi, conectados a una red de sensores y actuadores que permitieron la recolección y procesamiento de datos en tiempo real. Además, se desarrolló una aplicación móvil en Flutter para la visualización remota y local de información relevante, y se integró un sistema de comunicación MQTT junto a una API y base de datos en MongoDB para la gestión eficiente de los datos.

<<<<<<< HEAD
![2](../img/fase%202/S2-7.jpg)
=======

>>>>>>> develop

El equipo trabajó en la optimización del cableado y encapsulamiento de la maqueta física, facilitando el acceso y mantenimiento de los componentes electrónicos. Se realizaron pruebas exhaustivas de integración, depuración de errores y validación de funcionalidades, asegurando que el sistema respondiera correctamente ante eventos críticos como alertas de sismo, incendios y activación de botones de pánico. Cada componente, desde los sensores ultrasónicos y de gas, hasta los zumbadores y LEDs, fue seleccionado y configurado para cumplir con los objetivos planteados.

 Los resultados obtenidos en esta fase sientan las bases para futuras mejoras e implementaciones a mayor escala, demostrando la viabilidad y el impacto positivo de la integración de tecnologías IoT, comunicación en tiempo real y visualización avanzada en el contexto de la seguridad y movilidad ciudadana.

---

### 2. Introducción


#### 2.1. Justificación y Planteamiento del Problema

La Fase 2 del proyecto surge como respuesta a la necesidad de mejorar la gestión del tráfico y la seguridad ciudadana en entornos urbanos densos y complejos, como el Centro Histórico de la Ciudad de Guatemala. Los problemas de congestión vehicular, la falta de monitoreo en tiempo real y la limitada capacidad de respuesta ante emergencias evidencian la urgencia de implementar soluciones tecnológicas avanzadas. 

El proyecto se justifica en la exploración y validación de un modelo de ciudad inteligente, donde la tecnología IoT nos ayudará en la comunicación en tiempo real y la visualización avanzada para crear un entorno urbano más seguro, eficiente y de calidad. La integración de sensores y microcontroladores (una raspberry pi), plataformas móviles (Flutter) y sistemas de comunicación permite abordar los retos actuales y sentar las bases para futuras expansiones y mejoras. Esta fase representa un avance significativo en la aplicación práctica de conceptos de smart cities, adaptados a las necesidades y recursos locales.

<<<<<<< HEAD
![2](../img/fase%202/2.jpg)
=======

>>>>>>> develop
#

#### 2.2. Objetivos del Proyecto

##### **Objetivo General:**

Diseñar, construir e implementar un sistema inteligente de monitoreo y gestión urbana, capaz de recolectar, procesar y visualizar datos en tiempo real sobre tráfico y seguridad ciudadana, utilizando una arquitectura distribuida basada en microcontroladores, sensores, comunicación intermediaria de MQTT, implementación de una API y una aplicación móvil en Flutter.

##### **Objetivos Específicos:**

1.  **Desarrollar** el firmware en Arduino IDE y la lógica de comunicación en Raspberry Pi, permitiendo la gestión de actuadores (LEDs, zumbadores) y la transmisión de datos vía MQTT y API.
2.  **Crear** una aplicación móvil en Flutter y un dashboard web para la visualización en tiempo real de los datos recolectados y el estado del sistema.
3.  **Validar** el funcionamiento de los sistemas de alerta temprana, visualización y registro de eventos críticos, asegurando la respuesta adecuada ante infracciones, incendios, sismos y pánico.

---

### 3. Alcance y Delimitaciones (Fase 2)


#### 3.1. Alcance Funcional

Todos los dispositivos que se habian interconectado y configurado en la Fase 1 del proyecto, están ahora conectados a una arquitectura distribuida basada en Arduino y Raspberry Pi, permitiendo la adquisición, procesamiento y transmisión eficiente de datos.
#
<<<<<<< HEAD
![2](../img/fase%202/3.png)
=======

>>>>>>> develop
#

El sistema de alertas fue optimizado para activar alarmas sonoras y visuales tanto en la maqueta física como en la aplicación móvil. La información recolectada se visualiza en tiempo real a través de interfaces desarrolladas en Flutter, facilitando la supervisión y toma de decisiones por parte de los usuarios. Además, se implementó una base de datos en MongoDB y comunicación MQTT para asegurar la persistencia y el flujo confiable de los datos entre los diferentes componentes del sistema.

#### 3.2. Delimitaciones y Exclusiones

Para mantener el enfoque en los objetivos de la Fase 2, se establecieron ciertas delimitaciones y exclusiones. Aunque se avanzó en la integración de nuevas tecnologías, no se implementaron algoritmos de Inteligencia Artificial ni procesamiento de video, reconocimiento facial o de matrículas, ya que esa sería la siguiente y última Fase a realizar de este extenso proyecto. La conectividad a Internet se limitó a la comunicación entre dispositivos IoT y la base de datos, evitando la exposición de datos sensibles. 
El sistema en si se centró en la gestión local y remota de información relevante para la seguridad y movilidad urbana. Las pruebas y validaciones se realizaron en un entorno controlado, asegurando la fiabilidad y estabilidad del prototipo antes de considerar una expansión a mayor escala.

---

### 4. Arquitectura del Sistema


#### 4.1. Arquitectura de Hardware

La arquitectura de hardware en la Fase 2 está compuesto por microcontroladores Arduino y Raspberry Pi, que actúan como nodos centrales y periféricos para la gestión de sensores y actuadores. Los sensores ultrasónicos, de gas, piezoeléctricos y botones de pánico están distribuidos estratégicamente en la maqueta física, pensada como si fuera a escala para así permitir la detección precisa de eventos críticos y fáciles de acudir. Los actuadores, como LEDs y zumbadores, se encargan de la señalización visual y sonora ante la ocurrencia de incidentes y alertas que disparen los sensores mediante IoT.

El cableado y encapsulamiento fueron optimizados para facilitar el acceso y la reparación de componentes, reduciendo el riesgo de fallos a la hora de dañar o desconectar cables y mejorando la eficiencia en las pruebas. La comunicación entre los microcontroladores se realiza mediante protocolos seriales y MQTT, asegurando la transmisión confiable de datos hacia la base de datos y las interfaces de usuario. Esta arquitectura permite la integración de nuevos dispositivos y la expansión del sistema sin afectar la funcionalidad principal.
#
<<<<<<< HEAD
![](../img/fase%202/Doc-2.jpg)
=======

>>>>>>> develop
#


#### 4.2. Arquitectura de Software

El software del sistema se compone de varios módulos que interactúan de manera coordinada para garantizar la adquisición, procesamiento y visualización eficiente de los datos. El firmware de Arduino se encarga de la lectura de sensores y la gestión de actuadores, enviando la información relevante a la Raspberry Pi y al sistema central. La Raspberry Pi ejecuta scripts en Python para la comunicación MQTT, el manejo de la API y la transmisión de datos hacia la base de datos MongoDB.

La visualización de los datos se realiza a través de una aplicación móvil en Flutter, el cual esta diseñado para mostrar en tiempo real una pagina de inicio, una pestaña del control de datos de los sensores, rutas de transporte, notificaciones, etc. 
#
<<<<<<< HEAD
![](../img/fase%202/S2-7.jpg)
#
![](../img/fase%202/S3-8.jpg)
#
![](../img/fase%202/S2-9.jpg)
#
![](../img/fase%202/S2-10.jpg)
#
![](../img/fase%202/S3-11.jpg)
#
![](../img/fase%202/Doc-16.jpg)
**NOTA:** Si no se configura bien correctamente la API, entonces no va a funcionar en su totalidad la app movil. 
#
![](../img/fase%202/Doc-15.jpg)
=======

>>>>>>> develop
#

#### 4.3. Flujo de Datos y Comunicación

El flujo de datos en la Fase 2 se diseñó para ser eficiente, seguro y escalable. Los sensores distribuidos en la maqueta capturan eventos físicos como movimiento, presencia de humo, vibraciones y activación de botones de pánico. Los microcontroladores procesan estos datos localmente y, en caso de detectar una situación relevante, activan los actuadores correspondientes y envían la información a la Raspberry Pi.

La Raspberry Pi actúa como intermediario, consolidando los datos y transmitiéndolos mediante MQTT y API al backend y la base de datos MongoDB. El backend procesa y almacena los datos, permitiendo su consulta y visualización en tiempo real a través de la aplicación móvil. Este flujo asegura que los usuarios reciban alertas inmediatas y puedan supervisar el estado del sistema desde cualquier dispositivo autorizado, facilitando la gestión eficiente de la seguridad y movilidad urbana.

#
<<<<<<< HEAD
![](../img/fase%202/1.jpg)
#
![](../img/fase%202/S3-6.jpg)
=======

>>>>>>> develop
#

## Diagramas 

1. Arquitectura general (Fase 2)
#
<<<<<<< HEAD
![](../img/fase%202/diagrama1.png)
=======

>>>>>>> develop
#

2. Flujo de mensajes
#
<<<<<<< HEAD
![](../img/fase%202/diagrama%202.png)
=======

>>>>>>> develop
#

## Link de Github

https://github.com/Ennero/ARQUI2B_2S2025_GA1

## Modelo 3D implementado en Maqueta Física
#
<<<<<<< HEAD
![](../img/fase%202/Doc-1.jpg)
=======

>>>>>>> develop
#

## 6. Descripción Del trabajo de Software implementado

El trabajo de software implementado en la Fase 2 fue fundamental para lograr la integración y el funcionamiento eficiente del sistema de monitoreo inteligente. Se desarrolló el firmware para los microcontroladores Arduino, encargado de la lectura de sensores y la gestión de actuadores como LEDs y zumbadores. Además, se programó la Raspberry Pi para actuar como intermediario en la comunicación, utilizando MQTT y una API para transmitir los datos hacia la base de datos MongoDB y la aplicación móvil en Flutter.

La aplicación móvil en Flutter fue diseñada para mostrar en tiempo real la información recolectada por los sensores, permitiendo a los usuarios visualizar el estado de los semáforos, rutas de transporte, notificaciones y alertas de seguridad. El sistema permite la activación de alarmas sonoras y visuales ante eventos críticos, como la detección de humo, sismos o la pulsación de botones de pánico. Todo el flujo de datos está optimizado para garantizar la respuesta inmediata y la confiabilidad en la transmisión de información.

### 6.1. Detalles de Funcionamiento

El sistema opera como un ecosistema cohesivo donde cada componente cumple una función específica. Por ejemplo, cuando un vehículo simulado avanza por su ruta, el sensor ultrasónico HC-SR04 detecta su presencia y el Arduino procesa el dato, activando los semáforos y enviando la información a la Raspberry Pi. Esta, a su vez, transmite los datos mediante MQTT y la API hacia la base de datos y la app móvil.

La aplicación móvil recibe y muestra en tiempo real los eventos detectados, como el paso de vehículos, la activación de alarmas por humo, sismos o botones de pánico. Los zumbadores y LEDs se activan localmente en la maqueta para alertar a los usuarios presentes, mientras que las notificaciones llegan a la app móvil para informar a los responsables del monitoreo. Este flujo garantiza que tanto la supervisión local como remota sean efectivas y rápidas.

### 6.2. Usos y Beneficios del Prototipo (Fase 2)

El prototipo desarrollado en la Fase 2 ofrece múltiples usos y beneficios que demuestran la efectividad de la integración tecnológica alcanzada:

#### Usos:

- **Prueba de Concepto (PoC):** Demuestra la viabilidad de un sistema de monitoreo urbano inteligente basado en IoT, con integración de sensores, microcontroladores y una app móvil.
- **Plataforma de Desarrollo y Pruebas:** Permite depurar y mejorar el código, la lógica de control y la comunicación entre dispositivos en un entorno controlado antes de escalar el sistema.
- **Herramienta de Demostración Visual y Práctica:** Facilita la explicación de conceptos de ciudades inteligentes y sistemas IoT a estudiantes, docentes y público general, mostrando la interacción entre hardware y software en tiempo real.

#### Anexos: 
#
<<<<<<< HEAD
![](../img/fase%202/Doc-3.jpg)
#
![](../img/fase%202/Doc-5.jpg)
#
![](../img/fase%202/Doc-7.jpg)
#
![](../img/fase%202/Doc-8.jpg)
#
![](../img/fase%202/Doc-10.jpg)
#
![](../img/fase%202/Doc-11.jpg)
#
![](../img/fase%202/Doc-12.jpg)
#
![](../img/fase%202/Doc-13.jpg)
#
![](../img/fase%202/Doc-14.jpg)
=======

>>>>>>> develop
#