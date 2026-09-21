import '../helpers/url_helpers.dart';
import '../models/help_center.dart';
import '../services/api_service.dart';

class HelpCenterRepository {
  final ApiService _apiService = ApiService();

  Future<List<FaqItem>> getFaqs() async {
    try {
      final response = await _apiService.get(UrlHelpers.helpCenter);
      final resData = response.data;
      if (resData == null) return [];

      final dataMap = resData is Map
          ? (resData['result'] is Map ? resData['result'] : resData)
          : {};

      final faqsList = (dataMap['faqs'] as List?) ??
          (dataMap['data'] as List?) ??
          (resData['faqs'] as List?) ??
          [];

      return faqsList
          .map((item) => FaqItem.fromJson(
              item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      // Fallback: try POST if GET returns method not allowed or specific endpoint requirement
      try {
        final response = await _apiService.post(UrlHelpers.helpCenter, data: {'params': {}});
        final resData = response.data;
        if (resData == null) return [];

        final dataMap = resData is Map
            ? (resData['result'] is Map ? resData['result'] : resData)
            : {};

        final faqsList = (dataMap['faqs'] as List?) ??
            (dataMap['data'] as List?) ??
            [];

        return faqsList
            .map((item) => FaqItem.fromJson(
                item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item)))
            .toList();
      } catch (err) {
        throw Exception('Failed to load help center FAQs: $err');
      }
    }
  }

  Future<ChatInfo?> getChatInfo() async {
    try {
      final response = await _apiService.get(UrlHelpers.chatInfo);
      final resData = response.data;
      if (resData == null) return null;

      final dataMap = resData is Map
          ? (resData['result'] is Map ? resData['result'] : resData)
          : {};

      return ChatInfo.fromJson(
        dataMap is Map<String, dynamic> ? dataMap : Map<String, dynamic>.from(dataMap),
      );
    } catch (e) {
      // Fallback: try POST if GET returns method not allowed or specific endpoint requirement
      try {
        final response = await _apiService.post(UrlHelpers.chatInfo, data: {'params': {}});
        final resData = response.data;
        if (resData == null) return null;

        final dataMap = resData is Map
            ? (resData['result'] is Map ? resData['result'] : resData)
            : {};

        return ChatInfo.fromJson(
          dataMap is Map<String, dynamic> ? dataMap : Map<String, dynamic>.from(dataMap),
        );
      } catch (err) {
        return null;
      }
    }
  }
}

