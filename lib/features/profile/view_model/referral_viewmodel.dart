import 'package:flutter/material.dart';
import '../../../models/referral.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/referral_repository.dart';

class ReferralViewModel extends BaseViewModel {
  final ReferralRepository _repository = ReferralRepository();
  ReferralInfo? _referralInfo;

  ReferralViewModel() : super(name: "ReferralViewModel");

  ReferralInfo? get referralInfo => _referralInfo;

  Future<void> fetchReferralInfo(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _referralInfo = await _repository.getReferralInfo(customerId: customerId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addReferralCode(String customerId, String referralCode) async {
    setBusy(true);
    clearError();

    try {
      await _repository.addReferral(customerId: customerId, referralCode: referralCode);
      await fetchReferralInfo(customerId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }
}
