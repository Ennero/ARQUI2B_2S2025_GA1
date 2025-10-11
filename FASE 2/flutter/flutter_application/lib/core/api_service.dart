import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application/core/time_filter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiService {
  // URL del backend
  static String get baseUrl => dotenv.env['BASE_URL'] ?? "http://localhost:8080";

  // Obtiene los datos del dashboard desde el backend
  static Future<Map<String, dynamic>> fetchDashboardData({
    TimeFilter filter = TimeFilter.today,
  }) async {


    if (filter == TimeFilter.map) {
      final Uri url = Uri.parse("$baseUrl/live/bus/distances");
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // Decodifico la respuesta directa del endpoint de distancias.
          final rawData = json.decode(response.body);

          // El valor pasa de double a int.
          final int dist1 = (rawData['dist1'] ?? 0.0).toInt();
          final int dist2 = (rawData['dist2'] ?? 0.0).toInt();

          return {
            "dist1": {"distance": dist1},
            "dist2": {"distance": dist2}
          };
        } else {
          throw Exception("Error del servidor: ${response.statusCode}");
        }
      } catch (e) {
        throw Exception("Fallo al conectar el servidor. $e");
      }
    }


    // Convierte el enum a un string de la API
    final String filterQuery;
    switch (filter) {
      case TimeFilter.map:
        filterQuery = "map";
        break;
      case TimeFilter.today:
        filterQuery = "today";
        break;
      case TimeFilter.week:
        filterQuery = "week";
        break;
      case TimeFilter.month:
        filterQuery = "month";
        break;
    }

    final Uri url = Uri.parse("$baseUrl/dashboard?filter=$filterQuery");

    try {
      // realizamos la petición GET a la URL
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // Comprobamos si la respuesta es exitosa
      if (response.statusCode == 200) {
        // decodificamos el json y lo devolvemos
        return json.decode(response.body);
      } else {
        // Si el servidor responde con un error
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      // Capturamos cualquier error
      throw Exception("Fallo al conectar el servidor. $e");
    }
  }

  // Obtenemos el texto del label
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
