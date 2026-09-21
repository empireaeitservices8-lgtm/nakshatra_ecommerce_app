// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_center.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqItem _$FaqItemFromJson(Map<String, dynamic> json) => FaqItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );

Map<String, dynamic> _$FaqItemToJson(FaqItem instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
    };

HelpCenterResponse _$HelpCenterResponseFromJson(Map<String, dynamic> json) =>
    HelpCenterResponse(
      status: json['status'] as String? ?? '',
      faqs: (json['faqs'] as List<dynamic>?)
              ?.map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HelpCenterResponseToJson(HelpCenterResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'faqs': instance.faqs.map((e) => e.toJson()).toList(),
    };
