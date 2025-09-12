import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';
import 'package:flutter_application/screens/app_navigator_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

Future<void> main() async { // ← ahora es async
  WidgetsFlutterBinding.ensureInitialized(); // ← requerido antes de cargar assets
  await dotenv.load(fileName: '.env'); // ← carga variables del .env
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: AppNavigatorBar(),
    );
  }
}