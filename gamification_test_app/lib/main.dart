import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'features/auth/auth_service.dart';
import 'features/game/game_service.dart';
import 'features/shop/shop_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🎮 Gamification SDK
  await GamifSDK.init(apiKey: 'gam_kH_ZOuiS6G5awBGV_YV5-jgubAwL7bSgxdrbH_5Gqq8');
  await GamificationSDK.instance.identify('user_123');
  print('✅ SDK initialisé et user identifié');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _game = GameService();
  final _shop = ShopService();

  @override
  void initState() {
    super.initState();
    _game.loadPlayerProfile('user_123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 Game App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _auth.login('user@test.com', 'pass123'),
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _game.completeLevel(5),
              child: const Text('Complete Level 5'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _shop.purchaseItem('sword_001', 150),
              child: const Text('Buy Sword'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _game.startMission('mission_dragon'),
              child: const Text('Start Mission'),
            ),
          ],
        ),
      ),
    );
  }
}