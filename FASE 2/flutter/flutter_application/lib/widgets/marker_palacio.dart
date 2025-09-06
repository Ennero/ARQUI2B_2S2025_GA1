import 'package:flutter/material.dart';

class MarkerPalacio extends StatelessWidget {
  final Offset relativePos;
  final Size imageSize;
  final Offset imageOffset;
  final double iconSize;

  const MarkerPalacio({
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
        title: const Text("Palacio Nacional"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/palacio.jpg", height: 150, fit: BoxFit.cover),
            const SizedBox(height: 10),
            const Text(
              "El Palacio Nacional es uno de los edificios más emblemáticos de la ciudad, símbolo de la historia y cultura.",
            ),
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
        child: Icon(Icons.account_balance, color: Colors.purple, size: iconSize),
      ),
    );
  }
}
