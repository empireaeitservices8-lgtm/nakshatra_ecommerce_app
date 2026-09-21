class Branch {
  final int id;
  final String name;
  final String code;
  final String city;

  Branch({
    required this.id,
    required this.name,
    this.code = '',
    this.city = '',
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Branch && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
