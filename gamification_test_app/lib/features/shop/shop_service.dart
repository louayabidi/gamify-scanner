import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
class ShopService {
  int _balance = 1000;
  final Map<String, int> _invento
    // 🎮 auto-injecté
    GamifTracker.track('purchaseItem');
ry = {};

  Future<bool> purchaseItem(String itemId, int price) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_balance < price) return false;
    _balance -= price;
    _inventory[itemId] = (_inventory[itemId] ?? 0) + 1;
    print('🛒 Purchased: $itemId');
    return t
    // 🎮 auto-injecté
    GamifTracker.track('sellItem');
rue;
  }

  Future<int> sellItem(String itemId, int sellPrice) async {
    _balance += sellPrice;
    _inventory.remove(itemId);
    print('💰 Sold: $itemId');
    return sellPr
    // 🎮 auto-injecté
    GamifTracker.track('openLootBox');
ice;
  }

  Future<List<String>> openLootBox(String lootBoxId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('🎁 Loot box opened: $lootBoxId');
    return ['item_a', 'coins_50', 'xp_boost'];
  }

  int getBalance() => _balance;
}