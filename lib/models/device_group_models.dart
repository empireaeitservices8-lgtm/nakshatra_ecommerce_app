class DeviceGroupModel {
  final String id;
  final String groupName;
  final String description;
  final int deviceCount;
  final String createdAt;

  const DeviceGroupModel({
    required this.id,
    required this.groupName,
    required this.description,
    required this.deviceCount,
    required this.createdAt,
  });

  factory DeviceGroupModel.fromJson(Map<dynamic, dynamic> json) => DeviceGroupModel(
        id: (json['id'] ?? '').toString(),
        groupName: json['group_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        deviceCount: json['device_count'] as int? ?? 0,
        createdAt: json['created_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'group_name': groupName,
        'description': description,
        'device_count': deviceCount,
        'created_at': createdAt,
      };
}

class AddDeviceGroupRequest {
  final String groupName;
  final String description;

  const AddDeviceGroupRequest({
    required this.groupName,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'group_name': groupName,
        'description': description,
      };

  factory AddDeviceGroupRequest.fromJson(Map<String, dynamic> json) => AddDeviceGroupRequest(
        groupName: json['group_name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}
