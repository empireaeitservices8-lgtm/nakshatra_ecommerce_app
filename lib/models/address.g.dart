// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      id: (json['id'] ?? json['address_id'] ?? '').toString(),
      label: (json['type'] ?? json['label'] ?? '').toString(),
      name: (json['recipient_name'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address_details'] ?? json['address'] ?? '').toString(),
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.label,
      'recipient_name': instance.name,
      'phone': instance.phone,
      'address_details': instance.address,
    };

AddressListResponse _$AddressListResponseFromJson(Map<String, dynamic> json) =>
    AddressListResponse(
      status: json['status'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AddressListResponseToJson(
        AddressListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'count': instance.count,
      'addresses': instance.addresses.map((e) => e.toJson()).toList(),
    };
