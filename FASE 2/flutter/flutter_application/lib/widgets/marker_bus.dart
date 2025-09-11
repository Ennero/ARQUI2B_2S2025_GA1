import 'package:flutter/material.dart';

class MarkerBus extends StatelessWidget {
  final Offset relativePos; // posición relativa (0.0 a 1.0 en ancho/alto)
  final Size imageSize;     // tamaño del mapa mostrado
  final Offset imageOffset; // offset del mapa en pantalla (centrado)

  const MarkerBus({
    super.key,
    required this.relativePos,
    required this.imageSize,
    required this.imageOffset,
  });

  // Función para mostrar ventana emergente con foto y descripción
  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Transurbano"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/transurbano.jpg",
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            const Text(
              "Movilidad urbana para el día a día; la ruta azul que te acerca a los puntos clave del Centro Histórico y más allá.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convertir coordenadas relativas a absolutas
    final abs = Offset(
      imageOffset.dx + relativePos.dx * imageSize.width,
      imageOffset.dy + relativePos.dy * imageSize.height,
    );

    return Positioned(
      left: abs.dx - 25, // centra el icono
      top: abs.dy - 25,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: const Icon(
          Icons.directions_bus,
          color: Color.fromARGB(255, 125, 202, 253),
          size: 30,
        ),
      ),
    );
  }
}
