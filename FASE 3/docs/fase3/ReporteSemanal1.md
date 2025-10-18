# 📝 Reporte Semanal 1 - Proyecto IoT Zona 1 - Fase 3
**Fecha:** 05 de Octubre de 2025  
**Clase:** Arquitectura de Computadoras y Ensambladores 2  
**Fase:** Planeación y Organización Inicial (Fase 3/Primera Semana)
## Grupo 1 - Tutor 1

| Nombre de los integrantes                   |
|---------------------------------------------|
| MARCOS DANIEL BONIFASI DE LEÓN              |
| ALFREDO EMMANUEL DOMINGUEZ RODRIGUEZ        |
| ALVARO HUMBERTO GARCIA OLIVAREZ             |
| ESTEBAN SANCHEZ TUCHEZ                      |
| JUAN JOSE SANDOVAL RUIZ                     |
| DAVID ESTUARDO BARRIOS RAMIREZ              |
| ENNER ESAÍ MENDIZABAL CASTRO                |

---
#

### 1. Planificación Semanal del Proyecto
En esta semana nos juntamos en un meet donde nos pusimos a organizar como se iba a distribuir el trabajo y el tiempo en el que se realizaría, lo que conlleva, a también los horarios de reunirnos y en dónde. Esto con el fin de poder llevar en un buen camino la realización del proyecto de forma calmada, organizada y comoda para todos los integrantes del grupo puedan trabajar con tiempo sin presión alguna. 

![Reunion meet](../img/fase%203/reporteS1/s1-1.jpg)
#

---

### Tecnologías implementadas y a implementar:
En el proyecto de 3 fases se contempla una arquitectura tecnológica integral que combina hardware embebido, procesamiento distribuido y visualización de datos avanzada. En el núcleo del sistema se encuentra la Raspberry Pi, configurada como servidor API para recibir y almacenar los resultados de detecciones enviadas por laptops externas, las cuales ejecutan modelos de Inteligencia Artificial seleccionadas para identificar en la maqueta fisica placas vehiculares, rostros en "listas negras" y armas blancas. 
#

![IA](../img/fase%203/reporteS1/s1-2.jpg)

La comunicación entre dispositivos se realiza mediante el protocolo MQTT, garantizando eficiencia y desacoplamiento.
El Arduino que usamos desde el inicio mantiene su rol como interfaz física, activando alertas sonoras según los comandos recibidos que tiene configuradas.
#

![MQTT](../img/fase%203/reporteS1/s1-3.png)

Por el otro lado, en el área de trabajo en el software, se desarrolló una API RESTful la cual, respaldada por una base de datos NoSQL (MongoDB), recibe las alertas/mensajes de nuestra aplicación móvil en Flutter la cuál se actualiza para mostrar alertas en tiempo real, rankings analíticos y datos históricos. 
#

![MONGODB](../img/fase%203/reporteS1/s1-4.png)

Por último, Grafana se empleará para visualizar métricas en paneles dinámicos; además, se implementará un sistema de códigos QR vinculado a una web informativa en la nube, fomentando el turismo cultural en la maqueta urbana simulada.
#


![Grafana](../img/fase%203/reporteS1/s1-5.png)

#


### 2. Distribución de Roles en el equipo

| Nombre                                      | Actividad                        | Resumen de lo que hará cada uno                                      |
|---------------------------------------------|----------------------------------|---------------------------------------------------------------------|
| MARCOS DANIEL BONIFASI DE LEÓN              | Implementación de Inteligencia Artificial y Creación de API Local          |   Implementación de IA para captura de video y Creación de API para manejar la IA en las Laptops conectadas con las cámaras correspondientes       |
| ALFREDO EMMANUEL DOMINGUEZ RODRIGUEZ        | Maqueta, Realización de Grafana y encargado de la documentación.          | Toques finales en la maqueta, y realización de Grafana          |
| ALVARO HUMBERTO GARCIA OLIVAREZ             | Sitio web informativo y Maqueta             | Desarrollo de interfaz web con información clara de los centros historicos en la maqueta fisica accediendo a la pagina web con un QR y apoyo en los últimos retoques en la maqueta física.                            |
| ESTEBAN SANCHEZ TUCHEZ                      |    Crear Backend, arreglar la base de datos y trabajo en Arduino             |   Crear Servidor en Raspberry (Backend), arreglar la base de datos de MongoDB para recibir y guardar correctamente los datos como se espera y apoyar en la mejora y últimos toques de Arduino en la maqueta física      |
| JUAN JOSE SANDOVAL RUIZ                     | App Flutter                |  Implementación de nuevas alertas en tiempo real de flutter.                           |
| DAVID ESTUARDO BARRIOS RAMIREZ              | App Flutter                      | Desarrollo de mejoras de errores en la interfaz y lógica en Flutter y modificaciones en el dashboard de la app.                            |
| ENNER ESAÍ MENDIZABAL CASTRO                |  Maqueta, Arduino, API (de la Nube)         |  Apoyo en los arreglos físicos y de cableado en la maqueta física y en el arduino y arreglar la API de la nube.    |


---
#
#

### 3. Definición del Cronograma de Trabajo

El cronograma de trabajo se ha estructurado en tres semanas intensivas para maximizar la eficiencia y cumplir con los objetivos de la Fase 3 del proyecto IoT. 
La primera semana (29 de septiembre - 3 de octubre) nos efocamos en la distribución del trabajo del proyecto y que cada quien investigue por su cuenta el trabajo que debe realizar.

La segunda semana (6 de octubre - 10 de octubre) tenemos planeada las configuración iniciales del entorno de desarrollo, implementación inicial de los modelos de IA para detección de placas vehiculares y rostros, el desarrollo paralelo de mejoras en la aplicación Flutter, entre otras actividades. 

Las reuniones presenciales se han programado los martes, jueves y sábados de cada semana en las instalaciones universitarias con un seguimiento de reportes semanales en los domingos para evaluar el progreso de cada uno que se ira anotando para así resolver impedimentos técnicos que puedan surgir durante el desarrollo de esta fase final.
#
![Cronograma](../img/fase%203/reporteS1/s1-7.jpg)
#
#

## 4. Próximas Actividades
- Reuniones del grupo para empezar a trabajar en las actividades repartidas con cada integrante.
- Implementación de nuevas tecnologías descritas anteriormente para la realización final del proyecto. 
- Realización de prueba y error organizadas y con tiempo para poder realizar el proyecto con calma y con seguridad. 
#

![Reuniones](../img/fase%203/reporteS1/s1-6.jpg)