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
    src = src.replaceAll('void main() async async {', 'void main() async {');

    final initCode =
        '\n  // 🎮 Gamification SDK\n  await GamifSDK.init(apiKey: \'$apiKey\', baseUrl: \'http://localhost:8081\');\n';

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

  Future<void> _injectFile(String filePath, List<MethodInfo> methods) async {
    var src = File(filePath).readAsStringSync();

    // Trier par offset DÉCROISSANT pour ne pas décaler les positions
    final sorted = [...methods]
      ..sort((a, b) => b.bodyOffset.compareTo(a.bodyOffset));

    for (final m in sorted) {
      src = _wrapBody(src, m); // ← 2 arguments seulement
    }

    // Ajouter l'import si absent
    const imp =
        "import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';\n";
    if (!src.contains('gamification_flutter_sdk')) {
      src = imp + src;
    }

    File(filePath).writeAsStringSync(src);
  }

  String _wrapBody(String src, MethodInfo m) {
    final open = m.bodyOffset;
    final statusVar = '_gamifStatus_${m.name}';

    // ── 1. Trouver le `}` fermant ──────────────────────────────
    int depth = 0;
    int closePos = -1;
    for (int i = open; i < src.length; i++) {
      if (src[i] == '{') depth++;
      if (src[i] == '}') {
        depth--;
        if (depth == 0) {
          closePos = i;
          break;
        }
      }
    }
    if (closePos == -1) return src;

    // ── 2. Extraire le corps original ──────────────────────────
    final originalBody = src.substring(open + 1, closePos);

    // ── 3. Injecter SUCCESS avant chaque `return` ──────────────
    final patched = _injectSuccessBeforeReturns(originalBody, statusVar);

    // ── 4. Construire le wrapper try-finally ───────────────────
    final trackCall = m.isAsync
        ? "await GamifTracker.track('${m.name}', data: {'status': $statusVar});"
        : "GamifTracker.track('${m.name}', data: {'status': $statusVar});";

    final newBody = '''
{
    // 🎮 auto-injecté (try-finally)
    String $statusVar = 'PENDING';
    try {
$patched
      $statusVar = 'SUCCESS';
    } catch (e) {
      $statusVar = 'FAILED';
      rethrow;
    } finally {
      $trackCall
    }
}''';

    return src.substring(0, open) + newBody + src.substring(closePos + 1);
  }

  String _injectSuccessBeforeReturns(String body, String statusVar) {
    final buffer = StringBuffer();
    int i = 0;

    while (i < body.length) {
      // ── Triple-quotes strings ───────────────────────────────
      if (i + 2 < body.length &&
          (body.substring(i, i + 3) == "'''" ||
              body.substring(i, i + 3) == '"""')) {
        final quote = body.substring(i, i + 3);
        final end = body.indexOf(quote, i + 3);
        if (end == -1) {
          buffer.write(body.substring(i));
          break;
        }
        buffer.write(body.substring(i, end + 3));
        i = end + 3;
        continue;
      }

      // ── Single/double quote strings ─────────────────────────
      if (body[i] == '"' || body[i] == "'") {
        final quote = body[i];
        buffer.write(quote);
        i++;
        while (i < body.length) {
          if (body[i] == '\\') {
            buffer.write(body[i]);
            i++;
          }
          if (i < body.length) {
            buffer.write(body[i]);
            if (body[i] == quote) {
              i++;
              break;
            }
            i++;
          }
        }
        continue;
      }

      // ── Commentaires ligne ──────────────────────────────────
      if (i + 1 < body.length && body.substring(i, i + 2) == '//') {
        final end = body.indexOf('\n', i);
        if (end == -1) {
          buffer.write(body.substring(i));
          break;
        }
        buffer.write(body.substring(i, end + 1));
        i = end + 1;
        continue;
      }

      // ── Commentaires bloc ───────────────────────────────────
      if (i + 1 < body.length && body.substring(i, i + 2) == '/*') {
        final end = body.indexOf('*/', i + 2);
        if (end == -1) {
          buffer.write(body.substring(i));
          break;
        }
        buffer.write(body.substring(i, end + 2));
        i = end + 2;
        continue;
      }

      // ── Détecter `return` ───────────────────────────────────
      if (body.substring(i).startsWith('return') &&
          _isKeywordBoundary(body, i, 'return')) {
        final indent = _getLineIndent(body, i);
        buffer.write("$statusVar = 'SUCCESS';\n$indent");
        buffer.write('return');
        i += 'return'.length;
        continue;
      }

      buffer.write(body[i]);
      i++;
    }

    return buffer.toString();
  }

  bool _isKeywordBoundary(String src, int pos, String keyword) {
    if (pos > 0) {
      final before = src[pos - 1];
      if (RegExp(r'[a-zA-Z0-9_]').hasMatch(before)) return false;
    }
    final after = pos + keyword.length;
    if (after < src.length) {
      final next = src[after];
      if (RegExp(r'[a-zA-Z0-9_]').hasMatch(next)) return false;
    }
    return true;
  }

  String _getLineIndent(String src, int pos) {
    int lineStart = pos;
    while (lineStart > 0 && src[lineStart - 1] != '\n') lineStart--;
    int indent = lineStart;
    while (indent < src.length &&
        (src[indent] == ' ' || src[indent] == '\t')) {
      indent++;
    }
    return src.substring(lineStart, indent);
  }

  Future<void> _saveConfig(List<MethodInfo> methods, String apiKey) async {
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
      final uri =
          Uri.parse('http://localhost:8081/api/events/register');

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
      print('  ⚠️  Dashboard inaccessible (mode offline)');
    }
  }
}