import 'package:flutter/material.dart';

class TrainMarkerMoving extends StatefulWidget {
  final List<Offset> route;     // lista de posiciones relativas (0.0–1.0) que recorre el tren
  final Size imageSize;         // tamaño real del mapa mostrado
  final Offset imageOffset;     // offset del mapa en pantalla
  final Duration stepDuration;  // tiempo que tarda en avanzar de un punto al siguiente

  const TrainMarkerMoving({
    super.key,
    required this.route,
    required this.imageSize,
    required this.imageOffset,
    this.stepDuration = const Duration(seconds: 2),
  });

  @override
  State<TrainMarkerMoving> createState() => _TrainMarkerMovingState();
}

class _TrainMarkerMovingState extends State<TrainMarkerMoving> {
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
      _startMoving(); // sigue moviéndose
    });
  }

  @override
  Widget build(BuildContext context) {
    // posición relativa actual del tren
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
        Icons.train, // 🚆 tren
        color: Color.fromARGB(255, 10, 224, 21),
        size: 40,
      ),
    );
  }
}
