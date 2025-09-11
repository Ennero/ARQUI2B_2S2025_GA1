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


class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Constante para el padding del panel, ahora más pequeño para subirlo
  static const _panelPadding = 5.0;

  // Variables de estado para los datos de la API
  // Se eliminó la variable del Timer
  bool _isLoading = true;
  String? _error;
  int _dist1 = 0;
  int _dist2 = 0;

  // Posiciones relativas fijas para marcadores
  final Offset palacioRel = const Offset(0.50, 0.155);
  final Offset bibliotecaRel = const Offset(0.192, 0.48);
  final Offset museoRel = const Offset(1-0.183, 0.460);
  final Offset parkRel = const Offset(0.51, 0.457);
  final Offset parqueoRel = const Offset(0.21, 0.827);
  final Offset hotelRel = const Offset(0.51, 0.827);
  final Offset polloRel = const Offset(1-0.183, 0.827);
  final Offset bus1Rel = const Offset(0.50, 0.75);

  // Variables para la imagen del mapa
  final AssetImage _mapProvider = const AssetImage('assets/mapa.jpg');
  Size? _mapIntrinsicSize;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _resolveMapImage();

    // Se mantiene la primera llamada para cargar los datos al entrar
    _fetchBusData();
    // Se eliminó la inicialización del Timer
  }

  Future<void> _fetchBusData() async {
    // Si no es la carga inicial, no mostramos el spinner,
    // el RefreshIndicator ya tiene el suyo.
    if (!_isLoading) {
      setState(() {});
    }

    try {
      final data =
          await DataRepository.fetchDashboardData(filter: TimeFilter.map);

      final newDist1 = data['dist1']?['distance'] ?? 0;
      final newDist2 = data['dist2']?['distance'] ?? 0;

      if (mounted) {
        setState(() {
          _dist1 = newDist1;
          _dist2 = newDist2;
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
          _mapIntrinsicSize =
              Size(info.image.width.toDouble(), info.image.height.toDouble());
        });
      }
    });
    _imageStream?.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
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
  // El widget RefreshIndicator envuelve todo para la funcionalidad de deslizar
  return RefreshIndicator(
    onRefresh: _fetchBusData, // Llama a tu función de carga de datos
    backgroundColor: AppColors.cardBackground,
    color: AppColors.primaryText,
    child: Column( // 1. ESTRUCTURA PRINCIPAL: Cambiamos Stack por Column
      children: [
        // 2. PANEL DE DATOS: Ahora es el primer hijo del Column
        SafeArea(
          // SafeArea aquí para que solo afecte al panel y no al mapa
          bottom: false, // No aplicar a la parte inferior
          child: Padding(
            padding: const EdgeInsets.all(
                _panelPadding + 5.0), // Padding para separarlo de los bordes
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

        // 3. MAPA Y MARCADORES: Ocupan el resto del espacio
        Expanded(
          // Expanded hace que este widget llene el espacio vertical restante
          child: LayoutBuilder(
            // 4. LayoutBuilder para obtener el tamaño real del contenedor del mapa
            builder: (context, constraints) {
              // Calculamos el tamaño y offset del mapa basados en el espacio disponible
              // dado por el LayoutBuilder (constraints) en lugar del tamaño de la pantalla.
              final container = Size(constraints.maxWidth, constraints.maxHeight);
              final Size displayedSize = _mapIntrinsicSize == null
                  ? container
                  : _fittedSize(_mapIntrinsicSize!, container);
              final Offset imageOffset = Offset(
                (container.width - displayedSize.width) / 2,
                (container.height - displayedSize.height) / 2,
              );

              // El Stack ahora solo contiene el mapa y los marcadores
              return Stack(
                children: [
                  // Mapa
                  Positioned.fill(
                    child: Image(
                      image: _mapProvider,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Marcadores modulares (sin cambios aquí)
                  MarkerPalacio(
                      relativePos: palacioRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerBiblioteca(
                      relativePos: bibliotecaRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerMuseum(
                      relativePos: museoRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerParqueo(
                      relativePos: parqueoRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerRestaurante(
                      relativePos: polloRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerHotel(
                      relativePos: hotelRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerBus(
                      relativePos: bus1Rel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                  MarkerPark(
                      relativePos: parkRel,
                      imageSize: displayedSize,
                      imageOffset: imageOffset),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPanelContent() {
    // Durante la carga inicial, muestra el spinner.
    // Para las actualizaciones por deslizamiento, el RefreshIndicator tiene su propio spinner.
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
          style: TextStyles.body
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Recorrido del transurbano: $_dist2 km',
          style: TextStyles.body
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}