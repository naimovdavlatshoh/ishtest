import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_version.dart';
import 'mobile_version_api.dart';

class VersionCheckState {
  const VersionCheckState({
    this.isChecking = true,
    this.decision = VersionUpdateDecision.none,
    this.storeUrl,
  });

  final bool isChecking;
  final VersionUpdateDecision decision;
  final String? storeUrl;
}

class VersionCheckNotifier extends StateNotifier<VersionCheckState> {
  VersionCheckNotifier({
    required MobileVersionApi api,
    required AppPlatform platform,
    required Future<String?> Function() readCurrentVersion,
  })  : _api = api,
        _platform = platform,
        _readCurrentVersion = readCurrentVersion,
        super(const VersionCheckState()) {
    _check();
  }

  final MobileVersionApi _api;
  final AppPlatform _platform;
  final Future<String?> Function() _readCurrentVersion;

  Future<void> _check() async {
    try {
      final String? currentVersion = await _readCurrentVersion();
      final MobileVersionCatalog? catalog = await _api.fetch();
      final VersionUpdate update = resolveVersionUpdate(
        currentVersion: currentVersion,
        catalog: catalog,
        platform: _platform,
      );
      state = VersionCheckState(
        isChecking: false,
        decision: update.decision,
        storeUrl: update.storeUrl,
      );
    } catch (_) {
      state = const VersionCheckState(isChecking: false);
    }
  }
}

AppPlatform currentAppPlatform() {
  if (kIsWeb) return AppPlatform.other;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return AppPlatform.ios;
    case TargetPlatform.android:
      return AppPlatform.android;
    default:
      return AppPlatform.other;
  }
}

Future<String?> readInstalledVersion() async {
  try {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final String version = info.version.trim();
    if (version.isEmpty) return null;
    return version;
  } catch (_) {
    return null;
  }
}

final versionCheckProvider =
    StateNotifierProvider<VersionCheckNotifier, VersionCheckState>((ref) {
  return VersionCheckNotifier(
    api: MobileVersionApi(),
    platform: currentAppPlatform(),
    readCurrentVersion: readInstalledVersion,
  );
});
