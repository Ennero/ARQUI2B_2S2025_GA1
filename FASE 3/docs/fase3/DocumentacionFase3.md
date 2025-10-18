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

#
#
# Sistema Inteligente de Seguridad y Gestión de Tráfico Urbano  
### Fase 3 – Integración de IA y Optimización Final

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

## 1. Resumen

La Fase 3 del proyecto “Sistema Inteligente de Seguridad y Gestión de Tráfico Urbano” representa la culminación de un sistema IoT potenciado con módulos de inteligencia artificial (IA) orientados al monitoreo urbano y la seguridad ciudadana. 

Esta etapa final se centra en la implementación de cámaras inteligentes que permiten reconocer **rostros, placas vehiculares y armas blancas**; esto con el objetivo de emitir almacenar los datos encontrados en una base de datos NoSQL para su posterior análisis y visualización de datos en Grafana. 

Durante el desarrollo de esta fase, se integraron tecnologías de visión por computadora ejecutadas en computadoras externas, las cuales se comunican con una Raspberry Pi que actúa como nodo central y servidor API. Esta a su vez coordina la comunicación con un Arduino, responsable de activar las alertas físicas en la maqueta. Se realizaron además mejoras estéticas y funcionales en el prototipo físico de nuestra maqueta urbana, optimizando el cableado y encapsulamiento de los componentes.

El sistema fue validado mediante pruebas que confirmaron la correcta detección de eventos críticos y la transmisión fluida de datos hacia la aplicación móvil desarrollada en **Flutter**, que visualiza las alertas, estadísticas e historial de eventos. Con esta implementación, el equipo logró un prototipo funcional y escalable que ejemplifica cómo la integración de **IoT e IA** puede contribuir al desarrollo de ciudades inteligentes seguras y sostenibles.

---

## 2. Introducción

### 2.1. Justificación y Planteamiento del Problema

La creciente complejidad del tránsito urbano y el aumento de incidentes relacionados con la inseguridad ciudadana requieren soluciones tecnológicas innovadoras que integren monitoreo, automatización y análisis inteligente. En respuesta a esta necesidad, el objetivo general de este proyecto se logra plasmar en esta última Fase 3 del proyecto, que propone un sistema de vigilancia urbana inteligente, diseñado para detectar comportamientos o elementos de riesgo como personas en lista negra, infracciones vehiculares y armas blancas.

El proyecto se fundamenta en la comunicación IoT entre dispositivos, combinando hardware embebido y software distribuido. Mediante el uso de **Arduino, Raspberry Pi, cámaras con IA y una aplicación móvil Flutter**, se logra un ecosistema que captura, procesa y presenta información en tiempo real. Esto permite automatizar respuestas frente a eventos detectados, incrementando la eficiencia y la seguridad en entornos urbanos como el Centro Histórico de la Ciudad de Guatemala.

![1](../img/fase%203/docuF3/6-DF3.png)

---

### 2.2. Objetivos del Proyecto

#### **Objetivo General**

Diseñar e implementar un sistema inteligente de monitoreo urbano que integre módulos de Inteligencia Artificial con una arquitectura IoT distribuida, capaz de detectar, registrar y visualizar en tiempo real eventos relacionados con la seguridad y el tráfico urbano, utilizando Arduino, Raspberry Pi, MQTT, API REST y Flutter como tecnologías base.
#
![2](../img/fase%203/docuF3/7-DF3.png)

#
#### **Objetivos Específicos**

1. **Integrar:** modelos de IA en laptops externas para el reconocimiento de placas, rostros y armas blancas, comunicando los resultados al servidor central en la Raspberry Pi.  

2. **Desarrollar y optimizar:** la API en la Raspberry Pi para recibir, validar y almacenar las detecciones en una base de datos NoSQL, y enviar alertas físicas mediante el Arduino. 

3. **Actualizar** la aplicación móvil en Flutter para mostrar alertas, estadísticas y datos históricos en tiempo real.  

4. **Mejorar:** la maqueta física mediante la organización del cableado y encapsulamiento final de los componentes, garantizando una presentación limpia y funcional final. 

5. **Validar:** la comunicación entre todos los módulos mediante pruebas funcionales e integrales, asegurando la respuesta automatizada y la correcta interacción entre sensores, IA y app.  

