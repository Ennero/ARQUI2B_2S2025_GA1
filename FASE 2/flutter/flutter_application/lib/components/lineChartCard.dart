import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

class Linechartcard extends StatelessWidget {
  final Map<String, dynamic> chartData;
  const Linechartcard({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    // Se convierten los datos del JSON a una lista de puntos (FlSpot) que el gráfico entiende.
    final List<FlSpot> spots = (chartData['dataPoints'] as List).map((point) {
      return FlSpot(point['hour'].toDouble(), point['value'].toDouble());
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
            chartData['label'],
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Muestra solo algunas horas para no saturar el eje
                        if (value.toInt() % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}h',
                              style: TextStyles.caption.copyWith(
                                color: AppColors.secondaryText,
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
