class NearbyStatsModel {
  final int totalUsers;
  final int maleCount;
  final int femaleCount;
  final int otherCount;
  final int radiusMeters;
  final bool isMaskedForPrivacy;
  final bool isDemo;

  const NearbyStatsModel({
    required this.totalUsers,
    required this.maleCount,
    required this.femaleCount,
    this.otherCount = 0,
    this.radiusMeters = 1000,
    this.isMaskedForPrivacy = false,
    this.isDemo = false,
  });

  factory NearbyStatsModel.fromJson(Map<String, dynamic> json) {
    return NearbyStatsModel(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      maleCount: (json['male_count'] as num?)?.toInt() ?? 0,
      femaleCount: (json['female_count'] as num?)?.toInt() ?? 0,
      otherCount: (json['other_count'] as num?)?.toInt() ?? 0,
      radiusMeters: (json['radius_meters'] as num?)?.toInt() ?? 1000,
      isMaskedForPrivacy: json['is_masked_for_privacy'] as bool? ?? false,
      isDemo: json['is_demo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'male_count': maleCount,
      'female_count': femaleCount,
      'other_count': otherCount,
      'radius_meters': radiusMeters,
      'is_masked_for_privacy': isMaskedForPrivacy,
      'is_demo': isDemo,
    };
  }
}
