import 'package:flutter/material.dart';
import 'package:flutter_application/components/summaryCard.dart';
import 'package:flutter_application/components/buildDataTable.dart';
import 'package:flutter_application/components/lineChartCard.dart';
import 'package:flutter_application/core/time_filter.dart';
import 'package:flutter_application/core/data_repository.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/text_style.dart';

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
      _dashboardDataFuture = DataRepository.fetchDashboardData(
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
                            color: AppColors.vibrantGreen,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: .35),
                                offset: Offset(0, 3),
                                blurRadius: 8,
                              ),
                            ],
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
        BuildDataTable(
          selectedFilter: _selectedFilter,
          timeSeries: timeSeries,
          headers: ["Hora", "Valor (PM)"],
        ),
        const SizedBox(height: 16),
        LineChartCard(timeSeries: timeSeries, label: chartData['label']),
        //_buildLineChart(timeSeries, label: chartData['label']),
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
              BuildDataTable(
                selectedFilter: _selectedFilter,
                timeSeries: timeSeries,
                headers: ["Día", "Valor"],
              ),
              const SizedBox(height: 16),
              LineChartCard(timeSeries: timeSeries, label: metricData['title']),
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
              BuildDataTable(
                selectedFilter: _selectedFilter,
                timeSeries: timeSeries,
                headers: ["Semana", "Valor"],
              ),
              const SizedBox(height: 16),
              LineChartCard(timeSeries: timeSeries, label: metricData['title']),
            ],
          ),
        );
      }).toList(),
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
          ...TimeFilter.values
              .where(
                (f) => f != TimeFilter.map,
              ) // Ocultar "Mapa" en panel de control
              .map(
                (filter) => ButtonSegment<TimeFilter>(
                  value: filter,
                  label: Text(DataRepository.getFilterLabel(filter)),
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
}
