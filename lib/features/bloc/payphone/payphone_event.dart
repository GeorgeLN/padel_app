part of 'payphone_bloc.dart';

abstract class PayphoneEvent extends Equatable {
  const PayphoneEvent();

  @override
  List<Object> get props => [];
}

class CreatePayphonePayment extends PayphoneEvent {
  final PayphonePaymentRequest request;

  const CreatePayphonePayment(this.request);

  @override
  List<Object> get props => [request];
}