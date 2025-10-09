part of 'payphone_bloc.dart';

abstract class PayphoneState extends Equatable {
  const PayphoneState();

  @override
  List<Object> get props => [];
}

class PayphoneInitial extends PayphoneState {}

class PayphoneLoading extends PayphoneState {}

class PayphoneSuccess extends PayphoneState {
  final PayphonePaymentResponse response;

  const PayphoneSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class PayphoneFailure extends PayphoneState {
  final String error;

  const PayphoneFailure(this.error);

  @override
  List<Object> get props => [error];
}