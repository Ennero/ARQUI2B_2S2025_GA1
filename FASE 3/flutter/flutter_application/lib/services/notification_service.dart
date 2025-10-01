import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  // Lee la URL del servicio de notificaciones desde .env
  // Preferimos NOTIF_BASE_URL, si no existe usamos BASE_URL, y como último recurso localhost
  static String get baseUrl =>
      dotenv.env['NOTIF_BASE_URL'] ??
      dotenv.env['BASE_URL'] ??
      'http://18.220.53.96';


  // Headers para intentar evitar CORS
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      print('🔄 Conectando a: $baseUrl/notifications');

      final response = await http
          .get(Uri.parse('$baseUrl/notifications'), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((jsonItem) => NotificationModel.fromJson(jsonItem))
            .toList();
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
}