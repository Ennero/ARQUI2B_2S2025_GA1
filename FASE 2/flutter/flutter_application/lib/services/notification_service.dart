import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'https://localhost:5000/api/alertas/recientes'; // Change the url

  // Headers para la solicitud
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Obtain notifications from backend (last 15 notifications)
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alertas/recientes'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final List<dynamic> jsonResponse = json.decode(response.body);
        
        // Convertir cada item JSON a NotificationModel
        final allNotifications = jsonResponse.map((jsonItem) => 
          NotificationModel.fromJson(jsonItem)
        ).toList();

        // Ordenar por fecha (más recientes primero) y tomar solo las 15 más recientes
        allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return allNotifications.take(15).toList();
      } else {
        // Manejar errores de la API
        throw Exception('Error al cargar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores de conexión
      throw Exception('Error de conexión: $e');
    }
  }

  // Método alternativo: Solicitar directamente al backend que limite los resultados
  static Future<List<NotificationModel>> getNotificationsLimited() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alertas/recientes?limit=15'), // Si el backend soporta parámetro limit
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((jsonItem) => 
          NotificationModel.fromJson(jsonItem)
        ).toList();
      } else {
        throw Exception('Error al cargar notificaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}