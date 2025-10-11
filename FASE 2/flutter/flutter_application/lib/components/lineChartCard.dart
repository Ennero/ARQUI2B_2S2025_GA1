import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

class LineChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> timeSeries;
  final String label;
  const LineChartCard({super.key, required this.timeSeries, required this.label});

  @override
  Widget build(BuildContext context) {
    // Se convierten los datos del JSON a una lista de puntos (FlSpot) que el gráfico entiende.
    final spots = timeSeries.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value['value'] as num).toDouble(),
      );
    }).toList();

    return Container(
      height: 250,
      margin: EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.headline.copyWith(color: AppColors.primaryText),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 500,
                gridData: const FlGridData(
                  show: false,
                ), // Oculta la cuadrícula de fondo
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Estilos para los títulos del eje Y (izquierda)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyles.caption.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        );
                      },
                    ),
                  ),
                  // Estilos para los títulos del eje X (abajo)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) {
                        // Solo mostrar si el valor es entero y está en el rango
                        int idx = value.round();
                        if (idx >= 0 &&
                            idx < timeSeries.length &&
                            value == idx.toDouble()) {
                          final item = timeSeries[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 100, // Tamaño de los títulos
                              child: Text(
                                item['label'].toString(),
                                style: TextStyles.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ), // Oculta los bordes del gráfico
                // Datos de la línea principal
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryAccent, AppColors.vibrantGreen],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ), // Oculta los puntos en la línea
                    // Sombra/relleno debajo de la línea
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAccent.withValues(alpha: 0.3),
                          AppColors.vibrantGreen.withValues(alpha: 0.1),
                          AppColors.vibrantGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
