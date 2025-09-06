import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo del mapa
          Positioned.fill(
            child: Image.asset(
              'assets/mapa.jpg', // ruta de la imagen en assets
              fit: BoxFit.cover,
            ),
          ),

          // Contenido encima de la imagen (actual placeholder)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 80,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 20),
                Text(
                  widget.title,
                  style: TextStyles.headline.copyWith(
                      color: AppColors.secondaryText),
                ),
                Text(
                  "(En construcción el mejor mapa)",
                  style: TextStyles.body.copyWith(
                      color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
