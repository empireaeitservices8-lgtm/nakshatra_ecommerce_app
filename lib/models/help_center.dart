import 'package:json_annotation/json_annotation.dart';

part 'help_center.g.dart';

@JsonSerializable()
class FaqItem {
  final int id;
  final String question;
  final String answer;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      _$FaqItemFromJson(json);

  Map<String, dynamic> toJson() => _$FaqItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HelpCenterResponse {
  final String status;
  final List<FaqItem> faqs;

  HelpCenterResponse({
    required this.status,
    required this.faqs,
  });

  factory HelpCenterResponse.fromJson(Map<String, dynamic> json) =>
      _$HelpCenterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HelpCenterResponseToJson(this);
}

class ChatInfo {
  final String status;
  final String whatsappNumber;
  final String availability;
  final String chatLink;

  ChatInfo({
    this.status = '',
    this.whatsappNumber = '',
    this.availability = '',
    this.chatLink = '',
  });

  factory ChatInfo.fromJson(Map<String, dynamic> json) {
    return ChatInfo(
      status: json['status']?.toString() ?? '',
      whatsappNumber: (json['whatsapp_number'] ?? json['whatsappNumber'])?.toString() ?? '',
      availability: json['availability']?.toString() ?? '',
      chatLink: (json['chat_link'] ?? json['chatLink'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'whatsapp_number': whatsappNumber,
        'availability': availability,
        'chat_link': chatLink,
      };
}

