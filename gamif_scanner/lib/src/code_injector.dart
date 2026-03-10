import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'method_info.dart';


class InjectionResult {
  final int injectedCount;
  final List<String> errors;
  InjectionResult({required this.injectedCount, required this.errors});
}

class CodeInjector {
  final String projectPath;
  CodeInjector({required this.projectPath});

  Future<InjectionResult> inject({
    required List<MethodInfo> selectedMethods,
    required String apiKey,
  }) async {
    int count = 0;
    final errors = <String>[];

    if (await _injectInit(apiKey)) {
      count++;
      print('  ✅ GamifSDK.init() ajouté dans main.dart');
    } else {
      errors.add('  ⚠️  init() déjà présent dans main.dart');
    }

    final byFile = <String, List<MethodInfo>>{};
    for (final m in selectedMethods) {
      byFile.putIfAbsent(m.filePath, () => []).add(m);
    }

    for (final entry in byFile.entries) {
      try {
        await _injectFile(entry.key, entry.value);
        count += entry.value.length;
        final rel = p.relative(entry.key, from: projectPath);
        print('  ✅ ${entry.value.length} track(s) → $rel');
      } catch (e) {
        errors.add('  ❌ ${entry.key}: $e');
      }
    }

    await _saveConfig(selectedMethods, apiKey);
    await _registerEventsToBackend(selectedMethods, apiKey);
    return InjectionResult(injectedCount: count, errors: errors);
  }

  Future<bool> _injectInit(String apiKey) async {
    final mainPath = p.join(projectPath, 'lib', 'main.dart');
    final file = File(mainPath);
    if (!file.existsSync()) return false;

    var src = file.readAsStringSync();
    if (src.contains('GamifSDK.init(')) return false;

    const imp =
        "import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';\n";
    if (!src.contains('gamification_flutter_sdk')) src = imp + src;

    src = src.replaceAll('void main() {', 'void main() async {');
    src = src.replaceAll(
        'void main() async async {', 'void main() async {');

    final initCode =
        '\n  // 🎮 Gamification SDK\n  await GamifSDK.init(apiKey: \'$apiKey\');\n';

    if (src.contains('WidgetsFlutterBinding.ensureInitialized();')) {
      src = src.replaceFirst(
        'WidgetsFlutterBinding.ensureInitialized();',
        'WidgetsFlutterBinding.ensureInitialized();$initCode',
      );
    } else {
      src = src.replaceFirst(
        'void main() async {',
        'void main() async {$initCode',
      );
    }

    file.writeAsStringSync(src);
    return true;
  }

  Future<void> _injectFile(
    String filePath, List<MethodInfo> methods) async {
  var src = File(filePath).readAsStringSync();

  // ✅ Trier par offset DÉCROISSANT
  final sorted = [...methods]
    ..sort((a, b) => b.bodyOffset.compareTo(a.bodyOffset));

  // ✅ Injecter D'ABORD — avant d'ajouter l'import
  for (final m in sorted) {
    final trackCode =
        '\n    // 🎮 auto-injecté\n    print(\'[GamifTracker] ${m.name} tracked\');\n';
    final pos = m.bodyOffset + 1;
    src = src.substring(0, pos) + trackCode + src.substring(pos);
  }

  // ✅ Ajouter l'import APRÈS l'injection
  const imp =
      "import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';\n";
  if (!src.contains('gamification_flutter_sdk')) {
    src = imp + src;
  }

  File(filePath).writeAsStringSync(src);
}

  Future<void> _saveConfig(
      List<MethodInfo> methods, String apiKey) async {
    final configPath = p.join(projectPath, '.gamif_config.json');
    final config = {
      'apiKey': apiKey,
      'injectedAt': DateTime.now().toIso8601String(),
      'methods': methods
          .map((m) => {
                'name': m.name,
                'class': m.className,
                'file': p.relative(m.filePath, from: projectPath),
              })
          .toList(),
    };
    File(configPath).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(config));
    print('  💾 Config → .gamif_config.json');
  }


Future<void> _registerEventsToBackend(
  List<MethodInfo> methods,
  String apiKey,
) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse(
       'http://localhost:8081/api/events/register' 
      // ⚠️ remplace par ton vrai URL backend
    );

    final request = await client.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('X-Api-Key', apiKey);

    final body = jsonEncode({
      'events': methods.map((m) => m.name).toList(),
    });

    request.write(body);
    final response = await request.close();

    if (response.statusCode == 200) {
      print('  ✅ Méthodes envoyées au dashboard');
    } else {
      print('  ⚠️  Dashboard retourne : ${response.statusCode}');
    }

    client.close();
  } catch (e) {
    // Ne pas bloquer si pas de connexion
    print('  ⚠️  Dashboard inaccessible (mode offline)');
  }
}

}