import 'package:flutter/material.dart';
import '../../../providers/view_model.dart';
import '../../../screens/gold_scheme/gold_scheme_model.dart';
import '../../../screens/gold_scheme/gold_scheme_repository.dart';

class GoldSchemeViewModel extends BaseViewModel {
  final GoldSchemeRepository _repository = GoldSchemeRepository();
  GoldScheme? _activeScheme;

  GoldSchemeViewModel() : super(name: "GoldSchemeViewModel");

  GoldScheme? get activeScheme => _activeScheme;

  Future<void> fetchSchemeDetails(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _activeScheme = await _repository.getSchemeDetails(customerId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> joinOrPayScheme({
    required String customerId,
    required int schemeId,
    required double amount,
  }) async {
    setBusy(true);
    clearError();

    try {
      final success = await _repository.makeSchemePayment(
        customerId: customerId,
        schemeId: schemeId,
        amount: amount,
      );
      if (success) {
        await fetchSchemeDetails(customerId);
        setBusy(false);
        return true;
      } else {
        setErrorMessage('Payment failed. Please try again.');
        setBusy(false);
        return false;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }
}
