import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';

class ShopService {
  int _balance = 1000;
  final Map<String, int> _inventory = {};

  Future<bool> purchaseItem(String itemId, int price) async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_purchaseItem = 'PENDING';
    try {

    

   
    await Future.delayed(const Duration(milliseconds: 400));
    if (_balance < price) _gamifStatus_purchaseItem = 'SUCCESS';
    return false;
    _balance -= price;
    _inventory[itemId] = (_inventory[itemId] ?? 0) + 1;
    print('🛒 Purchased: $itemId');
    _gamifStatus_purchaseItem = 'SUCCESS';
    return true;
  
      _gamifStatus_purchaseItem = 'SUCCESS';
    } catch (e) {
      _gamifStatus_purchaseItem = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('purchaseItem', data: {'status': _gamifStatus_purchaseItem});
    }
}

  Future<int> sellItem(String itemId, int sellPrice) async {
    // 🎮 auto-injecté (try-finally)
    String _gamifStatus_sellItem = 'PENDING';
    try {

   

  
    _balance += sellPrice;
    _inventory.remove(itemId);
    print('💰 Sold: $itemId');
    _gamifStatus_sellItem = 'SUCCESS';
    return sellPrice;
  
      _gamifStatus_sellItem = 'SUCCESS';
    } catch (e) {
      _gamifStatus_sellItem = 'FAILED';
      rethrow;
    } finally {
      await GamifTracker.track('sellItem', data: {'status': _gamifStatus_sellItem});
    }
}

  Future<List<String>> openLootBox(String lootBoxId) async {
   

   
    await Future.delayed(const Duration(seconds: 1));
    return ['item_a', 'coins_50', 'xp_boost'];
  }

  int getBalance() => _balance;
}