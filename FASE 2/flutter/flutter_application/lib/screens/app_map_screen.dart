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
import 'package:flutter_application/widgets/marker_infobus.dart';
import 'package:flutter_application/widgets/marker_infotren.dart';

// Pantalla del mapa con marcadores y buses en movimiento
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

// Estado de la pantalla del mapa
class _MapaScreenState extends State<MapaScreen> {
  // OFFSETS FIJOS
  // Desplazamiento para el Transmetro.
  static const int transmetroOffset = 143;
  // Desplazamiento para el Transurbano.
  static const int transurbanoOffset = 155;

  // Constante para el padding del panel
  static const _panelPadding = 5.0;

  // --- Temporizadores ---
  Timer? _fetchDataTimer; // Timer para obtener datos de la API (cada 4s)
  Timer? _animationTimer; // Timer para la animación fluida (cada 250ms)

  // --- Variables de estado para los datos ---
  bool _isLoading = true;
  String? _error;
  // _distanciaObtenida: Último valor real de la API.
  int _distanciaObtenida1 = 0;
  int _distanciaObtenida2 = 0;

  // _dist: Valor animado que se muestra en la UI y mueve el bus.
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

  final Offset busInfoRel = const Offset(0.46, 0.31);
  final Offset busInfoRel2 = const Offset(0.60, 0.95);

  final Offset trenInfoRel = const Offset(0.17, 0.74);
  final Offset trenInfoRel2 = const Offset(0.90, 0.62);

  // Posición especial para el transmetro (centro del mapa)
  final Offset posicionEspecialTransmetro = const Offset(0.067, 0.748);

  // Posiciones relativas para transmetro
  static const Offset pp1 = Offset(0.067, 0.037); // izquierda-arriba
  static const Offset pp2 = Offset(0.982, 0.037); // derecha-arriba
  static const Offset pp3 = Offset(0.982, 0.9972); // derecha-abajo
  static const Offset pp4 = Offset(0.067, 0.9972); // izquierda-abajo

  // Posiciones relativas para transurbano
  static const Offset p1 = Offset(0.3605, 0.245); // izquierda-arriba
  static const Offset p2 = Offset(0.6785, 0.245); // derecha-arriba
  static const Offset p3 = Offset(0.6785, 0.9972); // derecha-abajo
  static const Offset p4 = Offset(0.3605, 0.9972); // izquierda-abajo

  // Posiciones actuales de los buses (inicialmente en p1 y pp1)
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
    _fetchBusData(); // Primera llamada para obtener datos

