import 'package:flutter/material.dart';

class BusMarkerMoving extends StatefulWidget {
  final List<Offset> route;     // lista de posiciones relativas (0.0–1.0) que recorre el bus
  final Size imageSize;         // tamaño real del mapa mostrado
  final Offset imageOffset;     // offset del mapa en pantalla
  final Duration stepDuration;  // tiempo que tarda en avanzar de un punto al siguiente

  const BusMarkerMoving({
    super.key,
    required this.route,
    required this.imageSize,
    required this.imageOffset,
    this.stepDuration = const Duration(seconds: 2),
  });

  @override
  State<BusMarkerMoving> createState() => _BusMarkerMovingState();
}

class _BusMarkerMovingState extends State<BusMarkerMoving> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startMoving();
  }

  void _startMoving() {
    Future.delayed(widget.stepDuration, () {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.route.length;
      });
      _startMoving(); // sigue moviéndose en bucle
    });
  }

  @override
  Widget build(BuildContext context) {
    // posición relativa actual del bus
    final Offset relativePos = widget.route[_currentIndex];

    // convertir coordenada relativa a absoluta
    final abs = Offset(
      widget.imageOffset.dx + relativePos.dx * widget.imageSize.width,
      widget.imageOffset.dy + relativePos.dy * widget.imageSize.height,
    );

    return Positioned(
      left: abs.dx - 20,
      top: abs.dy - 20,
      child: const Icon(
        Icons.directions_bus, // 🚍 ícono del bus
        color: Color.fromARGB(255, 11, 106, 247),
        size: 40,
      ),
    );
  }
}
