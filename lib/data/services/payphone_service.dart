import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payphone/payphone_payment_request.dart';
import '../models/payphone/payphone_payment_response.dart';

abstract class PayphoneService {
  Future<PayphonePaymentResponse> createPayment(PayphonePaymentRequest request);
}

class PayphoneServiceImpl implements PayphoneService {
  final String _apiUrl = 'https://pay.payphonetodoesposible.com/api/transaction'; // Placeholder URL
  final String _apiKey = 'YOUR_API_KEY'; // Placeholder API Key

  @override
  Future<PayphonePaymentResponse> createPayment(PayphonePaymentRequest request) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PayphonePaymentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }
}