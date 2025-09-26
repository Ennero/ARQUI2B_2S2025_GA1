import 'dart:math';
import 'package:flutter_application/core/time_filter.dart';

// Servicio simulado para pruebas sin un backend real.
// ! Funciona para el dashboard y el mapa.
// Genera datos aleatorios pero consistentes para cada filtro de tiempo.
// ! Si se quiere desactivar, simplemente cambiar booleano de data_repository.

class MockApiService {
  static int _currentBus1Distance = 0;
  static int _currentBus2Distance = 0;

  static Future<Map<String, dynamic>> fetchDashboardData({
    TimeFilter filter = TimeFilter.today,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (Random().nextDouble() < 0.1) {
      throw Exception('Error de conexión simulado.');
    }

    if (filter == TimeFilter.map) {
      // Obtenemos el valor actual para enviarlo en la respuesta.
      final bus1Distance = _currentBus1Distance;
      final bus2Distance = _currentBus2Distance;

      // Calculamos el siguiente valor para la próxima llamada.
      _currentBus1Distance += 40;
      _currentBus2Distance += 20;

      // Si el bus completó su ruta, lo reiniciamos a 0.
      // Los valores máximos (360 y 160) se basan en la lógica de tu mapa.
      if (_currentBus1Distance >= 360) {
        _currentBus1Distance = 0;
      }
      if (_currentBus2Distance >= 160) {
        _currentBus2Distance = 0;
      }

      return {
        "dist1": {"distance": bus1Distance},
        "dist2": {"distance": bus2Distance},
      };
    }

    if (filter == TimeFilter.today) {
      // PARA "HOY", LA ESTRUCTURA ES MÁS SIMPLE
      return {
        "summary": {
          "recorridoTransmetro": 57,
          "recorridoTransurbano": 13,
          "calidadAirePromedio": 158.5,
          "alertasCriticas": 2,
        },
        "airQualityChart": {
          "label": "Calidad del Aire (Hoy)",
          "dataPoints": List.generate(
            12,
            (i) => {
              "hour": i * 2,
              "value": 120.0 + Random().nextDouble() * 100,
            },
          ),
        },
      };
    } else {
      // PARA "SEMANA" Y "MES", LA ESTRUCTURA ES UNA LISTA DE MÉTRICAS ---
      bool isWeek = filter == TimeFilter.week;
      int entries = isWeek
          ? 7
          : 4; // 7 días para la semana, 4 "semanas" para el mes
      String entryLabel = isWeek ? "Día" : "Semana";

      // Creamos una función interna para generar los datos de cada métrica.
      List<Map<String, dynamic>> generateTimeSeries(
        double base,
        double variance,
      ) {
        return List.generate(entries, (i) {
          return {
            "label": "$entryLabel ${i + 1}",
            "value": base + Random().nextDouble() * variance,
          };
        });
      }

      var metrics = [
        {
          "title": "Recorrido Transmetro (km)",
          "timeSeries": generateTimeSeries(
            isWeek ? 50 : 350,
            isWeek ? 20 : 100,
          ),
        },
        {
          "title": "Recorrido Transurbano (km)",
          "timeSeries": generateTimeSeries(isWeek ? 15 : 105, isWeek ? 10 : 50),
        },
        {
          "title": "Calidad del Aire (PM)",
          "timeSeries": generateTimeSeries(150, 40),
        },
        {
          "title": "Alertas Críticas",
          "timeSeries": generateTimeSeries(isWeek ? 2 : 14, isWeek ? 3 : 10),
        },
      ];

      return {
        "summary": {
          "recorridoTransmetro": (metrics[0]['timeSeries'] as List)
              .map((d) => d['value'] as double)
              .reduce((a, b) => a + b),
          "recorridoTransurbano": (metrics[1]['timeSeries'] as List)
              .map((d) => d['value'] as double)
              .reduce((a, b) => a + b),
          "calidadAirePromedio":
              (metrics[2]['timeSeries'] as List)
                  .map((d) => d['value'] as double)
                  .reduce((a, b) => a + b) /
              entries,
          "alertasCriticas": (metrics[3]['timeSeries'] as List)
              .map((d) => d['value'] as double)
              .reduce((a, b) => a + b),
        },
        // Devolvemos la lista completa de métricas
        "detailedMetrics": metrics,
      };
    }
  }

  static Future<List<dynamic>> fetchTopPersons() async {
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 800));