6. **Implementar:** nuevas tecnologías de visualización de datos (Grafana) y datos extras sobre las estructuras del Centro Histórico en zona 1 mediante una aplicación de acceso con QR.

#
#
## 3. Alcance y Delimitaciones (Fase 3)

### 3.1. Alcance Funcional

El sistema desarrollado en esta fase abarca:

- La captura y procesamiento de video en tiempo real mediante cámaras conectadas a laptops que ejecutan modelos de IA, cada una ejecutando diferentes modelos de IA.  

- Comunicación directa con la Raspberry Pi para el envío de resultados de las cámaras de detección y almacenar los datos en nuestra base de datos de MongoDB. 

- Lograr realizar la visualización de alertas y datos históricos a través de la aplicación móvil de Flutter; la página web desarrollada en computadora "Sitio web informativo" con acceso con códigos QR y el panel analítico en **Grafana**. 

- Una gestión centralizada y organizada mediante API REST, permitiendo la integración de múltiples fuentes y tipos de detecciones.  

### 3.2. Delimitaciones y Exclusiones

- La detección de IA se limita a tres tipos de objetos: placas vehiculares, rostros y armas (todas estas que se distribuyen en las listas blancas y negras).  

- El sistema no realiza procesamiento de video directamente en la Raspberry Pi, sino en computadoras externas conectadas a celulares para optimizar el rendimiento de visualización de datos y comodidad en ella. 

- No se implementan mecanismos de intervención automática externa (como control vehicular o cierre de vías dentro de la maqueta).  

---

## 4. Arquitectura del Sistema

### 4.1. Arquitectura de Hardware

El hardware principal está compuesto por:  
- **Raspberry Pi:** como nodo central, servidor API y coordinador de comunicación.  

- **Laptops:** como nodos de procesamiento de IA, ejecutando modelos de detección.  

- **Arduino:**, encargado de gestionar actuadores físicos como LEDs y zumbadores.  

- **Sensores y actuadores previos:** (ultrasónicos, de gas, pánico, semáforos, buzzer) integrados a las nuevas funciones de software.

- **Cámaras de teléfonos móviles:** utilizadas como fuentes de video para las detecciones de listas negras/blancas conectadas mediante una red de internet única entre la laptop y el celular. 

### 4.2. Visualización de datos en Grafana

#### Link de ruta en Grafana: 

https://mimamamemima20.grafana.net/public-dashboards/9b227930628c43b3a5ae97b4384967c6


---
#

En esta última fase, Grafana cumple un rol esencial dentro del sistema al funcionar como la plataforma central de monitoreo y análisis visual de los datos recolectados y procesados por la infraestructura IoT e inteligencia artificial.

A través de un panel dashboard dinámico e interactivo que se conecta a nuestra base de datos en MongoDB, Grafana accede a las colecciones de nuestro proyecto, permitiendo observar en tiempo real distintos indicadores clave del sistema, ofreciendo una representación clara del estado general de la ciudad inteligente simulada.

Entre las principales métricas y visualizaciones implementadas se incluyen:

- Calidad del aire: muestra lecturas obtenidas desde el sensor de gas (MQ-135) y el valor del dato de la calidad del aire. 

- Detección de objetos mediante IA: paneles específicos para visualizar las detecciones de placas vehiculares, rostros y armas blancas detectadas, con gráficos de frecuencia y porcentaje de ocurrencia.

- Alertas críticas: visualización de eventos generados por botones de pánico, detección de incendios o sismos, con indicadores de tiempo y localización aproximada.

- Rutas de buses simuladas: gauges que muestran el desplazamiento y ubicación de los autobuses modelados dentro del entorno urbano, facilitando el control del flujo de transporte. Esto mediante un número que representa la posición del transmetro/transurbano. 

Esta integración permite una supervisión unificada de todos los subsistemas, mejorando la interpretación de los datos y facilitando la toma de decisiones. Además, Grafana ofrece la ventaja de almacenar históricos y generar reportes visuales, convirtiéndose en una herramienta analítica esencial para el proyecto en su fase final.

![grafana](../img/fase%203/docuF3/13-DF3.png)

