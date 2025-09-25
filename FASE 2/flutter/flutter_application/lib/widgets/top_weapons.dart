import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/moch_api_service.dart';
import 'package:flutter_application/core/text_style.dart';

class TopWeaponsWidget extends StatefulWidget {
  const TopWeaponsWidget({super.key});

  @override
  State<TopWeaponsWidget> createState() => _TopWeaponsWidgetState();
}

class _TopWeaponsWidgetState extends State<TopWeaponsWidget> {
  // Navegación
  int _currentPage = 0;
  static const int _itemsPerPage = 6; // armas por página
  List<dynamic> _allWeapons = [];
  List<dynamic> _currentPageWeapons = [];

  // Variable para manejar el futuro
  late Future<List<dynamic>> _topWeaponsFuture;

  static const List<Color> _cardColors = [
    AppColors.primaryAccent, // Azul brillante original
    AppColors.deepOcean, // Azul océano
    AppColors.steelBlue, // Azul acero
    AppColors.darkEmerald, // Verde esmeralda
    AppColors.spacePurple, // Púrpura espacial
    AppColors.deepRed, // Rojo profundo
    AppColors.burntOrange, // Naranja quemado
    AppColors.darkTeal, // Teal oscuro
    AppColors.deepIndigo, // Índigo profundo
  ];

  static const List<Color> _accentColors = [
    AppColors.cardBackground, // Original
    AppColors.deepOceanLight, // Azul océano claro
    AppColors.steelBlueLight, // Azul acero claro
    AppColors.darkEmeraldLight, // Verde esmeralda claro
    AppColors.spacePurpleLight, // Púrpura espacial claro
    AppColors.deepRedLight, // Rojo profundo claro
    AppColors.burntOrangeLight, // Naranja quemado claro
    AppColors.darkTealLight, // Teal oscuro claro
    AppColors.deepIndigoLight, // Índigo profundo claro
  ];

  @override
  void initState() {
    super.initState();
    // Solo cargamos una vez
    _topWeaponsFuture = MockApiService.fetchTopWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Top de Armas Detectadas",
                style: TextStyles.displayLarge.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.vibrantGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.vibrantGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Página ${_currentPage + 1} de ${_getTotalPages()}',
                style: TextStyles.caption.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Paginación
        FutureBuilder<List<dynamic>>(
          future: _topWeaponsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error ${snapshot.error}",
                  style: const TextStyle(color: AppColors.notificationRed),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No se ha dectecado armas.",
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              );
            }

            // Configurar Paginación
            _allWeapons = snapshot.data!;
            _updateCurrentPageWeapons();

            // Diseño de rejilla
            return Column(
              children: [
                // Flechas de navegación
                GridView.builder(
                  // shrinkWrap y physics son necesarios cuando un GridView está dentro
                  // de otro elemento desplazable como un ListView.
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentPageWeapons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // columnas
                    crossAxisSpacing: 16, // Espaciado horizontal
                    mainAxisSpacing: 16, // Espaciado vertical
                    childAspectRatio: 0.85, // Proporción (ancho / alto)
                  ),
                  itemBuilder: (context, index) {
                    final weapon = _currentPageWeapons[index];
                    return _buildWeaponCard(context, weapon);
                  },
                ),
                const SizedBox(height: 16),

                // Indicador de página y flechas de navegación
                if (_getTotalPages() > 1) _buildBottomNavigation(),
              ],
            );
          },
        ),
      ],
    );
  }

  // Widget para las tarjeta de rejilla
  Widget _buildWeaponCard(BuildContext context, Map<String, dynamic> weapon) {
    final imageURL = weapon['image_url'] ?? '';
    final weaponType = weapon['weapon_type'] ?? 'Desconocido';
    final count = weapon['detection_count'] ?? 0;

    // Obtener colores basados en el índice del arma
    final colorIndex = weapon.hashCode.abs() % _cardColors.length;
    final primaryColor = _cardColors[colorIndex];
    final accentColor = _accentColors[colorIndex];

    return Card(
      color: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Gradiente que combina con tu fondo appBackground
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.8), // Color de acento
              AppColors.cardBackground.withValues(alpha: 0.9), // Tu color base
              primaryColor.withValues(alpha: 0.1), // Toque del color principal
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Avatar clickleable
              GestureDetector(
                onTap: () => _showImageModal(
                  context,
                  imageURL,
                  weaponType,
                ), // Activa modal al tocar
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Sombra del color principal
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: accentColor.withValues(alpha: 0.6),
                    child: imageURL.isNotEmpty
                        ? ClipOval(
                            child: Image.asset(
                              imageURL,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.warning,
                                  color: primaryColor,
                                  size: 40,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.help_outline,
                            color: primaryColor,
                            size: 40,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                weaponType,
                style: TextStyles.headline.copyWith(
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: AppColors.secondaryText,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$count Vistas",
                    style: TextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageModal(
    BuildContext context,
    String imageURL,
    String weaponType,
  ) {
    if (imageURL.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true, // Cerrar tocando fuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header del modal
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          weaponType,
                          style: TextStyles.headline.copyWith(
                            color: AppColors.primaryText,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Imagen grande con zoom
                Flexible(
                  child: InteractiveViewer(
                    panEnabled: true, // Permitir arrastrar
                    scaleEnabled: true, // Permitir zoom
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          imageURL,
                          fit: BoxFit.contain, // Mostrar toda la imagen
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: AppColors.secondaryText,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Imagen no disponible',
                                      style: TextStyles.caption.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer con información adicional
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pellizca para hacer zoom • Arrastra para mover',
                        style: TextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Actualizar las armas de la página actual
  void _updateCurrentPageWeapons() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _allWeapons.length);
    _currentPageWeapons = _allWeapons.sublist(startIndex, endIndex);
  }

  // Obtener el total de páginas
  int _getTotalPages() {
    return (_allWeapons.length / _itemsPerPage).ceil();
  }

  // Navegar a la página anterior
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _updateCurrentPageWeapons();
      });
    }
  }

  // Navegar página siguiente
  void _goToNextPage() {
    if (_currentPage < _getTotalPages() - 1) {
      setState(() {
        _currentPage++;
        _updateCurrentPageWeapons();
      });
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Botón Anterior
          _buildBottomNavigationButton(
            icon: Icons.arrow_back_ios,
            label: 'Anterior',
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
          ),

          // ✅ Indicador de páginas en el centro
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicador de páginas (modificado)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_getTotalPages(), (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        height: isActive ? 8.0 : 5.0,
                        width: isActive ? 24.0 : 5.0,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryAccent
                              : AppColors.secondaryText.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Botón Siguiente
          _buildBottomNavigationButton(
            icon: Icons.arrow_forward_ios,
            label: 'Siguiente',
            onPressed: _currentPage < _getTotalPages() - 1
                ? _goToNextPage
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.primaryAccent.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? AppColors.primaryAccent.withValues(alpha: 0.3)
                    : AppColors.secondaryText.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled
                      ? AppColors.primaryAccent
                      : AppColors.secondaryText.withValues(alpha: 0.5),
                  size: 18,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyles.caption.copyWith(
                    color: isEnabled
                        ? AppColors.primaryAccent
                        : AppColors.secondaryText.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