    // SImulamos un posible error de conexión
    if (Random().nextDouble() < 0.1) {
      throw Exception("Error de conexión simulado al obtener personas");
    }

    // Generamos una lista de 10 personas con datos aleatorios
    return List.generate(10, (index) {
      return {
        "person_id": "PERSONA_${(index + 1).toString().padLeft(3, '0')}",
        "detection_count": Random().nextInt(20) + 1, // Detecciones entre 1 y 20
        "face_image_url": 'assets/image_simulation/${index + 1}.jfif',
      };
    });
  }

  static Future<List<dynamic>> fetchTopWeapons() async {
    // Simulamos un retraso de red
    await Future.delayed(const Duration(milliseconds: 800));

    // SImulamos un posible error de conexión
    if (Random().nextDouble() < 0.1) {
      throw Exception("Error de conexión simulado al obtener personas");
    }

    // Datos simulados estático spara consistencia visual
    final weaponsData = [
      {
        "weapon_type": "bayoneta",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/1.jfif",
      },
      {
        "weapon_type": "Cuchillo",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/2.jfif",
      },
      {
        "weapon_type": "Daga",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/3.jfif",
      },
      {
        "weapon_type": "Destornillador",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/4.jfif",
      },
      {
        "weapon_type": "Espada",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/5.jfif",
      },
      {
        "weapon_type": "Esapadín",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/6.jfif",
      },
      {
        "weapon_type": "Flecha",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/7.jfif",
      },
      {
        "weapon_type": "Hacha",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/8.jfif",
      },
      {
        "weapon_type": "Katana",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/9.jfif",
      },
      {
        "weapon_type": "Kunai",
        "detection_count": Random().nextInt(30) + 10, // Entre 10 y 40
        "last_seen": "2025-09-25T10:15:00Z",
        "image_url": "assets/weapons/10.jfif",
      },
    ];

    return weaponsData;
  }

  // Datos simulacdos de las infracciones del día
  static Future<List<dynamic>> fetchTodaysInfractions() async {
    // Simulamos un retraso en la red
    await Future.delayed(const Duration(milliseconds: 700));

    // Simular un error de conexión
    if (Random().nextDouble() < 0.1) {
      throw Exception("Error de conexión simulado al obtener personas");
    }

    final now = DateTime.now();
    return List.generate(10, (index) {
      final hour = 18 - index; // Horas hacia atrás desde las 6 PM
      final minute = Random().nextInt(60);
      final locationIndex = Random().nextInt(5);
      final locations = [
        "16 Av. y 4a Calle, Zona 1",
        "Calzada Roosevelt, Zona 7",
        "Blvd. Vista Hermosa, Zona 15",
        "Av. Las Américas, Zona 13",
        "Anillo Periférico, Zona 11",
      ];
      final plates = [
        "P-123ABC",
        "P-789XYZ",
        "C-456DEF",
        "M-321GHI",
        "P-987JKL",
      ];

      return {
        "plate": plates[Random().nextInt(plates.length)],
        // Formato ISO 8601 Z (UTC)
        "timestamp": DateTime.utc(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        ).toIso8601String(),
        "location": locations[locationIndex],
      };
    });
  }

  static String getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.map:
        return "Mapa";
      case TimeFilter.today:
        return "Hoy";
      case TimeFilter.week:
        return "Semana";
      case TimeFilter.month:
        return "Mes";
    }
  }
}
