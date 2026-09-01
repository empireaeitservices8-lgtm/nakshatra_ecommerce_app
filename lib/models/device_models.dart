class DeviceModel {
  final String id;
  final String deviceName;
  final String deviceType;
  final String serialNumber;
  final String status;
  final String? assignedTo;
  final String? ipAddress;

  const DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.serialNumber,
    required this.status,
    this.assignedTo,
    this.ipAddress,
  });

  factory DeviceModel.fromJson(Map<dynamic, dynamic> json) => DeviceModel(
        id: (json['id'] ?? '').toString(),
        deviceName: json['device_name'] as String? ?? 'Unnamed Device',
        deviceType: json['device_type'] as String? ?? 'Standard',
        serialNumber: json['serial_number'] as String? ?? '',
        status: json['status'] as String? ?? 'Offline',
        assignedTo: json['assigned_to'] as String?,
        ipAddress: json['ip_address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_name': deviceName,
        'device_type': deviceType,
        'serial_number': serialNumber,
        'status': status,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (ipAddress != null) 'ip_address': ipAddress,
      };
}

class DeviceTypeModel {
  final String id;
  final String typeName;
  final String code;

  const DeviceTypeModel({
    required this.id,
    required this.typeName,
    required this.code,
  });

  factory DeviceTypeModel.fromJson(Map<dynamic, dynamic> json) => DeviceTypeModel(
        id: (json['id'] ?? '').toString(),
        typeName: json['type_name'] as String? ?? '',
        code: json['code'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type_name': typeName,
        'code': code,
      };
}

class AddDeviceRequest {
  final String deviceName;
  final String deviceTypeId;
  final String serialNumber;
  final String? assignedToUserId;

  const AddDeviceRequest({
    required this.deviceName,
    required this.deviceTypeId,
    required this.serialNumber,
    this.assignedToUserId,
  });

  Map<String, dynamic> toJson() => {
        'device_name': deviceName,
        'device_type_id': deviceTypeId,
        'serial_number': serialNumber,
        if (assignedToUserId != null) 'assigned_to_user_id': assignedToUserId,
      };

  factory AddDeviceRequest.fromJson(Map<String, dynamic> json) => AddDeviceRequest(
        deviceName: json['device_name'] as String? ?? '',
        deviceTypeId: json['device_type_id'] as String? ?? '',
        serialNumber: json['serial_number'] as String? ?? '',
        assignedToUserId: json['assigned_to_user_id'] as String?,
      );
}
