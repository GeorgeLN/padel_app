// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/payphone/payphone_payment_request.dart';
import '../../../data/models/payphone/payphone_payment_response.dart';
import '../../../data/services/payphone_service.dart';

part 'payphone_event.dart';
part 'payphone_state.dart';

class PayphoneBloc extends Bloc<PayphoneEvent, PayphoneState> {
  final PayphoneService _payphoneService;

  PayphoneBloc(this._payphoneService) : super(PayphoneInitial()) {
    on<CreatePayphonePayment>(_onCreatePayment);
  }

  Future<void> _onCreatePayment(
    CreatePayphonePayment event,
    Emitter<PayphoneState> emit,
  ) async {
    emit(PayphoneLoading());
    try {
      final response = await _payphoneService.createPayment(event.request);
      emit(PayphoneSuccess(response));
    } catch (e) {
      emit(PayphoneFailure(e.toString()));
    }
  }
}