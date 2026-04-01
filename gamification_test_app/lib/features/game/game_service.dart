import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';

class GameService {
  int _currentLevel = 1;
  int _playerScore = 0;
  bool _specialActionEnabled = false; // ← nouvelle variable

  Future<Map<String, dynamic>> loadPlayerProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {'userId': userId, 'level': _currentLevel, 'score': _playerScore};
  }

  Future<void> completeLevel(int level) async {
    String _gamifStatus_completeLevel = 'PENDING';
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentLevel = level + 1;
      _playerScore += level * 100;
      print('🏆 Level $level completed! Score: $_playerScore');
      _gamifStatus_completeLevel = 'SUCCESS';
    } catch (e) {
      _gamifStatus_completeLevel = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('completeLevel',
          data: {'status': _gamifStatus_completeLevel});
    }
  }

  Future<bool> startMission(String missionId) async {
    String _gamifStatus_startMission = 'PENDING';
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      print('🚀 Mission started: $missionId');
      _gamifStatus_startMission = 'SUCCESS';
      return true;
    } catch (e) {
      _gamifStatus_startMission = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('startMission',
          data: {'status': _gamifStatus_startMission});
    }
  }

  Future<int> completeMission(String missionId, bool success) async {
    String _gamifStatus_completeMission = 'PENDING';
    try {
      final reward = success ? 500 : 0;
      _playerScore += reward;
      _gamifStatus_completeMission = 'SUCCESS';
      return reward;
    } catch (e) {
      _gamifStatus_completeMission = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('completeMission',
          data: {'status': _gamifStatus_completeMission});
    }
  }

  void earnPoints(int points, String reason) {
    String _gamifStatus_earnPoints = 'PENDING';
    try {
      _playerScore += points;
      _gamifStatus_earnPoints = 'SUCCESS';
    } catch (e) {
      _gamifStatus_earnPoints = 'FAILED';
      rethrow;
    } finally {
      GamifTracker.track('earnPoints',
          data: {'status': _gamifStatus_earnPoints});
    }
  }

  int getCurrentScore() => _playerScore;

  // === NOUVELLES MÉTHODES POUR L’ACTION CONDITIONNÉE ===

  /// Active le droit d’exécuter l’action spéciale.
  Future<void> enableSpecialAction() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _specialActionEnabled = true;
    print('🔓 Action spéciale activée !');
    await GamifTracker.track('enable_special_action');
  }

  /// Action qui ne peut être exécutée que si enableSpecialAction() a été appelée.
  Future<void> performSpecialAction() async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_performSpecialAction = 'PENDING';
    try {

    if (!_specialActionEnabled) {
      print('⛔ Action non autorisée : activez-la d’abord.');
      _gamifStatus_performSpecialAction = 'SUCCESS';
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    _playerScore += 1000;
    print('✨ Action spéciale exécutée ! +1000 points. Score total : $_playerScore');
    await GamifTracker.track('perform_special_action', data: {
      'score': _playerScore,
      'enabled': _specialActionEnabled,
    });
  
      _gamifStatus_performSpecialAction = 'SUCCESS';
    } catch (e) {
      _gamifStatus_performSpecialAction = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('performSpecialAction', data: {'status': _gamifStatus_performSpecialAction});
    }
}
}