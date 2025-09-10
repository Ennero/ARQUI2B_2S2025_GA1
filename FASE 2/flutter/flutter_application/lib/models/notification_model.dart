class NotificationModel {
  final String id;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String fuente;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fuente,
    required this.timestamp,
    this.isRead = false,
  });

  // Método para crear una instancia desde JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fuente: json['fuente'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: false, // Por defecto no leída
    );
  }

  // Método para convertir a JSON (útil si necesitas enviar datos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'fuente': fuente,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}