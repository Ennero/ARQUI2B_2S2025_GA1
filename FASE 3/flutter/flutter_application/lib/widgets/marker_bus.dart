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

  // Función para mostrar ventana emergente con tabla de ruta
  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ruta Transurbano"),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Parada")),
              DataColumn(label: Text("Descripción")),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text("1")),
                DataCell(Text("Palacio Nacional de la Cultura")),
              ]),              
              DataRow(cells: [
                DataCell(Text("2")),
                DataCell(Text("David Campero")),
              ]),              
            ],
          ),
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
      left: abs.dx - 20, // ajuste con size 30
      top: abs.dy - 20,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: const Icon(
          Icons.directions_bus,
          color: Colors.blueAccent,
          size: 30,
        ),
      ),
    );
  }
}
