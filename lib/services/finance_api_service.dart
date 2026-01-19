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
      if (kDebugMode) {
        print('GET $_baseUrl/ledger');
        print(
          'Params: ${{if (startDate != null) 'startDate': startDate, if (endDate != null) 'endDate': endDate, 'type': type, 'limit': limit, 'offset': offset}}',
        );
      }
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
      // Endpoint: /financial/invoice-items/{id}/cost
      // Base URL already includes /financial
      await _dio.patch(
        '$_baseUrl/invoice-items/$itemId/cost',
        data: {'cost_price': costPrice},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item cost: $e');
        if (e is DioException) {
          print('Response Data: ${e.response?.data}');
          print('Response Headers: ${e.response?.headers}');
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    try {
      // Endpoint: /api/v2/external/invoices/{id}
      // _baseUrl is /api/v2/external/financial
      final url = _baseUrl.replaceAll('/financial', '/invoices/$invoiceId');
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Error fetching invoice details: $e');
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
