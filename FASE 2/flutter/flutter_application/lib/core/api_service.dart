import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application/core/time_filter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  // Obtiene los datos del dashboard desde el backend
  static Future<Map<String, dynamic>> fetchDashboardData({
    TimeFilter filter = TimeFilter.today,
  }) async {
    if (filter == TimeFilter.map) {
      final Uri url = Uri.parse("$baseUrl/live/bus/distances");
      print('🔄 [ApiService-Map] Conectando a: $url');

      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 10));
        print('📡 [ApiService-Map] Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final rawData = json.decode(response.body);
          final int dist1 = (rawData['dist1'] ?? 0.0).toInt();
          final int dist2 = (rawData['dist2'] ?? 0.0).toInt();
          return {
            "dist1": {"distance": dist1},
            "dist2": {"distance": dist2},
          };
        } else {
          throw Exception("Error del servidor: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Fallo al conectar el servidor del mapa. $e");
      }
    }

    final String filterQuery;
    switch (filter) {
      case TimeFilter.map:
        filterQuery = "map";
        break;
      case TimeFilter.today:
        filterQuery = "daily";
        break;
      case TimeFilter.week:
        filterQuery = "weekly";
        break;
      case TimeFilter.month:
        filterQuery = "monthly";
        break;
    }

    final Uri url = Uri.parse("$baseUrl/analytics/$filterQuery");
    print('🔄 [ApiService-Dashboard] Conectando a: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('📡 [ApiService-Dashboard] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Fallo al conectar el servidor del dashboard. $e");
    }
  }

  // Otiene el ranking de personas más detectadas
  static Future<List<dynamic>> fetchTopPersonas() async {
    final Uri url = Uri.parse("$baseUrl/analytics/top-persons");
    print('🔄 [ApiService-Fase3] Conectando a: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      print(
        '📡 [ApiService-Fase3] Status Top Personas: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
          "Error del servidor al obtener top de persona: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception('Fallo al conectar para obtener top de personas. $e');
    }
  }

  // Obtiene el ranking de armas más detectada
  static Future<List<dynamic>> fetTopWeapons() async {
    final Uri url = Uri.parse("$baseUrl/analytics/top-weapons");
    print('🔄 [ApiService-Fase3] Conectando a: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      print('📡 [ApiService-Fase3] Status Top Armas: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
          "Error del servidor al obtener el top de armas. ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception('Fallo al obtener el top de armas. $e');
    }
  }

  // Obtiene las infracciones del tráfico del día
  static Future<List<dynamic>> fetchTodaysInfractions() async {
    final Uri url = Uri.parse("$baseUrl/analytics/infractions-today");
    print('🔄 [ApiService-Fase3] Conectando a: $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      print(
        '📡 [ApiService-Fase3] Infracciones del día: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
          "Error del servidor al obtener infracciones. ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Fallo al conectar para obtener infracciones. $e");
    }
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
