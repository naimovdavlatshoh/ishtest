import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linkedin_clone/core/version/app_version.dart';
import 'package:linkedin_clone/core/version/mobile_version_api.dart';

void main() {
  const String payload = '''
{
  "ios": {
    "latest_version": "1.0.2",
    "minimum_version": "1.0.0",
    "store_url": "https://apps.apple.com/uz/app/ish-uz/id6777630919"
  },
  "android": {
    "latest_version": "1.0.1",
    "minimum_version": "1.0.0",
    "store_url": "https://play.google.com/store/apps/details?id=uz.ish.app"
  }
}
''';

  MobileVersionCatalog catalog() {
    return MobileVersionCatalog.fromJson(jsonDecode(payload))!;
  }

  VersionUpdate resolve(String current, AppPlatform platform) {
    return resolveVersionUpdate(
      currentVersion: current,
      catalog: catalog(),
      platform: platform,
    );
  }

  test('current below minimum requires an update', () {
    final VersionUpdate update = resolve('0.9.0', AppPlatform.ios);
    expect(update.decision, VersionUpdateDecision.required);
    expect(update.storeUrl, 'https://apps.apple.com/uz/app/ish-uz/id6777630919');
  });

  test('current between minimum and latest suggests an update', () {
    final VersionUpdate update = resolve('1.0.0', AppPlatform.android);
    expect(update.decision, VersionUpdateDecision.optional);
    expect(
      update.storeUrl,
      'https://play.google.com/store/apps/details?id=uz.ish.app',
    );
  });

  test('current equal to latest shows nothing', () {
    expect(resolve('1.0.2', AppPlatform.ios).decision, VersionUpdateDecision.none);
    expect(resolve('1.0.1', AppPlatform.android).decision, VersionUpdateDecision.none);
  });

  test('current newer than latest shows nothing', () {
    expect(resolve('1.0.3+8', AppPlatform.ios).decision, VersionUpdateDecision.none);
  });

  test('missing catalog or version does not block', () {
    expect(
      resolveVersionUpdate(
        currentVersion: '0.1.0',
        catalog: null,
        platform: AppPlatform.ios,
      ).decision,
      VersionUpdateDecision.none,
    );
    expect(
      resolveVersionUpdate(
        currentVersion: null,
        catalog: catalog(),
        platform: AppPlatform.ios,
      ).decision,
      VersionUpdateDecision.none,
    );
    expect(
      resolveVersionUpdate(
        currentVersion: '0.1.0',
        catalog: catalog(),
        platform: AppPlatform.other,
      ).decision,
      VersionUpdateDecision.none,
    );
  });

  test('fetch uses the public path and no authorization header', () async {
    late http.Request captured;
    final MobileVersionApi api = MobileVersionApi(
      baseUrl: 'https://api.example.com',
      client: MockClient((http.Request request) async {
        captured = request;
        return http.Response(payload, 200);
      }),
    );

    final MobileVersionCatalog? result = await api.fetch();

    expect(captured.method, 'GET');
    expect(captured.url.toString(), 'https://api.example.com/mobile/version');
    expect(
      captured.headers.keys.map((String key) => key.toLowerCase()),
      isNot(contains('authorization')),
    );
    expect(result?.ios?.latestVersion, '1.0.2');
    expect(result?.android?.minimumVersion, '1.0.0');
  });

  test('non-200 and invalid json do not block', () async {
    final MobileVersionApi down = MobileVersionApi(
      client: MockClient((http.Request request) async => http.Response('nope', 503)),
    );
    final MobileVersionApi broken = MobileVersionApi(
      client: MockClient((http.Request request) async => http.Response('{', 200)),
    );

    expect(await down.fetch(), isNull);
    expect(await broken.fetch(), isNull);
  });
}
