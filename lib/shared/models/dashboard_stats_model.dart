class DashboardStats {
  final int profileViews;
  final int jobsApplied;
  final int connections;
  final int notifications;

  const DashboardStats({
    required this.profileViews,
    required this.jobsApplied,
    required this.connections,
    required this.notifications,
  });

  static const DashboardStats empty = DashboardStats(
    profileViews: 0,
    jobsApplied: 0,
    connections: 0,
    notifications: 0,
  );

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      profileViews: (json['profileViews'] as num?)?.toInt() ?? 0,
      jobsApplied: (json['jobsApplied'] as num?)?.toInt() ?? 0,
      connections: (json['connections'] as num?)?.toInt() ?? 0,
      notifications: (json['notifications'] as num?)?.toInt() ?? 0,
    );
  }
}

