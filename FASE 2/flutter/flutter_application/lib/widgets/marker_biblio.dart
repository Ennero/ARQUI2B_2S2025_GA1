import 'package:flutter/material.dart';

class MarkerBiblioteca extends StatelessWidget {
  final Offset relativePos; // (0..1)
  final Size imageSize;
  final Offset imageOffset;
  final double iconSize;

  const MarkerBiblioteca({
    super.key,
    required this.relativePos,
    required this.imageSize,
    required this.imageOffset,
    this.iconSize = 48,
  });

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Biblioteca Nacional"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/biblio.jpg", height: 150, fit: BoxFit.cover),
            const SizedBox(height: 10),
            const Text("Espacio cultural y educativo con un gran acervo bibliográfico."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double left = imageOffset.dx + relativePos.dx * imageSize.width;
    final double top = imageOffset.dy + relativePos.dy * imageSize.height;

    return Positioned(
      left: left - iconSize / 2,
      top: top - iconSize,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: Icon(Icons.local_library, color: Colors.green, size: iconSize),
      ),
    );
  }
}
