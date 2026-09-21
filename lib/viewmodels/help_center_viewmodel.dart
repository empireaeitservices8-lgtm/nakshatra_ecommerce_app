import '../models/help_center.dart';
import '../providers/view_model.dart';
import '../repositories/help_center_repository.dart';

class HelpCenterViewModel extends BaseViewModel {
  final HelpCenterRepository _repository = HelpCenterRepository();
  List<FaqItem> _faqs = [];
  ChatInfo? _chatInfo;

  HelpCenterViewModel() : super(name: "HelpCenterViewModel");

  List<FaqItem> get faqs => _faqs;
  ChatInfo? get chatInfo => _chatInfo;

  Future<void> fetchHelpCenterData() async {
    setBusy(true);
    clearError();

    try {
      final results = await Future.wait([
        _repository.getFaqs(),
        _repository.getChatInfo(),
      ]);
      _faqs = results[0] as List<FaqItem>;
      _chatInfo = results[1] as ChatInfo?;
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchFaqs() => fetchHelpCenterData();

  Future<void> fetchChatInfo() async {
    try {
      _chatInfo = await _repository.getChatInfo();
      notifyListeners();
    } catch (_) {}
  }
}
