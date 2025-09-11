import 'dart:math';

enum TimeFilter { today, week, month }

class MockApiService {
  static Future<Map<String, dynamic>> fetchDashboardData({TimeFilter filter = TimeFilter.today}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (Random().nextDouble() < 0.1) throw Exception('Error de conexión simulado.');

    if (filter == TimeFilter.today) {
      // PARA "HOY", LA ESTRUCTURA ES MÁS SIMPLE
      return {
        "summary": {
          "recorridoTransmetro": 57,
          "recorridoTransurbano": 13,
          "calidadAirePromedio": 158.5,
          "alertasCriticas": 2
        },
        "airQualityChart": {
          "label": "Calidad del Aire (Hoy)",
          "dataPoints": List.generate(12, (i) => {"hour": i * 2, "value": 120.0 + Random().nextDouble() * 100})
        }
      };
    } else {
      // --- NUEVO: PARA "SEMANA" Y "MES", LA ESTRUCTURA ES UNA LISTA DE MÉTRICAS ---
      bool isWeek = filter == TimeFilter.week;
      int entries = isWeek ? 7 : 4; // 7 días para la semana, 4 "semanas" para el mes
      String entryLabel = isWeek ? "Día" : "Semana";

      // Creamos una función interna para generar los datos de cada métrica.
      List<Map<String, dynamic>> generateTimeSeries(double base, double variance) {
        return List.generate(entries, (i) {
          return {"label": "$entryLabel ${i + 1}", "value": base + Random().nextDouble() * variance};
        });
      }

      var metrics = [
        {
          "title": "Recorrido Transmetro (km)",
          "timeSeries": generateTimeSeries(isWeek ? 50 : 350, isWeek ? 20 : 100),
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
        }
      ];

      return {
        // El resumen ahora se calcula a partir de los datos detallados
        "summary": {
          "recorridoTransmetro": (metrics[0]['timeSeries'] as List).map((d) => d['value'] as double).reduce((a, b) => a + b),
          "recorridoTransurbano": (metrics[1]['timeSeries'] as List).map((d) => d['value'] as double).reduce((a, b) => a + b),
          "calidadAirePromedio": (metrics[2]['timeSeries'] as List).map((d) => d['value'] as double).reduce((a, b) => a + b) / entries,
          "alertasCriticas": (metrics[3]['timeSeries'] as List).map((d) => d['value'] as double).reduce((a, b) => a + b),
        },
        // Devolvemos la lista completa de métricas
        "detailedMetrics": metrics,
      };
    }
  }
  
  static String getFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today: return "Hoy";
      case TimeFilter.week: return "Semana";
      case TimeFilter.month: return "Mes";
    }
  }
}

