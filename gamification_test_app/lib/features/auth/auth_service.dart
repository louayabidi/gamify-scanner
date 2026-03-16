import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class AuthService {
  String? _currentUser;

  Future<bool> login(String email, String password) async {
    // 🎮 auto-injecté
    await GamifTracker.track('login');

   

    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = email;
    print('✅ Logged in: $email');
    return true;
  }

  Future<void> logout() async {
   

    _currentUser = null;
    print('👋 Logged out');
  }

  bool isAuthenticated() => _currentUser != null;

  Future<bool> register(
      String email, String password, String username) async {
    // 🎮 auto-injecté
    await GamifTracker.track('register');

    

    await Future.delayed(const Duration(seconds: 1));
    print('🆕 Registered: $username');
    return true;
  }
}