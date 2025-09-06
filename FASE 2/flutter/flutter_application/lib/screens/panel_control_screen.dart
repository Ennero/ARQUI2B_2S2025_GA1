import 'package:flutter/material.dart';
import 'package:flutter_application/components/summaryCard.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/moch_api_service.dart';
import 'package:flutter_application/core/text_style.dart';
import 'package:fl_chart/fl_chart.dart';

class PanelControlScreen extends StatefulWidget {
  const PanelControlScreen({super.key});
  @override
  State<PanelControlScreen> createState() => _PanelControlScreenState();
}

class _PanelControlScreenState extends State<PanelControlScreen> {
  late Future<Map<String, dynamic>> _dashboardDataFuture;
  TimeFilter _selectedFilter = TimeFilter.today;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dashboardDataFuture = MockApiService.fetchDashboardData(
        filter: _selectedFilter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dashboardDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.notificationRed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                final data = snapshot.data!;
                final summaryData = data['summary'];
                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  backgroundColor: AppColors.cardBackground,
                  color: AppColors.primaryAccent,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          'Panel de Control',
                          textAlign: TextAlign.center,
                          style: TextStyles.displayLarge.copyWith(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      _buildFilterButtons(),
                      SizedBox(height: 12),
                      _buildSummaryGrid(summaryData),
                      const SizedBox(height: 24),
                      if (_selectedFilter == TimeFilter.week)
                        _buildWeekDetails(data['detailedMetrics'])
                      else if (_selectedFilter == TimeFilter.month)
                        _buildMonthDetails(data['detailedMetrics'])
                      else
                        _buildTodayDetails(data['airQualityChart']),
                    ],
                  ),
                );
              }
              return const Center(child: Text("No hay datos disponibles."));
            },
          ),
        ),
      ],
    );
  }

  /// Construye la vista de detalles para "Hoy".
  Widget _buildTodayDetails(Map<String, dynamic> chartData) {
    final dataPoints = (chartData['dataPoints'] as List);
    final timeSeries = dataPoints
        .map((p) => {"label": "${p['hour']}", "value": p['value']})
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chartData['label'],
          style: TextStyles.displayLarge.copyWith(
            color: AppColors.primaryText,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: .4),
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Separamos la tabla y el gráfico en sus propios contenedores.
        _buildDataTable(timeSeries, ["Hora", "Valor (PM)"]),
        const SizedBox(height: 16),
        _buildLineChart(timeSeries, label: chartData['label']),
      ],
    );
  }

  /// Construye la vista de detalles para "Semana"
  Widget _buildWeekDetails(List<dynamic> metrics) {
    return Column(
      children: metrics.map((metricData) {
        final timeSeries = (metricData['timeSeries'] as List)
            .cast<Map<String, dynamic>>();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metricData['title'],
                style: TextStyles.displayLarge.copyWith(
                  color: AppColors.primaryText,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .4),
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDataTable(timeSeries, ["Día", "Valor"]),
              const SizedBox(height: 16),
              _buildLineChart(timeSeries),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Construye la vista de detalles para "Mes"
  Widget _buildMonthDetails(List<dynamic> metrics) {
    return Column(
      children: metrics.map((metricData) {
        final timeSeries = (metricData['timeSeries'] as List)
            .cast<Map<String, dynamic>>();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metricData['title'], style: TextStyles.headline),
              const SizedBox(height: 16),
              _buildDataTable(timeSeries, ["Semana", "Valor"]),
              const SizedBox(height: 16),
              _buildLineChart(timeSeries),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// NUEVO WIDGET: Construye solo la tabla de datos en una tarjeta estilizada.
  Widget _buildDataTable(
    List<Map<String, dynamic>> timeSeries,
    List<String> headers,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: .08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: .15),
          width: 1,
        ),
      ),
      child: DataTable(
        headingRowHeight: 44,
        columnSpacing: 32,
        dataRowColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          // Alterna el color de las filas
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryAccent.withValues(alpha: .08);
          }
          return null;
        }),
        columns: headers
            .map(
              (h) => DataColumn(
                label: Text(
                  h,
                  style: TextStyles.headline.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
            .toList(),
        rows: timeSeries.asMap().entries.map((entry) {
          final row = entry.value;
          final isEven = entry.key % 2 == 0;
          String label = row['label'].toString();
          if (_selectedFilter == TimeFilter.today) label += 'h';

          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return isEven
                  ? AppColors.cardBackground
                  : AppColors.appBackground.withValues(alpha: 0.7);
            }),
            cells: [
              DataCell(
                Text(
                  label,
                  style: TextStyles.body.copyWith(color: AppColors.primaryText),
                ),
              ),
              DataCell(
                Text(
                  (row['value'] as num).toStringAsFixed(1),
                  style: TextStyles.body.copyWith(
                    color: AppColors.vibrantGreen,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> summaryData) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Summarycard(
          title: "Recorrido Transmetro",
          value:
              "${(summaryData['recorridoTransmetro'] as num).toStringAsFixed(0)} km",
          icon: Icons.directions_bus,
          color: AppColors.notificationRed,
        ),
        Summarycard(
          title: "Recorrido Transurbano",
          value:
              "${(summaryData['recorridoTransurbano'] as num).toStringAsFixed(0)} km",
          icon: Icons.local_shipping,
          color: AppColors.miOrange,
        ),
        Summarycard(
          title: "Calidad Aire (PM)",
          value: (summaryData['calidadAirePromedio'] as num).toStringAsFixed(1),
          icon: Icons.air,
          color: AppColors.vibrantGreen,
        ),
        Summarycard(
          title: "Alertas Críticas",
          value: (summaryData['alertasCriticas'] as num).toStringAsFixed(0),
          icon: Icons.warning_amber_rounded,
          color: AppColors.primaryAccent,
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SegmentedButton<TimeFilter>(
        segments: [
          ...TimeFilter.values.map(
            (filter) => ButtonSegment<TimeFilter>(
              value: filter,
              label: Text(MockApiService.getFilterLabel(filter)),
            ),
          ),
        ],
        selected: {_selectedFilter},
        onSelectionChanged: (Set<TimeFilter> newSelection) {
          setState(() {
            _selectedFilter = newSelection.first;
          });
          _loadData();
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.secondaryText,
          selectedBackgroundColor: AppColors.primaryAccent,
          selectedForegroundColor: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildLineChart(
    List<Map<String, dynamic>> timeSeries, {
    String label = "Gráfico",
  }) {
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Mostrar solo algunos labels para no saturar el eje
                        if (timeSeries.length > 10 && value.toInt() % 2 != 0){
                          return const SizedBox.shrink();
                        }
                        // Solo mostrar si el valor es entero y está en el rango
                        int idx = value.round();
                        if (idx >= 0 &&
                            idx < timeSeries.length &&
                            value == idx.toDouble()) {
                          final item = timeSeries[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              item['label'].toString(),
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
