import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/services/device_registration_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/utils/app_messenger.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Explicit container (instead of the implicit one `ProviderScope` creates)
  // so ApiClient -- a plain Dart class outside the widget tree -- can read
  // and mutate providers when a request comes back with an expired token.
  final ProviderContainer container = ProviderContainer();

  // Every API call in the app goes through ApiClient. Whenever the backend
  // answers 401 (access token expired/invalid), log the user out here in
  // one place instead of relying on each screen to notice on its own.
  // authProvider.logout() clears the stored token and flips
  // isAuthenticated to false, which the router (see app_router.dart's
  // routerListenableProvider) is already listening for -- it then
  // redirects to /login automatically.
  ApiClient.onUnauthorized = () {
    container.read(authProvider.notifier).logout();
    showGlobalSnackBar(
      'Sessiya muddati tugadi. Iltimos, qaytadan tizimga kiring.',
      isError: true,
    );
  };

  // Registers the FCM token with the backend (POST /api/v1/devices)
  // whenever one is issued or refreshed. A no-op while signed out --
  // DeviceRegistrationService.register() skips silently without an
  // access token -- so this also covers the case where the token
  // arrives before login.
  PushNotificationService.instance.onToken = (String token) {
    debugPrint('FCM token: $token');
    DeviceRegistrationService.instance.register(token);
  };
  await PushNotificationService.instance.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
