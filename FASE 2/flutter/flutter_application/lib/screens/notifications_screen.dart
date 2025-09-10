import 'package:flutter/material.dart';
import '../models/notification_model.dart';
// import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final List<NotificationModel> loadedNotifications =
          // Obtain notifications from the backend
          // await NotificationService.getNotifications();   
          [
            NotificationModel(
              id: "id_1234",
              tipo: "PANICO",
              titulo: "Botón de Pánico Activado",
              descripcion: "Se ha recibido una alerta de pánico desde la fuente PANICO3.",
              fuente: "PANICO3",
              timestamp: DateTime.parse("2025-09-05T16:21:15Z") // Formato ISO 8601
            ),
            NotificationModel(
              id: "alrt_7c3a1",
              tipo: "INFRACCION",
              titulo: "Infracción de Semáforo Detectada",
              descripcion: "Un vehículo ha cruzado en rojo en el punto de control INFRAB.",
              fuente: "INFRAB",
              timestamp: DateTime.parse("2025-09-05T16:20:55Z")
            ),
            NotificationModel(
              id: "alrt_b4e22",
              tipo: "SISMO",
              titulo: "Alerta Sísmica",
              descripcion: "Se ha detectado una vibración anómala. Protocolos de seguridad activados.",
              fuente: "SISMO",
              timestamp: DateTime.parse("2025-09-05T15:10:02Z")
            )
          ];

      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Método para obtener el icono según el tipo de notificación
  IconData _getNotificationIcon(String tipo) {
    switch (tipo) {
      case 'PANICO':
        return Icons.warning_amber_rounded;
      case 'INFRACCION':
        return Icons.traffic_rounded;
      case 'SISMO':
        return Icons.vibration_rounded;
      default:
        return Icons.notifications;
    }
  }

  // Método para obtener el color según el tipo de notificación
  Color _getNotificationColor(String tipo) {
    switch (tipo) {
      case 'PANICO':
        return Colors.red;
      case 'INFRACCION':
        return Colors.orange;
      case 'SISMO':
        return Colors.yellow[700]!;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas y Notificaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No hay alertas recientes',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItem(
            notification: notification,
            onTap: () {
              _showNotificationDetails(context, notification);
            },
            getIcon: _getNotificationIcon,
            getColor: _getNotificationColor,
          );
        },
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.titulo),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.descripcion),
            const SizedBox(height: 16),
            Text('Tipo: ${notification.tipo}'),
            Text('Fuente: ${notification.fuente}'),
            Text('Fecha: ${_formatDetailedDate(notification.timestamp)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final IconData Function(String) getIcon;
  final Color Function(String) getColor;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.getIcon,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead
          ? Colors.grey[100]
          : getColor(notification.tipo).withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColor(notification.tipo),
          child: Icon(
            getIcon(notification.tipo),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.titulo,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
            color: getColor(notification.tipo),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.descripcion,
              style: const TextStyle(color: Colors.grey)
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.source, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  notification.fuente,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  _formatDate(notification.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const CircleAvatar(radius: 5, backgroundColor: Colors.red),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
