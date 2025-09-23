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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fuente: json['fuente'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: false,
    );
  }

  // Método para debugging
  @override
  String toString() {
    return 'NotificationModel{id: $id, tipo: $tipo, titulo: $titulo}';
  }
}