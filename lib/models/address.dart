class Address {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String address;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: (json['address_id'] ?? json['id'] ?? '').toString(),
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
