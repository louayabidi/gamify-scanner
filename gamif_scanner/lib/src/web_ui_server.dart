import 'dart:io';
import 'dart:convert';
import 'project_scanner.dart';
import 'code_injector.dart';
import 'method_info.dart';
import 'web_ui_template.dart'; // ← ajouter cet import

/// Local HTTP server providing a browser-based UI for scanning and injecting
/// gamification tracking code into a Flutter project.
class WebUIServer {
  /// The absolute path to the root of the Flutter project.
  final String projectPath;

  /// Creates a [WebUIServer] for the given [projectPath].
  WebUIServer({required this.projectPath});

  /// Starts the HTTP server on port 9090 and opens the browser.
  Future<void> start() async {
    final server =
        await HttpServer.bind(InternetAddress.loopbackIPv4, 9090);
    print('  🌐 Ouvre http://localhost:9090 dans ton navigateur');

    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', 'http://localhost:9090']);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['http://localhost:9090']);
      } else {
        await Process.run('xdg-open', ['http://localhost:9090']);
      }
    } catch (_) {}

    await for (final req in server) {
      await _handle(req);
    }
  }

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path;

    if (path == '/' || path == '/index.html') {
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(buildWebUIHtml()) // ← appel vers le template
        ..close();
    } else if (path == '/api/scan') {
      final scanner = ProjectScanner(projectPath: projectPath);
      final methods = await scanner.scanProject();
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..write(jsonEncode(methods.map((m) => m.toJson()).toList()))
        ..close();
    } else if (path == '/api/inject' && req.method == 'POST') {
      final body = await utf8.decoder.bind(req).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final apiKey = data['apiKey'] as String;
      final list = data['methods'] as List;

      final selected = list
          .map((m) => MethodInfo(
                name: m['name'],
                className: m['className'],
                filePath: m['filePath'],
                bodyOffset: m['bodyOffset'],
                isAsync: m['isAsync'],
                lineNumber: m['lineNumber'],
              ))
          .toList();

      final injector = CodeInjector(projectPath: projectPath);
      final result =
          await injector.inject(selectedMethods: selected, apiKey: apiKey);

      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..write(jsonEncode({
          'success': true,
          'injectedCount': result.injectedCount,
          'errors': result.errors,
        }))
        ..close();
    } else {
      req.response
        ..statusCode = 404
        ..close();
    }
  }
}