class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? groupName;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.groupName,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json) => UserModel(
        id: (json['id'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'User',
        status: json['status'] as String? ?? 'Active',
        groupName: json['group_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        if (groupName != null) 'group_name': groupName,
      };
}

class AddUserRequest {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? groupId;

  const AddUserRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        if (groupId != null) 'group_id': groupId,
      };

  factory AddUserRequest.fromJson(Map<String, dynamic> json) => AddUserRequest(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'User',
        groupId: json['group_id'] as String?,
      );
}
