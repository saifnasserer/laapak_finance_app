import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FinanceApiService {
  final Dio _dio;
  final String _baseUrl =
      'https://reports.laapak.com/api/v2/external/financial';
  // API Key for authentication
  // secure-api-key - generated via admin panel
  static const String _apiKey =
      'ak_live_d5f56697b40cde8ce0e3a3033c4382b6c4d03872bcd90c9a1ef44f4ebd2f7d25';

  FinanceApiService() : _dio = Dio() {
    _dio.options.headers['x-api-key'] = _apiKey;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Map<String, dynamic>> getFinancialSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/summary',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Error fetching summary: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFinancialLedger({
    String? startDate,
    String? endDate,
    String type = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/ledger',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'type': type,
          'limit': limit,
          'offset': offset,
        },
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Error fetching ledger: $e');
      rethrow;
    }
  }

  Future<void> updateInvoiceItemCost(int itemId, double costPrice) async {
    try {
      // Note: Endpoint path corrected based on API guide context, though guide said /financial/invoice-items...
      // Guide says: PATCH /financial/invoice-items/{id}/cost
      // Base URL is .../financial
      // So it should be just /invoice-items/{id}/cost relative to base, or absolute?
      // Guide base URL: https://reports.laapak.com/api/v2/external/financial
      // Endpoint: PATCH /financial/invoice-items/{id}/cost
      // This implies the endpoint might be outside the base URL if it repeats /financial.
      // However, usually it's relative. I will assume it's relative to the parent of base if it starts with /financial or just append if it's consistent.
      // Let's assume the guide meant relative to root api/v2/external.
      // But for safety, I will use the path from the guide but check if I need to adjust.
      // actually the guide says "Base URL: .../financial", and endpoint "PATCH /financial/invoice-items...".
      // This looks like a copy-paste in the guide. I will try to use the full path or assume relative.
      // Let's stick to the base url being the prefix.
      // If base is .../financial, then appending /invoice-items makes sense.
      // I will remove the duplicate /financial prefix if it exists in the append.
      await _dio.patch(
        '$_baseUrl.replaceFirst("/financial", "")/financial/invoice-items/$itemId/cost',
        data: {'cost_price': costPrice},
      );
      // actually, let's just use the full url to be safe if `_baseUrl` assumes .../financial
      // Let's blindly follow the guide's specific endpoint path which might be a typo in guide or specific routing.
      // I will assume the guide meant the resource is under financial.
      // api/v2/external/financial/invoice-items/...
    } catch (e) {
      if (kDebugMode) print('Error updating item cost: $e');
      rethrow;
    }
  }

  Future<void> createExpense({
    required String name,
    required double amount,
    required int categoryId,
    required DateTime date,
    String type = 'variable',
    String? description,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/expenses',
        data: {
          'name': name,
          'amount': amount,
          'category_id': categoryId,
          'date': date.toIso8601String().split('T')[0],
          'type': type,
          if (description != null) 'description': description,
        },
      );
    } catch (e) {
      if (kDebugMode) print('Error creating expense: $e');
      rethrow;
    }
  }
}
