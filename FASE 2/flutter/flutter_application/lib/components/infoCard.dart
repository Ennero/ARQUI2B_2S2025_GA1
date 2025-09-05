import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

/// Un widget reutilizable para mostrar una tarjeta de información con
/// título, descripción, ícono y color personalizables.
class Infocard extends StatelessWidget{
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isReversed;

  const Infocard({super.key, 
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isReversed = false
  });


  @override
  Widget build(BuildContext context){
    // Definimos los widgets que componen la tarjeta
    final textContent = Expanded(
      child: Column(
        crossAxisAlignment: isReversed ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.headline.copyWith(color: color, fontSize: 20),
            textAlign: isReversed ? TextAlign.right: TextAlign.left,
            ),
            const SizedBox(height: 8,),
            Text(
              description,
              style: TextStyles.body.copyWith(color: AppColors.secondaryText),
              textAlign: isReversed ? TextAlign.right: TextAlign.left,
            ),
        ],
      )
    );

    final iconContent = CircleAvatar(
      radius: 40,
      backgroundColor: color,
      child: Icon(
        icon,
        size: 40,
        color: AppColors.primaryText
      )
    );

    // Rederizamos la tarjeta
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Si isReversed es verdadero, el ícono va primero
          if (isReversed) ...[
            iconContent,
            const SizedBox(width: 16,)
          ],
          textContent,
          // Si isReversed es falso, el ícono va al final
          if (!isReversed) ...[
            const SizedBox(width: 16,),
            iconContent,
          ]
        ],
      ),
    );
  }
}
