class PayphonePaymentRequest {
  final double amount;
  final double amountWithTax;
  final double amountWithoutTax;
  final double tax;
  final String clientTransactionId;
  final String currency;
  final String email;
  final String reference;

  PayphonePaymentRequest({
    required this.amount,
    required this.amountWithTax,
    required this.amountWithoutTax,
    required this.tax,
    required this.clientTransactionId,
    required this.currency,
    required this.email,
    required this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amountWithTax': amountWithTax,
      'amountWithoutTax': amountWithoutTax,
      'tax': tax,
      'clientTransactionId': clientTransactionId,
      'currency': currency,
      'email': email,
      'reference': reference,
    };
  }
}