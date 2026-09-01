import 'package:flutter/material.dart';
import '../../../models/address.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/address_repository.dart';

class AddressViewModel extends BaseViewModel {
  final AddressRepository _repository = AddressRepository();
  List<Address> _addresses = [];

  AddressViewModel() : super(name: "AddressViewModel");

  List<Address> get addresses => _addresses;

  Future<void> fetchAddresses(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _addresses = await _repository.getAddresses(customerId: customerId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> addAddress({
    required String customerId,
    required String label,
    required String name,
    required String phone,
    required String address,
  }) async {
    setBusy(true);
    clearError();

    try {
      final newAddress = await _repository.saveAddress(
        customerId: customerId,
        label: label,
        name: name,
        phone: phone,
        address: address,
      );
      _addresses.add(newAddress);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> updateAddress({
    required String customerId,
    required String addressId,
    required String label,
    required String name,
    required String phone,
    required String address,
  }) async {
    setBusy(true);
    clearError();

    try {
      final updated = await _repository.updateAddress(
        customerId: customerId,
        addressId: addressId,
        label: label,
        name: name,
        phone: phone,
        address: address,
      );
      final index = _addresses.indexWhere((item) => item.id == addressId);
      if (index != -1) {
        _addresses[index] = updated;
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<void> deleteAddress(String customerId, String id) async {
    setBusy(true);
    clearError();

    try {
      await _repository.deleteAddress(customerId: customerId, id: id);
      _addresses.removeWhere((item) => item.id == id);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
