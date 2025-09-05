import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/text_style.dart';
import '../components/infoCard.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Título Principal de la Pantalla ---
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Acerca del Proyecto',
            textAlign: TextAlign.center,
            style: TextStyles.displayLarge.copyWith(
              color: AppColors.primaryText
            )
          ),
        ),
        
        // --- Tarjetas Informativas ---
        Infocard(
          title: 'Nuestra Misión',
          description: 'Ofrecer a los ciudadanos una herramienta tecnológica para visualizar datos complejos de forma sencilla, permitiendo tomar decisiones informadas.',
          icon: Icons.rocket_launch,
          color: AppColors.primaryAccent,
        ),
        SizedBox(height: 20),
        Infocard(
          title: 'Visión del Proyecto',
          description: 'Contribuir a la creación de ciudades más seguras, eficientes e inteligentes mediante el uso de tecnologías como el Internet de las Cosas (IoT).',
          icon: Icons.visibility,
          color: AppColors.vibrantGreen,
          isReversed: true, // Alineación invertida
        ),
        SizedBox(height: 20),
        Infocard(
          title: '¿Cómo Funciona?',
          description: 'Nuestra app se conecta a una red de sensores simulados que recopilan datos sobre tráfico, alertas y transporte público en tiempo real.',
          icon: Icons.hub_outlined,
          color: AppColors.notificationRed,
        ),
        SizedBox(height: 20),
        Infocard(
          title: 'Nuestro Prototipo',
          description: 'Este proyecto se basa en una maqueta física que simula un entorno urbano, sentando las bases para una implementación a gran escala.',
          icon: Icons.memory,
          color: AppColors.miOrange,
          isReversed: true, // Alineación invertida
        ),
      ],
    );
  }
}

