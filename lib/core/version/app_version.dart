enum AppPlatform { ios, android, other }

enum VersionUpdateDecision { none, optional, required }

class VersionUpdate {
  const VersionUpdate({
    required this.decision,
    this.storeUrl,
  });

  const VersionUpdate.none()
      : decision = VersionUpdateDecision.none,
        storeUrl = null;

  final VersionUpdateDecision decision;
  final String? storeUrl;
}

/// Numeric `major.minor.patch` comparison. Build metadata (`+8`) and a
/// pre-release suffix are ignored so the installed version matches the
/// store versions returned by `/mobile/version`.
int compareAppVersions(String left, String right) {
  final List<int> a = _versionParts(left);
  final List<int> b = _versionParts(right);
  final int length = a.length > b.length ? a.length : b.length;
  for (int i = 0; i < length; i++) {
    final int av = i < a.length ? a[i] : 0;
    final int bv = i < b.length ? b[i] : 0;
    if (av != bv) return av.compareTo(bv);
  }
  return 0;
}

List<int> _versionParts(String raw) {
  final String core = raw.split('+').first.split('-').first.trim();
  if (core.isEmpty) return const <int>[0];
  return core.split('.').map((String part) => int.tryParse(part) ?? 0).toList();
}

/// `current < minimum` blocks the app, `current < latest` suggests an
/// update, and anything else (including a missing policy) lets the user in.
VersionUpdate resolveVersionUpdate({
  required String? currentVersion,
  required MobileVersionCatalog? catalog,
  required AppPlatform platform,
}) {
  final String? current = currentVersion?.trim();
  if (current == null || current.isEmpty || catalog == null) {
    return const VersionUpdate.none();
  }

  final PlatformVersionPolicy? policy = catalog.forPlatform(platform);
  if (policy == null) return const VersionUpdate.none();

  if (compareAppVersions(current, policy.minimumVersion) < 0) {
    return VersionUpdate(
      decision: VersionUpdateDecision.required,
      storeUrl: policy.storeUrl,
    );
  }
  if (compareAppVersions(current, policy.latestVersion) < 0) {
    return VersionUpdate(
      decision: VersionUpdateDecision.optional,
      storeUrl: policy.storeUrl,
    );
  }
  return const VersionUpdate.none();
}

class PlatformVersionPolicy {
  const PlatformVersionPolicy({
    required this.latestVersion,
    required this.minimumVersion,
    required this.storeUrl,
  });

  final String latestVersion;
  final String minimumVersion;
  final String storeUrl;

  static PlatformVersionPolicy? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final Object? latest = json['latest_version'];
    final Object? minimum = json['minimum_version'];
    final Object? storeUrl = json['store_url'];
    if (latest is! String || latest.trim().isEmpty) return null;
    if (minimum is! String || minimum.trim().isEmpty) return null;
    if (storeUrl is! String) return null;
    return PlatformVersionPolicy(
      latestVersion: latest.trim(),
      minimumVersion: minimum.trim(),
      storeUrl: storeUrl.trim(),
    );
  }
}

class MobileVersionCatalog {
  const MobileVersionCatalog({this.ios, this.android});

  final PlatformVersionPolicy? ios;
  final PlatformVersionPolicy? android;

  PlatformVersionPolicy? forPlatform(AppPlatform platform) {
    switch (platform) {
      case AppPlatform.ios:
        return ios;
      case AppPlatform.android:
        return android;
      case AppPlatform.other:
        return null;
    }
  }

  static MobileVersionCatalog? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    return MobileVersionCatalog(
      ios: PlatformVersionPolicy.fromJson(json['ios']),
      android: PlatformVersionPolicy.fromJson(json['android']),
    );
  }
}
