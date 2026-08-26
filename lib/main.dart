import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/utils/app_messenger.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
