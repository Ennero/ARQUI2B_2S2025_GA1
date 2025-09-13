import 'package:flutter_application/core/time_filter.dart';
import 'package:flutter_application/core/api_service.dart' as real;
import 'package:flutter_application/core/moch_api_service.dart' as mock;

class DataRepository {
  // Cámbiarlo a false para usar backend real.
  static bool useMock = false;

  static Future<Map<String, dynamic>> fetchDashboardData({
    TimeFilter filter = TimeFilter.today,
  }) {
    return useMock
        ? mock.MockApiService.fetchDashboardData(filter: filter)
        : real.ApiService.fetchDashboardData(filter: filter);
  }

  static String getFilterLabel(TimeFilter filter) {
    return real.ApiService.getFilterLabel(filter);
  }
}
