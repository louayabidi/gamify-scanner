import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'features/auth/auth_service.dart';
import 'features/game/game_service.dart';
import 'features/shop/shop_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GamifSDK.init(
    apiKey: 'gam_kH_ZOuiS6G5awBGV_YV5-jgubAwL7bSgxdrbH_5Gqq8',
    baseUrl: 'http://localhost:8081',
  );
  await GamificationSDK.instance.identify('user_127');
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
      appBar: AppBar(
        title: const Text('🎮 Game App'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GamifPointsWidget(          // ✅ ici c'est correct
              backgroundColor: Colors.purple,
              label: 'pts',
              showLifetime: true,
            ),
          ),
        ],
      ),
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
              onPressed: () {
                _auth.printWelcomeMessage();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Message affiché dans la console'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('📋 Message Bienvenue'),
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _game.enableSpecialAction();
                setState(() {});
              },
              child: const Text('🔓 Activer action spéciale'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _game.performSpecialAction();
                setState(() {});
              },
              child: const Text('✨ Action spéciale (validée)'),
            ),
          ],
        ),
      ),
    );
  }
}