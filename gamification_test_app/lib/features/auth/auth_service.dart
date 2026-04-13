import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';

class AuthService {
  String? _currentUser;
  bool _isEmailVerified = false;

  // ✅ FONCTION DÉPENDANTE : Ne peut s'exécuter que si login est complété
  Future<bool> verifyEmail() async {
    if (_currentUser == null) {
      print('❌ Erreur : Vous devez d\'abord vous connecter (login)');
      return false;
    }

    print('📧 Vérification d\'email pour: $_currentUser');
    
    try {
      // Attendre 30 secondes pour simuler la vérification
      print('⏳ Vérification en cours... (30 secondes)');
      await Future.delayed(const Duration(seconds: 30));
      
      _isEmailVerified = true;
      print('✅ Email vérifié: $_currentUser');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
      rethrow;
    } finally {
      await GamifTracker.track('email_verified', 
        data: {'user': _currentUser});
    }
  }

  // ✅ FONCTION AVEC DÉLAI : Affiche "Hello" après 1 minute
  Future<void> delayedHelloMessage() async {
    print('⏳ Attente de 1 minute avant le message...');
    await Future.delayed(const Duration(minutes: 1));
    print('👋 HELLO! Message après 1 minute');
  }

  // ✅ FONCTION INDÉPENDANTE : Pas de gamification
  void printWelcomeMessage() {
    final timestamp = DateTime.now();
    print('👋 Bienvenue à $timestamp');
    print('Utilisateur actuel: ${_currentUser ?? "Aucun"}');
    print('Email vérifié: $_isEmailVerified');
    // Cette fonction n'appelle pas GamifTracker
  }

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
    } catch (e) {
      _gamifStatus_login = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('login', data: {'status': _gamifStatus_login});
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isEmailVerified = false;
    print('👋 Logged out');
  }

  bool isAuthenticated() => _currentUser != null;
  bool isEmailVerified() => _isEmailVerified;

  Future<bool> register(
      String email, String password, String username) async {
    await Future.delayed(const Duration(seconds: 1));
    print('🆕 Registered: $username');
    return true;
  }
}