import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';

class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      // API call to be implemented
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        user: null, // Replace with real API call later
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final profileProvider = StateNotifierProvider.family<ProfileNotifier, ProfileState, String>(
  (ref, userId) {
    final ProfileNotifier notifier = ProfileNotifier();
    notifier.loadProfile(userId);
    return notifier;
  },
);
