// screens/mapa_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/marker_biblio.dart';
import 'package:flutter_application/widgets/marker_palacio.dart';
import 'package:flutter_application/widgets/marker_parqueo.dart';
import 'package:flutter_application/widgets/marker_museum.dart';
import 'package:flutter_application/widgets/marker_pollo.dart';
import 'package:flutter_application/widgets/marker_hotel.dart';
import 'package:flutter_application/widgets/marker_bus.dart';
import 'package:flutter_application/widgets/marker_park.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final Random random = Random();

  // Posiciones relativas (0..1) para carro y moto
  late List<Offset> carroRelPositions;
  late List<Offset> motoRelPositions;

  // parte superior   posiciones relativas fijas para marcadores
  final Offset palacioRel = const Offset(0.50, 0.13); // palacio nacional
  // parte medio
  final Offset bibliotecaRel = const Offset(0.25, 0.38); // biblioteca nacional
  final Offset museoRel = const Offset(0.75, 0.35); // portal del comercio
  final Offset parkRel = const Offset(0.50, 0.35); // portal del comercio  // parte baja
  // parte baja
  final Offset parqueoRel = const Offset(0.25, 0.65); // parqueo
  final Offset hotelRel = const Offset(0.50, 0.65); // portal del comercio
  final Offset polloRel = const Offset(0.75, 0.65); // portal del comercio
  final Offset bus1Rel = const Offset(0.50, 0.75); // portal del comercio

  // Información de la imagen (tamaño intrínseco)
  final AssetImage _mapProvider = const AssetImage('assets/mapa.jpg');
  Size? _mapIntrinsicSize;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  @override
  void initState() {
    super.initState();

    carroRelPositions =
        List.generate(3, (_) => Offset(random.nextDouble(), random.nextDouble()));
    motoRelPositions =
        List.generate(3, (_) => Offset(random.nextDouble(), random.nextDouble()));

    // Resolver la imagen para obtener tamaño intrínseco
    _imageStream = _mapProvider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener((ImageInfo info, bool _) {
      final image = info.image;
      setState(() {
        _mapIntrinsicSize =
            Size(image.width.toDouble(), image.height.toDouble());
      });
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

  // Calcula tamaño ajustado (BoxFit.contain) y offset (centrado)
  Size _fittedSize(Size src, Size dest) {
    final double scaleWidth = dest.width / src.width;
    final double scaleHeight = dest.height / src.height;
    final double used = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    return Size(src.width * used, src.height * used);
  }

  @override
  Widget build(BuildContext context) {
    final container = MediaQuery.of(context).size;

    final Size displayedSize = _mapIntrinsicSize == null
        ? container
        : _fittedSize(_mapIntrinsicSize!, container);

    final Offset imageOffset = Offset(
      (container.width - displayedSize.width) / 2,
      (container.height - displayedSize.height) / 2,
    );
    
    // El Scaffold se elimina porque AppNavigatorBar ya lo proporciona.
    // Devolvemos directamente el Stack.
    return Stack(
      children: [
        // Mapa
        Positioned.fill(
          child: Image(
            image: _mapProvider,
            fit: BoxFit.contain,
          ),
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
        MarkerParqueo(
          relativePos: parqueoRel,
          imageSize: displayedSize,
          imageOffset: imageOffset,
        ),
        MarkerMuseum(
          relativePos: museoRel,
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
          relativePos: bus1Rel,
          imageSize: displayedSize,
          imageOffset: imageOffset,
        ),
        MarkerPark(
          relativePos: parkRel,
          imageSize: displayedSize,
          imageOffset: imageOffset,
        ),

        // Header (Opcional, ya que el AppBar está en el navigator)
        // Si quieres mantener un título dentro de la pantalla del mapa, puedes dejarlo.
        // Aquí usamos valores fijos en lugar de "widget.title".
        Positioned(
          top: 15, // Ajusta el padding si es necesario
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mapa Interactivo",
                  style: TextStyles.headline.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)])),
              Icon(Icons.map_sharp, color: AppColors.secondaryText),
            ],
          ),
        ),
      ],
    );
  }
}