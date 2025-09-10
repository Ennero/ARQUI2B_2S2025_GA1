import 'dart:convert';
import 'package:http/http.dart' as http;

// Enum para representar los filtros de tiempo
enum TimeFilter { today, week, month }

class ApiService{
  // URL del backend
  static const String apiIp = '10.0.2.2'; 
  static const String apiPort = '8000';
  static const String baseUrl = 'http://$apiIp:$apiPort';

  // Obtiene los datos del dashboard desde el backend
  static Future <Map<String, dynamic>> fetchDashboardData({TimeFilter filter = TimeFilter.today}) async {
    // Convierte el enum a un string de la API
    final String endpoint;
    switch (filter) {
      case TimeFilter.today:
        endpoint = "/analytics/daily";
        break;
      case TimeFilter.week:
        endpoint = "/analytics/weekly";
        break;
      case TimeFilter.month:
        endpoint = "/analytics/monthly";
        break;
    }

    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      // realizamos la petición GET a la URL
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // Comprobamos si la respuesta es exitosa
      if (response.statusCode == 200){
        // decodificamos el json y lo devolvemos
        final String responseBody = utf8.decode(response.bodyBytes);
        print(responseBody);
        return json.decode(responseBody);
      } else {
        // Si el servidor responde con un error
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e){
      // Capturamos cualquier error
      throw Exception("Fallo al conectar el servidor. $e");
    }
  }

  // Obtenemos el texto del label
  static String getFilterLabel(TimeFilter filter) {
    switch (filter){
      case TimeFilter.today: return "Hoy";
      case TimeFilter.week: return "Semana";
      case TimeFilter.month: return "Mes";
    }
  }

}