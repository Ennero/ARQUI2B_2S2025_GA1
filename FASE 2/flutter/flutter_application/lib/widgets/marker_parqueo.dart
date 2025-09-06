import 'package:flutter/material.dart';

class MarkerParqueo extends StatelessWidget {
  final Offset relativePos;
  final Size imageSize;
  final Offset imageOffset;

  const MarkerParqueo({
    super.key,
    required this.relativePos,
    required this.imageSize,
    required this.imageOffset,
  });

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Parqueo Central"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/parqueo.jpg",
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            const Text("Zona de estacionamiento central para vehículos."),
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
    final absPos = Offset(
      imageOffset.dx + relativePos.dx * imageSize.width,
      imageOffset.dy + relativePos.dy * imageSize.height,
    );

    return Positioned(
      left: absPos.dx - 25, // centra el icono
      top: absPos.dy - 25,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: const Icon(
          Icons.local_parking,
          color: Colors.orange,
          size: 40,
        ),
      ),
    );
  }
}
