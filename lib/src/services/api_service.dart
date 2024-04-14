import 'package:dio/dio.dart';
import 'base_url.dart';
import 'endpoints.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Response> verifyMpin(String mpin) async {
    try {
      return await _dio.post(
        '${BaseUrl.baseUrl}${Endpoint.verifyMpin.value}',
        data: {'mobileNumber': '+919700000001','pin':mpin},
      );
    } catch (e) {
      throw Exception('Failed to get card details: $e');
    }
  }

  Future<Response> getCardDetails(String token) async {
    try {
      return await _dio.get(
        '${BaseUrl.baseUrl}${Endpoint.getCardDetails.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to get card details: $e');
    }
  }

  Future<Response> getCardBalance(String token) async {
    try {
      return await _dio.get(
        '${BaseUrl.baseUrl}${Endpoint.getCardBalance.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw Exception('Failed to get card balance: $e');
    }
  }

  Future<Response> getCvv(String token, String kitNo, String dob, String expiryDate) async {
    try {
      return await _dio.post(
        '${BaseUrl.baseUrl}${Endpoint.getCvv.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'kitNo': kitNo, 'dob': dob, 'expiryDate': expiryDate},
      );
    } catch (e) {
      throw Exception('Failed to get CVV: $e');
    }
  }

  Future<Response> getUnbilledTransactions(String token) async {
    try {
      return await _dio.post(
        '${BaseUrl.baseUrl}${Endpoint.getUnbilledTransactions.value}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'fromDate': '20200101', 'toDate': '20240101'},
      );
    } catch (e) {
      throw Exception('Failed to get unbilled transactions: $e');
    }
  }
}
