import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint) async {
    // 🎮 auto-injecté
    print('[GamifTracker] get tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] get tracked');

    await Future.delayed(const Duration(milliseconds: 300));
    print('GET $baseUrl/$endpoint');
    return {'status': 'ok'};
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    // 🎮 auto-injecté
    print('[GamifTracker] post tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] post tracked');

    await Future.delayed(const Duration(milliseconds: 400));
    print('POST $baseUrl/$endpoint');
    return {'status': 'ok'};
  }
}