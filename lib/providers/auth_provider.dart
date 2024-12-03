import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelance_project/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return UserDataNotifier(ref);
});

class UserDataNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  UserDataNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        loadUserData(next.value!.uid);
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> loadUserData(String uid) async {
    try {
      state = const AsyncValue.loading();
      final userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      state = AsyncValue.data(userData.data());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
