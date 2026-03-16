// example/main.dart
/// Example of using gamif_scanner programmatically.
///
/// Normally you run it via the command line:
/// ```sh
/// dart pub global activate gamif_scanner
/// dart pub global run gamif_scanner:setup .
/// ```
library;

import 'package:gamif_scanner/gamif_scanner.dart';

Future<void> main() async {
  const projectPath = '/path/to/your/flutter/project';

  // 1. Scan the project
  final scanner = ProjectScanner(projectPath: projectPath);
  final methods = await scanner.scanProject();
  print('Found ${methods.length} methods');

  // 2. Inject tracking into selected methods
  final injector = CodeInjector(projectPath: projectPath);
  final result = await injector.inject(
    selectedMethods: methods.take(3).toList(),
    apiKey: 'your_api_key_here',
  );
  print('Injected: ${result.injectedCount}');
}