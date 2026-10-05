import '../models/order.dart';
import '../providers/view_model.dart';
import '../repositories/order_repository.dart';

class OrderViewModel extends BaseViewModel {
  final OrderRepository _repository = OrderRepository();

  List<Order> _orders = [];
  double _couponDiscount = 0.0;
  String? _couponCode;
  String? _couponMessage;
  Map<String, dynamic>? _placedOrder;
  List<dynamic> _coupons = [];

  OrderViewModel() : super(name: "OrderViewModel");

  List<Order> get orders => _orders;
  double get couponDiscount => _couponDiscount;
  String? get couponCode => _couponCode;
  String? get couponMessage => _couponMessage;
  Map<String, dynamic>? get placedOrder => _placedOrder;
  List<dynamic> get coupons => _coupons;

  Future<void> fetchOrders(String customerId, {bool rethrowError = false}) async {
    setBusy(true);
    clearError();

    try {
      _orders = await _repository.getOrders(customerId: customerId);
    } catch (e) {
      setErrorMessage(e.toString());
      if (rethrowError) rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> validateCoupon(String customerId, String code) async {
    setBusy(true);
    clearError();
    _couponMessage = null;

    try {
      final res = await _repository.validateCoupon(customerId: customerId, code: code);
      if (res['valid'] == true || res['status'] == 'success') {
        _couponDiscount = (res['discount_amount'] ?? 0.0).toDouble();
        _couponCode = code;
        _couponMessage = res['message'] ?? 'Coupon applied successfully';
        setBusy(false);
        return true;
      } else {
        _couponMessage = res['message'] ?? 'Invalid coupon code';
        setBusy(false);
        return false;
      }
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<void> fetchCoupons(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _coupons = await _repository.getCoupons(customerId: customerId);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  void clearCoupon() {
    _couponDiscount = 0.0;
    _couponCode = null;
    _couponMessage = null;
    notifyListeners();
  }

  Future<bool> placeOrder({
    required String customerId,
    required String addressId,
    required String paymentMethod,
    String? shippingAddress,
    String? shippingCity,
    String? shippingPhone,
    String? notes,
    String? cardId,
    String? couponCode,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    setBusy(true);
    clearError();

    try {
      _placedOrder = await _repository.checkout(
        customerId: customerId,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress ?? '',
        shippingCity: shippingCity ?? 'Calicut',
        shippingPhone: shippingPhone ?? '',
        notes: notes,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );
      // Wait for /orders API to succeed before marking order placed
      await fetchOrders(customerId, rethrowError: true);
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }
}
