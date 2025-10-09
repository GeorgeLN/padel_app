import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payphone/payphone_payment_request.dart';
import '../bloc/payphone/payphone_bloc.dart';
import '../../data/services/payphone_service.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayphoneBloc(PayphoneServiceImpl()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PayPhone Payment'),
        ),
        body: BlocListener<PayphoneBloc, PayphoneState>(
          listener: (context, state) {
            if (state is PayphoneSuccess) {
              // Navigate to a success screen or show a success dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment successful! URL: ${state.response.payphoneUrl}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PayphoneFailure) {
              // Show an error dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: BlocBuilder<PayphoneBloc, PayphoneState>(
                builder: (context, state) {
                  if (state is PayphoneLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      final request = PayphonePaymentRequest(
                        amount: 1000, // Example amount
                        amountWithTax: 1000,
                        amountWithoutTax: 1000,
                        tax: 0,
                        clientTransactionId: DateTime.now().millisecondsSinceEpoch.toString(),
                        currency: 'USD',
                        email: 'test@example.com',
                        reference: 'Test Payment',
                      );
                      context.read<PayphoneBloc>().add(CreatePayphonePayment(request));
                    },
                    child: const Text('Pay with PayPhone'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}