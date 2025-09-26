import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/infractions.dart';
import 'package:flutter_application/widgets/top_persons.dart';
import 'package:flutter_application/widgets/top_weapons.dart';
import 'package:flutter_application/core/app_colors.dart';

class AnalyticalDashboardView extends StatefulWidget {
  const AnalyticalDashboardView({super.key});

  @override
  State<AnalyticalDashboardView> createState() =>
      _AnalyticalDashboardViewState();
}

class _AnalyticalDashboardViewState extends State<AnalyticalDashboardView> {
  // ✅ Contador para forzar rebuild
  int _refreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: AppColors.cardBackground,
      color: AppColors.primaryAccent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Título
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Dashboard Analítico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onlineIndicator,
                letterSpacing: 1.0,
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

          // Widgets con key dinámica
          TopPersonsWidget(key: ValueKey('persons_$_refreshKey')),
          const SizedBox(height: 24),
          TopWeaponsWidget(key: ValueKey('weapons_$_refreshKey')),
          const SizedBox(height: 24),
          InfractionsWidget(key: ValueKey('infractions_$_refreshKey')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Delay realista
    await Future.delayed(const Duration(milliseconds: 800));

    // Forzamos la recarga
    if (mounted) {
      setState(() {
        _refreshKey++;
      });

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: AppColors.primaryAccent, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Datos actualizados exitosamente',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
