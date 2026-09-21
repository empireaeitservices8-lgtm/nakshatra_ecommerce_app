import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String id;
  @JsonKey(name: 'type')
  final String label;
  @JsonKey(name: 'recipient_name')
  final String name;
  final String phone;
  @JsonKey(name: 'address_details')
  final String address;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
  });

  // Backward-compatible and API alias getters
  String get type => label;
  String get recipientName => name;
  String get addressDetails => address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AddressListResponse {
  final String status;
  final int count;
  final List<Address> addresses;

  AddressListResponse({
    required this.status,
    required this.count,
    required this.addresses,
  });

  factory AddressListResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressListResponseToJson(this);
}
