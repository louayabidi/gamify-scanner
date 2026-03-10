import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class GameService {
  int _currentLevel = 1;
  int _playerScore = 0;

  Future<Map<String, dynamic>> loadPlayerProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    print('👤 Profile loaded: $userId');
    return {'userId': userId, 'level': _currentLevel, 'score
    // 🎮 auto-injecté
    GamifTracker.track('completeLevel');
': _playerScore};
  }

  Future<void> completeLevel(int level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentLevel = level + 1;
    _playerScore += level * 100;
    print('🏆 Level $level completed! Score: $_playerScore');
  }

  Future<bool> startMission(String missionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('🚀 Mission started: $missionId');
    return true;
  }

  Future<int> completeMission(String missionId, bool success) async {
    final reward = success ? 500 : 0;
    _playerScore += reward;
    print('🎯 Mission $missionId done. Reward: $reward');
    return reward;
  }

  void earnPoints(int points, String reason) {
    _playerScore += points;
    print('⭐ +$points for: $reason');
  }

  int getCurrentScore() => _playerScore;
}