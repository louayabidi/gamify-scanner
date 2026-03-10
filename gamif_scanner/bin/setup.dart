import 'dart:io';
import 'package:path/path.dart' as p;
import '../lib/src/project_scanner.dart';
import '../lib/src/code_injector.dart';
import '../lib/src/cli_interface.dart';
import '../lib/src/web_ui_server.dart';

void main(List<String> args) async {
  final projectPath =
      args.isNotEmpty ? args[0] : Directory.current.path;

  print('');
  print('  ╔══════════════════════════════════════╗');
  print('  ║   🎮  Gamification SDK Setup Tool   ║');
  print('  ╚══════════════════════════════════════╝');
  print('  Projet : $projectPath');
  print('');

  // Vérifier pubspec.yaml
  if (!File(p.join(projectPath, 'pubspec.yaml')).existsSync()) {
    print('  ❌ Aucun pubspec.yaml trouvé !');
    exit(1);
  }

  // Choisir l'interface
  print('  [1] 💻  CLI (terminal)');
  print('  [2] 🌐  Web UI (navigateur)');
  print('');
  stdout.write('  Choix [1/2] > ');
  final choice = stdin.readLineSync()?.trim() ?? '1';

  if (choice == '2') {
    print('');
    print('  🌐 Lancement du serveur...');
    final server = WebUIServer(projectPath: projectPath);
    await server.start();
    return;
  }

  // ── CLI MODE ──────────────────────────────────────
  print('');
  print('  🔍 Scan en cours...');
  print('');

  final scanner = ProjectScanner(projectPath: projectPath);
  final allMethods = await scanner.scanProject();

  if (allMethods.isEmpty) {
    print('  ⚠️  Aucune méthode trouvée.');
    exit(0);
  }

  print('  ✅ ${allMethods.length} méthodes trouvées !');

  // Sélection via CLI
  final cli = CliInterface();
  final selected = await cli.selectMethods(allMethods, projectPath);

  if (selected.isEmpty) {
    print('  ⚠️  Aucune méthode sélectionnée. Annulation.');
    exit(0);
  }

  // Clé API
  final apiKey = await cli.askApiKey();
  if (apiKey.isEmpty) {
    print('  ❌ Clé API requise.');
    exit(1);
  }

  // Confirmation
  final confirmed = await cli.confirmInjection(selected);
  if (!confirmed) {
    print('  ✋ Annulé.');
    exit(0);
  }

  // Injection
  print('');
  print('  💉 Injection en cours...');
  print('');

  final injector = CodeInjector(projectPath: projectPath);
  final result =
      await injector.inject(selectedMethods: selected, apiKey: apiKey);

  print('');
  print('  ╔══════════════════════════════════════╗');
  print('  ║        ✅  Setup Terminé !           ║');
  print('  ╚══════════════════════════════════════╝');
  print('  ${result.injectedCount} injection(s) réussie(s)');
  for (final e in result.errors) print(e);
  print('');
}