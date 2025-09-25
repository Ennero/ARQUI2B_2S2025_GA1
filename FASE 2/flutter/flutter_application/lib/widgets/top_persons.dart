import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/core/api_service.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/moch_api_service.dart';
import 'dart:math';

class TopPersonsWidget extends StatefulWidget {
  const TopPersonsWidget({super.key});

  @override
  State<TopPersonsWidget> createState() => _TopPersonsWidgetState();
}

class _TopPersonsWidgetState extends State<TopPersonsWidget> {
  // El PageController nos permite controlar la vista del carrusel
  late PageController _pageController;
  // Guardaremos la página actual para los indicadores y las animaciones
  int _currentPage = 0;

  // Variable para guardar el futuro
  late Future<List<dynamic>> _topPersonasFuture;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    // viewportFraction < 1.0 permite que se vean las páginas adyacentes
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.8, // Cada página ocupa el 80% del ancho
    );

    // Esto solo se ejecuta cuando el widget se crea
    _topPersonasFuture = MockApiService.fetchTopPersons().then((people) {
      _totalPages = people.length;
      return people;
    });

    // Escuchamos los cambios de página para actualizar nuestro estado
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título mejorado y centrado
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Personas en Lista Negra',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26, // Un poco más pequeño para elegancia
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // El FutureBuilder ahora envuelve todo el carrusel
        FutureBuilder<List<dynamic>>(
          // Usamos la variable para que no recargue en cada momento
          future: _topPersonasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.notificationRed),
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    'No hay datos de personas detectadas.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              );
            }

            final people = snapshot.data!;

            // Contenedor principal con flechas de navegación
            return Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: people.length,
                        itemBuilder: (context, index) {
                          final person = people[index];
                          // Pasamos el índice para la animación de escala
                          return _buildPersonCard(person, index);
                        },
                      ),
                    ),
                    // Flecha izquierda
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildNavigationButton(
                          icon: Icons.arrow_back_ios,
                          onPressed: _goToPreviousPage,
                        ),
                      ),
                    ),
                    // Flecha derecha
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: _buildNavigationButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: _goToNextPage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Construimos los indicadores de página (los puntitos)
                _buildPageIndicator(people.length),
              ],
            );
          },
        ),
      ],
    );
  }

  // Widget para construir cada tarjeta del carrusel con animación
  Widget _buildPersonCard(Map<String, dynamic> person, int index) {
    // Usamos AnimatedBuilder para re-construir la tarjeta cuando cambia el scroll
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        if (_pageController.position.haveDimensions) {
          // Calculamos la diferencia entre la página actual y esta tarjeta
          final double pageOffset = (_pageController.page ?? 0) - index;
          // Creamos un efecto de escala: la tarjeta del centro es grande (escala 1),
          // las de los lados son más pequeñas.
          scale = max(0.85, 1 - pageOffset.abs() * 0.3);
        }

        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(person['face_image_url'] ?? ''),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // Usamos un Stack para poner el degradado y el texto sobre la imagen
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // El degradado en la parte inferior para la legibilidad del texto
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // El texto posicionado en la parte inferior
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['person_id'] ?? 'Desconocido',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${person['detection_count'] ?? 0} Vistas",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir los puntitos indicadores
  Widget _buildPageIndicator(int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            height: isActive ? 10.0 : 6.0,
            width: isActive ? 30.0 : 6.0,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.vibrantGreen
                  : AppColors.secondaryText.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(5),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.vibrantGreen.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [],
            ),
          );
        }),
      ),
    );
  }

  // Widget para botones de navegación
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: onPressed != null ? 0.7 : 0.3),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            child: Icon(
              icon,
              color: onPressed != null
                  ? Colors.white
                  : Colors.grey.withValues(alpha: 0.5),
              size: 20, // ← Más pequeño y elegante
            ),
          ),
        ),
      ),
    );
  }

  // Método para ir a la página anterior
  void _goToPreviousPage() {
    HapticFeedback.lightImpact(); // vibración o algo así
    int newPage = _currentPage > 0 ? _currentPage - 1 : _totalPages - 1;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    HapticFeedback.lightImpact(); // vibración o algo así
    int newPage = _currentPage < _totalPages - 1 ? _currentPage + 1 : 0;
    _pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
