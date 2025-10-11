import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
<<<<<<< HEAD
  static String get baseUrl =>
      dotenv.env['NOTIF_BASE_URL'] ??
      dotenv.env['BASE_URL'] ??
      'http://54.160.158.12:8000';

=======
  // Lee la URL del servicio de notificaciones desde .env
  // Preferimos NOTIF_BASE_URL, si no existe usamos BASE_URL, y como último recurso localhost
  static String get baseUrl =>
      dotenv.env['NOTIF_BASE_URL'] ??
      dotenv.env['BASE_URL'] ??
      'http://localhost:8000';


  // Headers para intentar evitar CORS
>>>>>>> feature/ai
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  static Future<List<NotificationModel>> getNotifications() async {
    try {
<<<<<<< HEAD
      print('Conectando a: $baseUrl/notifications');
=======
      print('🔄 Conectando a: $baseUrl/notifications');
>>>>>>> feature/ai

      final response = await http
          .get(Uri.parse('$baseUrl/notifications'), headers: headers)
          .timeout(const Duration(seconds: 10));

<<<<<<< HEAD
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        
        final notifications = jsonResponse
            .map((jsonItem) => NotificationModel.fromJson(jsonItem))
            .toList();
            
        // Ordenar descendente por timestamp
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return notifications;
=======
      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((jsonItem) => NotificationModel.fromJson(jsonItem))
            .toList();
>>>>>>> feature/ai
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        'Error CORS. Solución:'
        '\n1. Instalar extensión "Allow CORS" en Chrome'
        '\n2. Configurar CORS en el backend'
        '\n3. Error detallado: $e',
      );
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> feature/ai
