import '../models/notification.dart';
import '../providers/view_model.dart';
import '../repositories/notification_repository.dart';

class NotificationViewModel extends BaseViewModel {
  final NotificationRepository _repository = NotificationRepository();
  List<AppNotification> _notifications = [];

  NotificationViewModel() : super(name: "NotificationViewModel");

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _notifications = await _repository.getNotifications(
        customerId: customerId,
      );
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> markAsRead(String customerId, String id) async {
    try {
      await _repository.markAsRead(customerId: customerId, id: id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];
        _notifications[index] = AppNotification(
          id: current.id,
          title: current.title,
          message: current.message,
          time: current.time,
          read: true,
        );
        notifyListeners();
      }
    } catch (e) {
      setErrorMessage(e.toString());
    }
  }
}
