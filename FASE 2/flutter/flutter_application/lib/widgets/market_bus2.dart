import 'package:flutter/material.dart';

class MarkerBus2 extends StatelessWidget {
  final Offset relativePos; // posición relativa (0.0 a 1.0 en ancho/alto)
  final Size imageSize;     // tamaño del mapa mostrado
  final Offset imageOffset; // offset del mapa en pantalla (centrado)

  const MarkerBus2({
    super.key,
    required this.relativePos,
    required this.imageSize,
    required this.imageOffset,
  });

  // Función para mostrar ventana emergente con tabla de la ruta
  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ruta Transmetro"),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Estación")),
              DataColumn(label: Text("Ubicación")),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text("1")),
                DataCell(Text("Palacio Nacional")),
              ]),
              DataRow(cells: [
                DataCell(Text("2")),
                DataCell(Text("Plaza Municipal")),
              ]),
              DataRow(cells: [
                DataCell(Text("3")),
                DataCell(Text("El Trébol")),
              ]),
              DataRow(cells: [
                DataCell(Text("4")),
                DataCell(Text("El Amate")),
              ]),
              DataRow(cells: [
                DataCell(Text("5")),
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
      left: abs.dx - 20, // ajusta al centro con ícono
      top: abs.dy - 20,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: const Icon(
          Icons.train,
          color: Color.fromARGB(255, 135, 250, 112),
          size: 30,
        ),
      ),
    );
  }
}
