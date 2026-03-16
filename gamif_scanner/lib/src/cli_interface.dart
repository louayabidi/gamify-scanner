import 'dart:io';
import 'package:path/path.dart' as p;
import 'method_info.dart';

/// Interactive command-line interface for method selection and injection.
class CliInterface {
  /// Displays detected methods and lets the user select which ones to track.
  Future<List<MethodInfo>> selectMethods(
    List<MethodInfo> allMethods,
    String projectPath,
  ) async {
    // Grouper par fichier
    final byFile = <String, List<MethodInfo>>{};
    for (final m in allMethods) {
      final rel = p.relative(m.filePath, from: projectPath);
      byFile.putIfAbsent(rel, () => []).add(m);
    }

    // Afficher avec numéros
    final indexed = <int, MethodInfo>{};
    int idx = 1;

    print('');
    for (final entry in byFile.entries) {
      print('  📁 ${entry.key}');
      for (final m in entry.value) {
        if (!m.isSuggestedToIgnore) {
          final asyncTag = m.isAsync ? ' [async]' : '';
          print('    [$idx] ${m.displayName}$asyncTag');
          indexed[idx] = m;
          idx++;
        } else {
          print('    [ ] ${m.displayName} ← ignoré par défaut');
        }
      }
      print('');
    }

    print('  ─────────────────────────────────────────');
    print('  Entrer les numéros séparés par virgule (ex: 1,3,5)');
    print('  ou appuyer ENTRÉE pour tout sélectionner :');
    print('');
    stdout.write('  Ton choix > ');

    final input = stdin.readLineSync()?.trim() ?? '';

    if (input.isEmpty) {
      return allMethods.where((m) => !m.isSuggestedToIgnore).toList();
    }

    final nums = input
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>();
    return nums.map((n) => indexed[n]).whereType<MethodInfo>().toList();
  }

/// Prompts the user to enter their Gamify API key.
  Future<String> askApiKey() async {
    print('');
    stdout.write('  🔑 Clé API > ');
    return stdin.readLineSync()?.trim() ?? '';
  }

/// Asks the user to confirm before proceeding with injection.
  Future<bool> confirmInjection(List<MethodInfo> methods) async {
    print('');
    print('  📋 Récapitulatif :');
    print('  • GamifSDK.init() → main.dart');
    for (final m in methods) {
      print('  • GamifTracker.track() → ${m.displayName}');
    }
    print('');
    stdout.write('  Continuer ? [o/N] > ');
    final answer = stdin.readLineSync()?.trim().toLowerCase() ?? 'n';
    return answer == 'o' || answer == 'oui';
  }
}