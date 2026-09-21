import '../models/address.dart';
import '../providers/view_model.dart';
import '../repositories/address_repository.dart';

class AddressViewModel extends BaseViewModel {
  final AddressRepository _repository = AddressRepository();
  List<Address> _addresses = [];

  AddressViewModel() : super(name: "AddressViewModel");

  List<Address> get addresses => _addresses;

  String _formatError(dynamic e) {
    final errStr = e.toString();
    if (errStr.contains('Exception:')) {
      return errStr.replaceFirst('Exception:', '').trim();
    }
    return errStr;
  }

  Future<void> fetchAddresses(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _addresses = await _repository.getAddresses(customerId: customerId);
    } catch (e) {
      setErrorMessage(_formatError(e));
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
      await _repository.saveAddress(
        customerId: customerId,
        label: label,
        name: name,
        phone: phone,
        address: address,
      );
      // Automatically refresh address list from the server
      await fetchAddresses(customerId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(_formatError(e));
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
      await _repository.updateAddress(
        customerId: customerId,
        addressId: addressId,
        label: label,
        name: name,
        phone: phone,
        address: address,
      );
      // Automatically refresh address list from the server
      await fetchAddresses(customerId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(_formatError(e));
      setBusy(false);
      return false;
    }
  }

  Future<bool> deleteAddress(String customerId, String id) async {
    setBusy(true);
    clearError();

    try {
      await _repository.deleteAddress(customerId: customerId, id: id);
      // Automatically refresh address list from the server
      await fetchAddresses(customerId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(_formatError(e));
      setBusy(false);
      return false;
    }
  }
}
