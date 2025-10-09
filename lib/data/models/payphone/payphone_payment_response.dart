class PayphonePaymentResponse {
  final int? transactionId;
  final String? clientTransactionId;
  final String? statusCode;
  final String? message;
  final String? payphoneUrl;

  PayphonePaymentResponse({
    this.transactionId,
    this.clientTransactionId,
    this.statusCode,
    this.message,
    this.payphoneUrl,
  });

  factory PayphonePaymentResponse.fromJson(Map<String, dynamic> json) {
    return PayphonePaymentResponse(
      transactionId: json['transactionId'],
      clientTransactionId: json['clientTransactionId'],
      statusCode: json['statusCode'],
      message: json['message'],
      payphoneUrl: json['payphoneUrl'],
    );
  }
}