import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';

class ShopService {
  int _balance = 1000;
  final Map<String, int> _inventory = {};

  Future<bool> purchaseItem(String itemId, int price) async {
    // 🎮 auto-injecté
    print('[GamifTracker] purchaseItem tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] purchaseItem tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] purchaseItem tracked');

    // 🎮 auto-injecté
    GamifTracker.track('purchaseItem');
    await Future.delayed(const Duration(milliseconds: 400));
    if (_balance < price) return false;
    _balance -= price;
    _inventory[itemId] = (_inventory[itemId] ?? 0) + 1;
    print('🛒 Purchased: $itemId');
    return true;
  }

  Future<int> sellItem(String itemId, int sellPrice) async {
    // 🎮 auto-injecté
    print('[GamifTracker] sellItem tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] sellItem tracked');

    // 🎮 auto-injecté
    GamifTracker.track('sellItem');
    _balance += sellPrice;
    _inventory.remove(itemId);
    print('💰 Sold: $itemId');
    return sellPrice;
  }

  Future<List<String>> openLootBox(String lootBoxId) async {
    // 🎮 auto-injecté
    print('[GamifTracker] openLootBox tracked');

    // 🎮 auto-injecté
    print('[GamifTracker] openLootBox tracked');

    // 🎮 auto-injecté
    GamifTracker.track('openLootBox');
    await Future.delayed(const Duration(seconds: 1));
    return ['item_a', 'coins_50', 'xp_boost'];
  }

  int getBalance() => _balance;
}