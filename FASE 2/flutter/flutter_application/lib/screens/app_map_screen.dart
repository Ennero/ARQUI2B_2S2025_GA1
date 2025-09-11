import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/data_repository.dart';
import 'package:flutter_application/core/text_style.dart';
import 'package:flutter_application/core/time_filter.dart';
import 'package:flutter_application/widgets/marker_biblio.dart';
import 'package:flutter_application/widgets/marker_bus.dart';
import 'package:flutter_application/widgets/marker_hotel.dart';
import 'package:flutter_application/widgets/marker_museum.dart';
import 'package:flutter_application/widgets/marker_palacio.dart';
import 'package:flutter_application/widgets/marker_park.dart';
import 'package:flutter_application/widgets/marker_parqueo.dart';
import 'package:flutter_application/widgets/marker_pollo.dart';
import 'package:flutter_application/widgets/market_bus2.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Constante para el padding del panel, ahora más pequeño para subirlo
  static const _panelPadding = 5.0;

  // Timer para actualizar las posiciones cada cierto tiempo
  Timer? _timer;

  // Variables de estado para los datos de la API
  // Se eliminó la variable del Timer
  bool _isLoading = true;
  String? _error;
  int _dist1 = 0;
  int _dist2 = 0;

  // Posiciones relativas fijas para marcadores
  final Offset palacioRel = const Offset(0.50, 0.155);
  final Offset bibliotecaRel = const Offset(0.192, 0.48);
  final Offset museoRel = const Offset(1 - 0.183, 0.460);
  final Offset parkRel = const Offset(0.51, 0.457);
  final Offset parqueoRel = const Offset(0.21, 0.827);
  final Offset hotelRel = const Offset(0.51, 0.827);
  final Offset polloRel = const Offset(1 - 0.183, 0.827);

  // Posiciones relativas para transmetro
  static const Offset pp1 = Offset(0.067, 0.037);
  static const Offset pp2 = Offset(0.982, 0.037);
  static const Offset pp3 = Offset(0.982, 0.9972);
  static const Offset pp4 = Offset(0.067, 0.9972);

  // Posiciones relativas para transurbano
  static const Offset p1 = Offset(0.3605, 0.245);
  static const Offset p2 = Offset(0.6785, 0.245);
  static const Offset p3 = Offset(0.6785, 0.9972);
  static const Offset p4 = Offset(0.3605, 0.9972);

  Offset _bus1Position = pp1;
  Offset _bus2Position = p1;

  // Variables para la imagen del mapa
  final AssetImage _mapProvider = const AssetImage('assets/mapa.jpg');
  Size? _mapIntrinsicSize;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _resolveMapImage();

    //Calcula la posición inicial del transurbano y transmetro
    _bus1Position = _calculateTransPosition(_dist1);
    _bus2Position = _calculateBusPosition(_dist2);

    // Se mantiene la primera llamada para cargar los datos al entrar
    _fetchBusData();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _fetchBusData();
    });
  }

  Future<void> _fetchBusData() async {
    try {
      final data = await DataRepository.fetchDashboardData(
        filter: TimeFilter.map,
      );

      final newDist1 = data['dist1']?['distance'] ?? 0;
      final newDist2 = data['dist2']?['distance'] ?? 0;

      // Calcula la nueva posición del transmetro basado en la nueva distancia
      final newBus1Position = _calculateTransPosition(newDist1);

      // Calcula la nueva posición del transurbano basado en la nueva distancia
      final newBusPosition = _calculateBusPosition(newDist2);

      if (mounted) {
        setState(() {
          _dist1 = newDist1;
          _dist2 = newDist2;

          // Actualiza la posición del transmetro
          _bus1Position = newBus1Position;

          // Actualiza la posición del transurbano
          _bus2Position = newBusPosition;

          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error al obtener datos";
          _isLoading = false;
        });
      }
    }
  }

  void _resolveMapImage() {
    _imageStream = _mapProvider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool _) {
      if (mounted) {
        setState(() {
          _mapIntrinsicSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }
    });
    _imageStream?.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    // Cancelar el timer si está activo
    _timer?.cancel();
    if (_imageStreamListener != null) {
      _imageStream?.removeListener(_imageStreamListener!);
    }
    super.dispose();
  }

  Size _fittedSize(Size src, Size dest) {
    final double scaleWidth = dest.width / src.width;
    final double scaleHeight = dest.height / src.height;
    final double used = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    return Size(src.width * used, src.height * used);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // ESTRUCTURA PRINCIPAL
      children: [
        // PANEL DE DATOS
        SafeArea(
          // SafeArea aquí para que solo afecte al panel y no al mapa
          bottom: false, // No aplicar a la parte inferior
          child: Padding(
            padding: const EdgeInsets.all(
              _panelPadding + 5.0,
            ), // Padding para separarlo de los bordes
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildPanelContent(),
            ),
          ),
        ),

        // MAPA Y MARCADORES
        Expanded(
          child: LayoutBuilder(
            // LayoutBuilder para obtener el tamaño real del contenedor del mapa
            builder: (context, constraints) {
              // Calculo el tamaño y offset del mapa basados en el espacio disponible
              final container = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              // Si no se sabe el tamaño del mapa, no dibujamos los marcadores.
              if (_mapIntrinsicSize == null) {
                return Image(image: _mapProvider, fit: BoxFit.contain);
              }

              final Size displayedSize = _fittedSize(_mapIntrinsicSize!, container);

              final Offset imageOffset = Offset(
                (container.width - displayedSize.width) / 2,
                (container.height - displayedSize.height) / 2,
              );

              return Stack(
                children: [
                  // Mapa
                  Positioned.fill(
                    child: Image(image: _mapProvider, fit: BoxFit.contain),
                  ),

                  // Marcadores modulares
                  MarkerPalacio(
                    relativePos: palacioRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerBiblioteca(
                    relativePos: bibliotecaRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerMuseum(
                    relativePos: museoRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerParqueo(
                    relativePos: parqueoRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerRestaurante(
                    relativePos: polloRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerHotel(
                    relativePos: hotelRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerBus(
                    relativePos: _bus2Position,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerBus2(
                    relativePos: _bus1Position,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerPark(
                    relativePos: parkRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPanelContent() {
    // Durante la carga inicial, muestra el spinner.
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: TextStyles.body.copyWith(color: AppColors.notificationRed),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Recorrido del transmetro: $_dist1 km',
          style: TextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recorrido del transurbano: $_dist2 km',
          style: TextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Función para calcular la posición del bus basado en la distancia recorrida
  Offset _calculateBusPosition(int distance) {
    // Si _dist2 llega a 160, habrá completado un ciclo.
    const double maxDistanceForLoop = 160.0;

    // Longitudes de cada lado del rectángulo en unidades relativas.
    final double side1 = p2.dx - p1.dx; // Derecha
    final double side2 = p3.dy - p2.dy; // Abajo
    final double side3 = p3.dx - p4.dx; // Izquierda
    final double side4 = p4.dy - p1.dy; // Arriba

    final double perimeter = side1 + side2 + side3 + side4;

    // Normalizamos la distancia para que siempre esté dentro de un ciclo de 0 a maxDistanceForLoop
    final double distanceInLoop = distance % maxDistanceForLoop;

    // Calculamos qué tan lejos ha viajado en el perímetro (de 0 a 'perimeter')
    double distanceTravelled =
        (distanceInLoop / maxDistanceForLoop) * perimeter;

    // Determinamos en qué lado del rectángulo se encuentra el bus
    if (distanceTravelled <= side1) {
      // Moviéndose de p1 a p2 (horizontalmente)
      return Offset(p1.dx + distanceTravelled, p1.dy);
    } else if (distanceTravelled <= side1 + side2) {
      // Moviéndose de p2 a p3 (verticalmente)
      distanceTravelled -= side1;
      return Offset(p2.dx, p2.dy + distanceTravelled);
    } else if (distanceTravelled <= side1 + side2 + side3) {
      // Moviéndose de p3 a p4 (horizontalmente, en reversa)
      distanceTravelled -= (side1 + side2);
      return Offset(p3.dx - distanceTravelled, p3.dy);
    } else {
      // Moviéndose de p4 a p1 (verticalmente, en reversa)
      distanceTravelled -= (side1 + side2 + side3);
      return Offset(p4.dx, p4.dy - distanceTravelled);
    }
  }

  // Función para calcular la posición del transmetro basado en la distancia recorrida
  Offset _calculateTransPosition(int distance) {
    // Si _dist2 llega a 360, habrá completado un ciclo.
    const double maxDistanceForLoop = 360.0;

    // Longitudes de cada lado del rectángulo en unidades relativas.
    final double side1 = pp2.dx - pp1.dx; // Derecha
    final double side2 = pp3.dy - pp2.dy; // Abajo
    final double side3 = pp3.dx - pp4.dx; // Izquierda
    final double side4 = pp4.dy - pp1.dy; // Arriba

    final double perimeter = side1 + side2 + side3 + side4;

    // Normalizando la distancia para que siempre esté dentro de un ciclo de 0 a maxDistanceForLoop
    final double distanceInLoop = distance % maxDistanceForLoop;

    // Calculo qué tan lejos ha viajado en el perímetro
    double distanceTravelled =
        (distanceInLoop / maxDistanceForLoop) * perimeter;

    // Determinamos en qué lado del rectángulo se encuentra el bus
    if (distanceTravelled <= side1) {
      // Moviéndose de pp1 a pp2 (horizontalmente)
      return Offset(pp1.dx + distanceTravelled, pp1.dy);
    } else if (distanceTravelled <= side1 + side2) {
      // Moviéndose de pp2 a pp3 (verticalmente)
      distanceTravelled -= side1;
      return Offset(pp2.dx, pp2.dy + distanceTravelled);
    } else if (distanceTravelled <= side1 + side2 + side3) {
      // Moviéndose de pp3 a pp4 (horizontalmente, en reversa)
      distanceTravelled -= (side1 + side2);
      return Offset(pp3.dx - distanceTravelled, pp3.dy);
    } else {
      // Moviéndose de pp4 a pp1 (verticalmente, en reversa)
      distanceTravelled -= (side1 + side2 + side3);
      return Offset(pp4.dx, pp4.dy - distanceTravelled);
    }
  }
}