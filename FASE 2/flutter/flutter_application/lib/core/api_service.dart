import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application/core/time_filter.dart';

class ApiService {
  // URL del backend
  static const String baseUrl = "URL del backend";

  // Obtiene los datos del dashboard desde el backend
  static Future<Map<String, dynamic>> fetchDashboardData({
    TimeFilter filter = TimeFilter.today,
  }) async {
    // Convierte el enum a un string de la API
    final String filterQuery;
    switch (filter) {
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
      case TimeFilter.today:
        return "Hoy";
      case TimeFilter.week:
        return "Semana";
      case TimeFilter.month:
        return "Mes";
    }
  }
}
