import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

class Summarycard extends StatelessWidget{
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const Summarycard({super.key, 
    required this.title,
    required this.value,
    required this.icon,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyles.displayLarge.copyWith(color: AppColors.primaryText),
              ),
              const SizedBox(height: 4,),
              Text(
                title,
                style: TextStyles.caption.copyWith(color: AppColors.secondaryText),
                overflow: TextOverflow.ellipsis,
              )
            ],
          )
        ],
      ),
    );
  }
}