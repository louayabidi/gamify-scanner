import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class AuthService {
  String? _currentUser;



Future<bool> login(String email, String password) async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_login = 'PENDING';
    try {

    print('⏳ Connexion : veuillez patienter 1 minute...');
    await Future.delayed(const Duration(minutes: 1));
    
    _currentUser = email;
    print('✅ Logged in: $email');
    _gamifStatus_login = 'SUCCESS';
    return true;
  
      _gamifStatus_login = 'SUCCESS';
    } catch (e) {
      _gamifStatus_login = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('login', data: {'status': _gamifStatus_login});
    }
}






  Future<void> logout() async {
  

    
   

    _currentUser = null;
    print('👋 Logged out');
  }

bool isAuthenticated() => _currentUser != null;

  Future<bool> register(
      String email, String password, String username) async {
   

    await Future.delayed(const Duration(seconds: 1));
    print('🆕 Registered: $username');
    return true;
  }
}