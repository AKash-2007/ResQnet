enum EmergencyType { medical, fire, accident, sos }

enum EmergencyStatus { active, responding, resolved, cancelled }

class EmergencyIncidentModel {
  final String id;
  final String requesterId;
  final EmergencyType emergencyType;
  final EmergencyStatus status;
  final double latitude;
  final double longitude;
  final String? addressHint;
  final int helpersNotifiedCount;
  final int helpersRespondingCount;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final bool isDemo;

  const EmergencyIncidentModel({
    required this.id,
    required this.requesterId,
    required this.emergencyType,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.addressHint,
    this.helpersNotifiedCount = 0,
    this.helpersRespondingCount = 0,
    required this.createdAt,
    this.resolvedAt,
    this.isDemo = false,
  });

  EmergencyIncidentModel copyWith({
    String? id,
    String? requesterId,
    EmergencyType? emergencyType,
    EmergencyStatus? status,
    double? latitude,
    double? longitude,
    String? addressHint,
    int? helpersNotifiedCount,
    int? helpersRespondingCount,
    DateTime? createdAt,
    DateTime? resolvedAt,
    bool? isDemo,
  }) {
    return EmergencyIncidentModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      emergencyType: emergencyType ?? this.emergencyType,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressHint: addressHint ?? this.addressHint,
      helpersNotifiedCount: helpersNotifiedCount ?? this.helpersNotifiedCount,
      helpersRespondingCount: helpersRespondingCount ?? this.helpersRespondingCount,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'emergency_type': emergencyType.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'latitude': latitude,
      'longitude': longitude,
      'address_hint': addressHint,
      'helpers_notified_count': helpersNotifiedCount,
      'helpers_responding_count': helpersRespondingCount,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'is_demo': isDemo,
    };
  }

  factory EmergencyIncidentModel.fromJson(Map<String, dynamic> json) {
    EmergencyType parseType(String? val) {
      switch (val?.toUpperCase()) {
        case 'FIRE':
          return EmergencyType.fire;
        case 'ACCIDENT':
          return EmergencyType.accident;
        case 'SOS':
          return EmergencyType.sos;
        case 'MEDICAL':
        default:
          return EmergencyType.medical;
      }
    }

    EmergencyStatus parseStatus(String? val) {
      switch (val?.toUpperCase()) {
        case 'RESPONDING':
          return EmergencyStatus.responding;
        case 'RESOLVED':
          return EmergencyStatus.resolved;
        case 'CANCELLED':
          return EmergencyStatus.cancelled;
        case 'ACTIVE':
        default:
          return EmergencyStatus.active;
      }
    }

    return EmergencyIncidentModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      emergencyType: parseType(json['emergency_type'] as String?),
      status: parseStatus(json['status'] as String?),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressHint: json['address_hint'] as String?,
      helpersNotifiedCount: (json['helpers_notified_count'] as num?)?.toInt() ?? 0,
      helpersRespondingCount: (json['helpers_responding_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      isDemo: json['is_demo'] as bool? ?? false,
    );
  }
}
