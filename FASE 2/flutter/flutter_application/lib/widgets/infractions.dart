import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';
import 'package:flutter_application/core/api_service.dart';

class InfractionsWidget extends StatefulWidget {
  const InfractionsWidget({super.key});

  @override
  State<InfractionsWidget> createState() => _InfractionsWidgetState();
}

class _InfractionsWidgetState extends State<InfractionsWidget>
    with AutomaticKeepAliveClientMixin {
  // Indicar que queremos mantener el widget vivo
  @override
  bool get wantKeepAlive => true;
  static const int _maxItemsToShow = 8;
  static const double _maxHeight = 400;

  late Future<List<dynamic>> _infractionsFuture;

  late ScrollController _scrollController;
  late ScrollController _modalScrollController;

  @override
  void initState() {
    super.initState();
    // Inicializar el Future solo una vez
    _infractionsFuture = ApiService.fetchTodaysInfractions();

    _scrollController = ScrollController();
    _modalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _modalScrollController.dispose();
    super.dispose();
  }

  // Función para formatear la hora
  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '--;--';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Llamar a super.build() al inicio
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header existente...
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Infracciones del Día (Semáforo)',
                style: TextStyles.displayLarge.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.onlineIndicator.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.onlineIndicator.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Últimas $_maxItemsToShow',
                style: TextStyles.caption.copyWith(
                  color: AppColors.primaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        FutureBuilder<List<dynamic>>(
          future: _infractionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 100,
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
                height: 100,
                child: Center(
                  child: Text(
                    'No hay infracciones registradas hoy.',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              );
            }

            final allInfractions = snapshot.data!;
            final limitedInfractions = allInfractions
                .take(_maxItemsToShow)
                .toList();
            final hasMore = allInfractions.length > _maxItemsToShow;

            return Column(
              children: [
                Container(
                  height: _maxHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: limitedInfractions.length,
                      itemBuilder: (context, index) {
                        final infraction = limitedInfractions[index];
                        return _buildInfractionTile(
                          infraction: infraction,
                          isFirst: index == 0,
                          isLast: index == limitedInfractions.length - 1,
                        );
                      },
                    ),
                  ),
                ),

                if (hasMore) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          _showAllInfractionsModal(context, allInfractions),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryAccent.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: AppColors.primaryAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver todas las ${allInfractions.length} infracciones',
                              style: TextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.open_in_full,
                              size: 14,
                              color: AppColors.primaryAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // Para construir los cards
  Widget _buildInfractionTile({
    required Map<String, dynamic> infraction,
    required bool isFirst,
    required bool isLast,
  }) {
    final plate = infraction['plate'] ?? 'N/A';
    final location = infraction['location'] ?? 'Ubicación Desconocida';
    final time = _formatTimestamp(infraction['timestamp'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimelineMarker(isFirst, isLast),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plate,
                            style: TextStyles.headline.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: TextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          color: AppColors.secondaryText,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
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
          ],
        ),
      ),
    );
  }

  // Construcción de la línea del tiempo
  Widget _buildTimelineMarker(bool isFirst, bool isLast) {
    return SizedBox(
      width: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            margin: EdgeInsets.only(
              top: isFirst ? 20 : 0,
              bottom: isLast ? 20 : 0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.6),
                  AppColors.primaryAccent.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.notificationRed,
              border: Border.all(color: AppColors.appBackground, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.notificationRed.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.traffic, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // Ver las demás card faltantes en un modal
  void _showAllInfractionsModal(
    BuildContext context,
    List<dynamic> allInfractions,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.traffic,
                        color: AppColors.primaryAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Todas las Infracciones (${allInfractions.length})',
                          style: TextStyles.headline.copyWith(
                            color: AppColors.primaryText,
                            fontSize: 18,
                          ),
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
                Expanded(
                  child: Scrollbar(
                    controller: _modalScrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _modalScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: allInfractions.length,
                      itemBuilder: (context, index) {
                        final infraction = allInfractions[index];
                        return _buildInfractionTile(
                          infraction: infraction,
                          isFirst: index == 0,
                          isLast: index == allInfractions.length - 1,
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.appBackground.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Desliza para ver todas las infracciones',
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
}
