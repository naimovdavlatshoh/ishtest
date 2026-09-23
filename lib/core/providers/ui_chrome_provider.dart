import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets a full-screen child (e.g. an individual chat room) tell the shared
/// [MainScreen] shell to hide its bottom nav bar while it's on top, without
/// depending on the router recomputing per-route chrome — which the go_router
/// ShellRoute doesn't reliably do for routes pushed within the same shell.
final hideBottomNavProvider = StateProvider<bool>((ref) => false);
