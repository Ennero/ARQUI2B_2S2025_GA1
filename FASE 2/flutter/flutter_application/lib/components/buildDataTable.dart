import 'package:flutter/material.dart';
import 'package:flutter_application/core/app_colors.dart';
import 'package:flutter_application/core/moch_api_service.dart';
import 'package:flutter_application/core/text_style.dart';

class BuildDataTable extends StatelessWidget {
  final TimeFilter selectedFilter;
  final List<Map<String, dynamic>> timeSeries;
  final List<String> headers;
  const BuildDataTable({
    super.key,
    required this.selectedFilter,
    required this.timeSeries,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
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
          if (selectedFilter == TimeFilter.today) label += 'h';

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
}