#

![GRafana](../img/fase%203/docuF3/14-DF3.png)

#
#

### 4.3. Flujo de Datos y Comunicación

Estos pasos son el cómo se comunican nuestros equipos que son nuevos en implementarse en nuestro proyecto: 

1. La laptop capta el video mediante el uso de una cámara externa, procesa la imagen con IA y envía un payload JSON con los resultados a la API en la Raspberry Pi. 

2. Luego, la Raspberry valida los datos, los guarda en la base de datos y envía un comando al Arduino según el tipo de alerta.  

3. Entonces, el Arduino activa la señal física correspondiente (luz o zumbador).  

4. Por último, la aplicación de Flutter y el dashboard de Grafana consultan la API para mostrar alertas y análisis en tiempo real.  

#
#

## 5. Descripción del Trabajo de Software Implementado

### 5.1. Detalles de Funcionamiento

El sistema ejecuta modelos de detección visual en tiempo real utilizando IA local. Cada detección se clasifica en colecciones separadas (siendo estas las placas, personas y armas) y se envía a la Raspberry Pi para su procesamiento central.  

La API se encarga de almacenar los datos, mientras que la app Flutter los visualiza y notifica al usuario.  
El flujo es estable, modular y escalable, permitiendo futuras expansiones de IA o sensores sin alterar la arquitectura principal.

### 5.2. Usos y Beneficios del Prototipo (Fase 3)

#### **Usos:**
- Monitoreo urbano inteligente en tiempo real.  
- Identificación automática de riesgos.  
- Registro histórico de eventos para análisis posterior.  
- Visualización intuitiva para el usuario ciudadano o autoridad.

#### **Beneficios:**
- Mejora la seguridad y control en zonas críticas.  
- Demuestra la integración efectiva de IoT + IA.  
- Es un modelo educativo y escalable aplicable a proyectos reales de ciudades inteligentes.  

---

## 6. Diagramas
#
### Capas de MQTT
![](../img/fase%203/docuF3/diagrama%20capas%20mqtt.png)

#
#### Diagrama de interacción de componentes 
![](../img/fase%203/docuF3/digrama%20interacción%20de%20componentes.png)

#
#### Sensores con Arduino 
![](../img/fase%203/docuF3/Sensores%20con%20Arduino.png)

#
#

## 7. Modelo 3D Implementado en Maqueta Física

#
![](../img/fase%203/docuF3/1-DF3.jpg)
#
![](../img/fase%203/docuF3/2-DF3.jpg)
#
![](../img/fase%203/docuF3/3-DF3.jpg)
#
![](../img/fase%203/docuF3/4-DF3.jpg)
#
![](../img/fase%203/docuF3/5-DF3.jpg)
#
#

## 8. Link de GitHub (Repositorio general y de Sitio Web)

### Repositorio del proyecto con código fuente y documentación:  

#### Sitio Web: 

https://agarcia17948.github.io/ARQUI2_F3/biblioteca_nacional.html

#
#### Vista inicial del Sitio web: 
![](../img/fase%203/docuF3/8-DF3.png)

#### Vistas en cada ventana del sitio web: 

![palacio](../img/fase%203/docuF3/9-DF3.png)
#
![PORTAL](../img/fase%203/docuF3/10-DF3.png)
#
![biblioteca central](../img/fase%203/docuF3/11-DF3.PNG)

#
#

## 9. Anexos
#
![repo sitio web](../img/fase%203/docuF3/12-DF3.png)
#
![21](../img/fase%203/docuF3/21-DF3.png)
#
![alt text](../img/fase%203/docuF3/16-DF3.png)
#
![alt text](../img/fase%203/docuF3/15-DF3.png)
#
![alt text](../img/fase%203/docuF3/17-DF3.png)
#
![reuniono](../img/fase%203/docuF3/18-DF3.png)
#
![MONGO](../img/fase%203/docuF3/19-DF3.png)
#
![reuniono](../img/fase%203/docuF3/20-DF3.png)
#
![ia](../img/fase%203/docuF3/22-DF3.png)
#
![AI rutas](../img/fase%203/docuF3/23-DF3.png)
#
![MAIN IA](../img/fase%203/docuF3/24-DF3.png)