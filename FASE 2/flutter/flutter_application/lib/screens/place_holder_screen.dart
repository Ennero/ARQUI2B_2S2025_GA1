import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/marker_biblio.dart';
import 'package:flutter_application/widgets/marker_palacio.dart';
import 'package:flutter_application/widgets/marker_parqueo.dart';
import 'package:flutter_application/widgets/marker_portal.dart';
import 'package:flutter_application/widgets/marker_pollo.dart';
import 'package:flutter_application/widgets/marker_palomar.dart';
import 'package:flutter_application/widgets/marker_bus.dart';
import 'package:flutter_application/widgets/marker_park.dart';
import 'package:flutter_application/widgets/marker_tren.dart';
// transurbano y transmetro
import 'package:flutter_application/widgets/marker_bus_moving.dart';
import 'package:flutter_application/widgets/marker_train_moving.dart';

import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

class PlaceHolderScreen extends StatefulWidget {
  final String title;
  final IconData icon;

  const PlaceHolderScreen({super.key, required this.title, required this.icon});

  @override
  State<PlaceHolderScreen> createState() => _PlaceHolderScreenState();
}

class _PlaceHolderScreenState extends State<PlaceHolderScreen> {
  // parte superior   posiciones relativas fijas para marcadores
  final Offset palacioRel = const Offset(0.50, 0.13); // palacio nacional 
  // parte medio
  final Offset bibliotecaRel = const Offset(0.25, 0.38); // biblioteca nacional
  final Offset museoRel = const Offset(0.75, 0.35); // portal del comercio
  final Offset parkRel = const Offset(0.50, 0.35); // portal del comercio  // parte baja
  final Offset tren1Rel = const Offset(0.27, 0.50); // transMetro 
  final Offset tren2Rel = const Offset(0.77, 0.50); // transMetro 
  // parte baja
  final Offset parqueoRel = const Offset(0.25, 0.67); // parqueo
  final Offset hotelRel = const Offset(0.50, 0.67); // portal del comercio
  final Offset polloRel = const Offset(0.75, 0.67); // pollo campero 
  final Offset bus1Rel = const Offset(0.53, 0.24); // transMetro 
  final Offset bus2Rel = const Offset(0.53, 0.58); // transMetro
  
  // Información de la imagen (tamaño intrínseco)
  final AssetImage _mapProvider = const AssetImage('assets/mapa.jpg');
  Size? _mapIntrinsicSize;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;


  @override
  void initState() {
    super.initState();

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

    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          Positioned.fill(
            child: Image(
              image: _mapProvider,
              fit: BoxFit.contain,
            ),
          ),


          // Marcadores modulares
          MarkerPalacio(relativePos: palacioRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerBiblioteca(relativePos: bibliotecaRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerParqueo(relativePos: parqueoRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerMuseum(relativePos: museoRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerRestaurante(relativePos: polloRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerHotel(relativePos: hotelRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerBus(relativePos: bus1Rel,imageSize: displayedSize,imageOffset: imageOffset,),
           MarkerBus(relativePos: bus2Rel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerPark(relativePos: parkRel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerTrain(relativePos: tren1Rel,imageSize: displayedSize,imageOffset: imageOffset,),
          MarkerTrain(relativePos: tren2Rel,imageSize: displayedSize,imageOffset: imageOffset,          ),
          TrainMarkerMoving(
            route: const [ //x1=12 x2=88
              Offset(0.12, 0.03), // punto 1
              Offset(0.12, 0.78), // punto 2
              Offset(0.88, 0.03), // punto 3              
              Offset(0.88, 0.78), // punto 4
            ],
            imageSize: displayedSize,
            imageOffset: imageOffset,
            stepDuration: Duration(seconds: 3), // velocidad del tren
          ),
          BusMarkerMoving(
            route: const [ //x1=12 x2=88
              Offset(0.38, 0.19), // punto 1
              Offset(0.63, 0.19), // punto 2       
              Offset(0.63, 0.78), // punto 3
              Offset(0.38, 0.78), // punto 4
            ],
            imageSize: displayedSize,
            imageOffset: imageOffset,
            stepDuration: Duration(seconds: 2), // velocidad del tren
          ),
         
          // Header
          Positioned(
            top: 30,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: TextStyles.headline.copyWith(
                        color: AppColors.secondaryText)),
                Icon(widget.icon, color: AppColors.secondaryText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
