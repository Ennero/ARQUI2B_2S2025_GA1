import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/screens/app_home_screen.dart';
import 'package:flutter_application/screens/panel_control_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_application/screens/app_map_screen.dart';
import 'package:flutter_application/screens/notifications_screen.dart';

class AppNavigatorBar extends StatefulWidget {
  const AppNavigatorBar({super.key});

  @override
  State<AppNavigatorBar> createState() => _AppNavigatorBarState();
}

class _AppNavigatorBarState extends State<AppNavigatorBar> {
  // Para el cambio de pestañas
  int selectedIndex = 0;
  // Widgets que mostraremos
  List<Widget> pages = [
    AppHomeScreen(),
    PanelControlScreen(),
    NotificationsScreen(),
    MapaScreen(),
  ];

  void onItemTopped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Tráfico"),
        elevation: 0, // Sin sombra para un look más plano
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cardBackground, AppColors.primaryAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        // Mostramos el widget correspondiente
        child: pages.elementAt(selectedIndex),
      ),
      bottomNavigationBar: Container(
        // Un contenedor para darle un padding y un color de fondo seguro
        color: AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: GNav(
            // Estilos de la barra de navegación
            backgroundColor: AppColors.cardBackground,
            color: AppColors.secondaryText, // Color de íconos y texto inactivos
            activeColor:
                AppColors.primaryText, // Color de íconos y texto activos
            tabBackgroundColor: AppColors.primaryAccent.withOpacity(
              0.3,
            ), // Color de fondo de la pestaña activa
            gap: 8, // Espacio entre el ícono y el texto
            padding: const EdgeInsets.all(
              16,
            ), // Padding interno de cada pestaña
            // Pestañas
            tabs: const [
              GButton(icon: Icons.home, text: 'Principal'),
              GButton(icon: Icons.devices, text: 'Control'),
              GButton(
                icon: Icons.notifications_active_outlined,
                text: 'Notificaciones',
              ),
              GButton(icon: Icons.map_sharp, text: 'Mapa'),
            ],

            // Funcionalidad
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              // Llama a la función para cambiar de página
              onItemTopped(index);
            },
          ),
        ),
      ),
    );
  }
}