    // Timer para obtener datos de la API cada 4 segundos
    _fetchDataTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _fetchBusData();
    });

    // Timer para la animación, se ejecuta 4 veces por segundo
    _animationTimer = Timer.periodic(const Duration(milliseconds: 250), (
      timer,
    ) {
      _updateBusAnimation();
    });
  }

  // Funcion para actualizar la animación de los buses
  void _updateBusAnimation() {
    if (!mounted || _isLoading) return; // No animar si está cargando

    bool needsUiUpdate = false;
    int nextDist1 = _dist1;
    int nextDist2 = _dist2;

    // Lógica de animación para Transmetro
    const int limiteAvanceTransmetro = 32;
    bool enParadaTransmetro =
        _distanciaObtenida1 == 0 ||
        _distanciaObtenida1 == 120 ||
        _distanciaObtenida1 == 360;

    // Si no está paraado y no ha avanzado más allá del límite, avanza.
    if (!enParadaTransmetro &&
        _dist1 < _distanciaObtenida1 + limiteAvanceTransmetro) {
      nextDist1++; // Avanza 1cm cada 250ms (4cm/s)
      needsUiUpdate = true;
    }

    // Lógica de animación para Transurbano
    const int limiteAvanceTransurbano = 16;
    bool enParadaTransurbano =
        _distanciaObtenida2 % 80 == 0; // Parada cada 80cm

    // Si no está paraado y no ha avanzado más allá del límite, avanza.
    if (!enParadaTransurbano &&
        _dist2 < _distanciaObtenida2 + limiteAvanceTransurbano) {
      nextDist2++; // Avanza 1cm cada 250ms (4cm/s)
      needsUiUpdate = true;
    }

    // Si hubo un cambio, actualiza el estado y la posición de los buses
    if (needsUiUpdate) {
      setState(() {
        _dist1 = nextDist1;
        _dist2 = nextDist2;
        _updateBusPositions(); // Recalcula la posición en el mapa
      });
    }
  }

  Future<void> _fetchBusData() async {
    try {
      final data = await DataRepository.fetchDashboardData(
        filter: TimeFilter.map,
      );
      // Extrae las distancias del JSON, con valor por defecto 0
      final int rawDist1 = data['dist1']?['distance'] ?? 0;
      final int rawDist2 = data['dist2']?['distance'] ?? 0;

      // Actualiza el estado solo si el widget sigue montado
      if (mounted) {
        setState(() {
          // Guarda el valor real de la API
          _distanciaObtenida1 = rawDist1;
          _distanciaObtenida2 = rawDist2;

          // Resetea la distancia animada al nuevo valor obtenido
          _dist1 = _distanciaObtenida1;
          _dist2 = _distanciaObtenida2;

          // Calcula la posición inicial con los nuevos datos
          _updateBusPositions();

          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error al obtener datos del servidor.";
          _isLoading = false;
        });
      }
    }
  }

  // Función para actualizar las posiciones de los buses en el mapa
  void _updateBusPositions() {
    // Transmetro
    if (_dist1 == 120) {
      _bus1Position = posicionEspecialTransmetro;
    } else {
      final int visualDist1 = _dist1 + transmetroOffset;
      _bus1Position = _calculateTransPosition(visualDist1);
    }

    // Transurbano
    final int visualDist2 = _dist2 + transurbanoOffset;
    _bus2Position = _calculateBusPosition(visualDist2);
  }

  @override
  void dispose() {
    // Cancelar timers y listeners para evitar fugas de memoria
    _fetchDataTimer?.cancel();
    _animationTimer?.cancel();

    // Remover listener de la imagen del mapa
    if (_imageStreamListener != null) {
      _imageStream?.removeListener(_imageStreamListener!);
    }
    super.dispose();
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

              final Size displayedSize = _fittedSize(
                _mapIntrinsicSize!,
                container,
              );

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
                  MarkerInfoBus(
                    relativePos: busInfoRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerInfoBus(
                    relativePos: busInfoRel2,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerInfoTren(
                    relativePos: trenInfoRel,
                    imageSize: displayedSize,
                    imageOffset: imageOffset,
                  ),
                  MarkerInfoTren(
                    relativePos: trenInfoRel2,
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

    // LOGICA PARA TRANSURBANO
    const int longitudTramo = 80;
    final int avanceEnTramo = _dist2 % longitudTramo;

    // Si está justo en una parada, la distancia faltante es 0.
    final int distanciaFaltanteTransurbano = (avanceEnTramo == 0)
        ? 0
        : longitudTramo - avanceEnTramo;

    // Calcular el tiempo aproximado en segundos (1 cm = 0.15 segundos)
    final double tiempoFaltanteTransurbano =
        distanciaFaltanteTransurbano * 0.15;

    // LÓGICA PARA TRANSMETRO
    int distanciaFaltanteTransmetro;

    // Si está en una de las paradas clave, la distancia faltante es 0.
    if (_dist1 == 0 || _dist1 == 120 || _dist1 == 360) {
      distanciaFaltanteTransmetro = 0;
    }
    // Si está en el primer tramo (después de 0 y hasta 120), la próxima parada es 120.
    else if (_dist1 > 0 && _dist1 < 120) {
      distanciaFaltanteTransmetro = 120 - _dist1;
    }
    // Si está en el segundo tramo (después de 120 y hasta 360), la próxima parada es 360.
    else {
      distanciaFaltanteTransmetro = 360 - _dist1;
    }

    // Calcular el tiempo aproximado en segundos (1 cm = 0.15 segundos)
    final double tiempoFaltanteTransmetro = distanciaFaltanteTransmetro * 0.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // BLOQUE TRANSMETRO
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.vibrantGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TRANSMETRO - próxima parada',
              style: TextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Padding para indentar los detalles
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          // AHORA ES UNA FILA (ROW) PARA PONER LOS TEXTOS LADO A LADO
          child: Row(
            children: [
              Text(
                'Distancia aprox: $distanciaFaltanteTransmetro cm', // Texto abreviado
                style: TextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 16), // Espacio entre los dos textos
              Text(
                'Tiempo aprox: ${tiempoFaltanteTransmetro.toStringAsFixed(1)} s', // Texto abreviado
                style: TextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // BLOQUE TRANSURBANO
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TRANSURBANO - próxima parada',
              style: TextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Text(
                'Distancia aprox: $distanciaFaltanteTransurbano cm', // Texto abreviado
                style: TextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 16), // Espacio entre los dos textos
              Text(
                'Tiempo aprox: ${tiempoFaltanteTransurbano.toStringAsFixed(1)} s', // Texto abreviado
                style: TextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
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

    // Calculamos qué tan lejos ha viajado en el perímetro
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
