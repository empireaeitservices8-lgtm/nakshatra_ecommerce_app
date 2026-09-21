import '../models/payment_method.dart';
import '../providers/view_model.dart';
import '../repositories/payment_repository.dart';

class PaymentViewModel extends BaseViewModel {
  final PaymentRepository _repository = PaymentRepository();
  List<PaymentMethod> _cards = [];

  PaymentViewModel() : super(name: "PaymentViewModel");

  List<PaymentMethod> get cards => _cards;

  Future<void> fetchCards(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _cards = await _repository.getPaymentMethods(customerId: customerId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> saveCard({
    required String customerId,
    required String number,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String holder,
    required String brand,
    required String theme,
  }) async {
    setBusy(true);
    clearError();

    try {
      final newCard = await _repository.saveCard(
        customerId: customerId,
        number: number,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        holder: holder,
        brand: brand,
        theme: theme,
      );
      _cards.add(newCard);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> deleteCard(String customerId, String cardId) async {
    setBusy(true);
    clearError();

    try {
      await _repository.removePaymentMethod(
        customerId: customerId,
        cardId: cardId,
      );
      _cards.removeWhere((item) => item.id == cardId);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }
}
