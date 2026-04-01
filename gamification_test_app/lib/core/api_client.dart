import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint) async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_get = 'PENDING';
    try {

   
   

   
   

    await Future.delayed(const Duration(milliseconds: 300));
    print('GET $baseUrl/$endpoint');
    _gamifStatus_get = 'SUCCESS';
    return {'status': 'ok'};
  
      _gamifStatus_get = 'SUCCESS';
    } catch (e) {
      _gamifStatus_get = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('get', data: {'status': _gamifStatus_get});
    }
}

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_post = 'PENDING';
    try {

   

    
    

    await Future.delayed(const Duration(milliseconds: 400));
    print('POST $baseUrl/$endpoint');
    _gamifStatus_post = 'SUCCESS';
    return {'status': 'ok'};
  
      _gamifStatus_post = 'SUCCESS';
    } catch (e) {
      _gamifStatus_post = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('post', data: {'status': _gamifStatus_post});
    }
}
}