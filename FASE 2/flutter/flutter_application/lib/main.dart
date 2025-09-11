import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';
import 'package:flutter_application/screens/app_navigator_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Establece el tema global de la aplicación
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.appBackground, 
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.primaryText,
          titleTextStyle: TextStyles.headline,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyles.displayLarge,
          headlineMedium: TextStyles.headline,
          bodyMedium: TextStyles.body,
          labelLarge: TextStyles.button,
        ),
      ),
      home: AppNavigatorBar (),
    );
  }

}
