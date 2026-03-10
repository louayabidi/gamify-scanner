import 'dart:io';
import 'dart:convert';
import 'project_scanner.dart';
import 'code_injector.dart';
import 'method_info.dart';

class WebUIServer {
  final String projectPath;
  WebUIServer({required this.projectPath});

  Future<void> start() async {
    final server =
        await HttpServer.bind(InternetAddress.loopbackIPv4, 9090);
    print('  🌐 Ouvre http://localhost:9090 dans ton navigateur');

    // Ouvrir le navigateur automatiquement
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', 'http://localhost:9090']);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['http://localhost:8080']);
      } else {
        await Process.run('xdg-open', ['http://localhost:8080']);
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
        ..write(_html())
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

  String _html() => '''
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Gamification SDK Setup</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, sans-serif; background: #0f0f1a; color: #e0e0e0; }
    header { background: linear-gradient(135deg,#5e35b1,#a855f7); padding: 20px 32px; }
    header h1 { color: #fff; font-size: 20px; }
    .wrap { max-width: 860px; margin: 0 auto; padding: 28px 20px; }
    .card { background: #1a1a2e; border: 1px solid #2d2d4a; border-radius: 10px; padding: 20px; margin-bottom: 20px; }
    .card h2 { color: #a855f7; font-size: 15px; margin-bottom: 14px; }
    button { background: #5e35b1; color: #fff; border: none; padding: 10px 20px; border-radius: 7px; cursor: pointer; font-size: 14px; width: 100%; }
    button:hover { background: #7c4fd5; }
    button:disabled { background: #333; cursor: not-allowed; }
    .file-group { margin-bottom: 14px; }
    .file-name { font-size: 12px; color: #60a5fa; font-family: monospace; padding: 4px 8px; background: #0f1729; border-radius: 4px; margin-bottom: 6px; }
    label { display: flex; align-items: center; gap: 9px; padding: 7px 10px; border-radius: 5px; cursor: pointer; font-size: 14px; }
    label:hover { background: #252540; }
    input[type=checkbox] { width: 15px; height: 15px; accent-color: #a855f7; }
    .badge { font-size: 11px; background: #2d1f4a; color: #c084fc; padding: 2px 6px; border-radius: 4px; }
    .ignored { opacity: 0.4; }
    input[type=password] { width: 100%; background: #0f0f1a; border: 1px solid #3d3d5c; color: #e0e0e0; padding: 9px 12px; border-radius: 7px; font-size: 14px; margin-top: 8px; }
    .summary { background: #0f1a0f; border: 1px solid #1a4a1a; border-radius: 7px; padding: 10px 14px; margin-bottom: 14px; color: #4ade80; font-size: 14px; }
    .privacy { background: #1a1a0a; border: 1px solid #3a3a10; border-radius: 7px; padding: 10px 14px; margin-bottom: 14px; font-size: 13px; color: #b8b860; }
    .result { text-align: center; padding: 20px; }
    .result h3 { color: #4ade80; font-size: 18px; margin-bottom: 8px; }
    .row { display: flex; gap: 8px; margin-bottom: 12px; }
    .sm { background: #2d2d4a; color: #e0e0e0; border: none; padding: 5px 12px; border-radius: 5px; cursor: pointer; font-size: 12px; width: auto; }
  </style>
</head>
<body>
<header><h1>🎮 Gamification SDK — Setup Tool</h1></header>
<div class="wrap">

  <div class="card">
    <h2>🔍 Étape 1 — Scanner le projet</h2>
    <button onclick="scan()" id="scanBtn">🔍 Lancer le scan</button>
  </div>

  <div class="card" id="selCard" style="display:none">
    <h2>☑️ Étape 2 — Choisir les méthodes</h2>
    <div class="row">
      <button class="sm" onclick="all()">✅ Tout</button>
      <button class="sm" onclick="none()">❌ Aucun</button>
      <button class="sm" onclick="smart()">🤖 Intelligent</button>
    </div>
    <div id="list"></div>
  </div>

  <div class="card" id="injectCard" style="display:none">
    <h2>🔑 Étape 3 — Clé API et injection</h2>
    <div class="summary" id="summary"></div>
    <label style="font-size:13px;color:#9ca3af;display:block">Clé API SDK</label>
    <input type="password" id="apiKey" placeholder="gam_sk_xxxxxxxx">
    <div class="privacy" style="margin-top:12px">
      🔒 Le scan est 100% local. Aucun code source n'est envoyé à nos serveurs.
    </div>
    <button onclick="inject()" id="injectBtn" style="margin-top:12px">💉 Injecter le SDK</button>
  </div>

  <div class="card" id="resultCard" style="display:none">
    <div class="result">
      <h3>🎉 Setup terminé !</h3>
      <p id="resultText" style="color:#9ca3af"></p>
    </div>
  </div>

</div>
<script>
let methods = [];

async function scan() {
  const btn = document.getElementById('scanBtn');
  btn.disabled = true; btn.textContent = '⏳ Scan...';
  const res = await fetch('/api/scan');
  methods = await res.json();
  renderList();
  document.getElementById('selCard').style.display = 'block';
  document.getElementById('injectCard').style.display = 'block';
  btn.textContent = '✅ ' + methods.length + ' méthodes trouvées';
  updateSummary();
}

function renderList() {
  const byFile = {};
  methods.forEach(m => { if (!byFile[m.filePath]) byFile[m.filePath] = []; byFile[m.filePath].push(m); });
  let html = '';
  for (const [file, list] of Object.entries(byFile)) {
    const parts = file.replace(/\\\\/g, '/').split('/');
    const rel = parts.slice(parts.indexOf('lib')).join('/');
    html += '<div class="file-group"><div class="file-name">📄 ' + rel + '</div>';
    list.forEach(m => {
      const ign = m.isSuggestedToIgnore;
      html += '<label class="' + (ign ? 'ignored' : '') + '">'
            + '<input type="checkbox" ' + (!ign ? 'checked' : '') + ' onchange="updateSummary()" data-m=\\'' + JSON.stringify(m).replace(/'/g,'&apos;') + '\\'>'
            + m.displayName
            + (m.isAsync ? ' <span class="badge">async</span>' : '')
            + '</label>';
    });
    html += '</div>';
  }
  document.getElementById('list').innerHTML = html;
}

function getSelected() {
  return [...document.querySelectorAll('[data-m]:checked')].map(c => JSON.parse(c.getAttribute('data-m')));
}
function updateSummary() {
  document.getElementById('summary').textContent = '✅ ' + getSelected().length + ' méthode(s) sélectionnée(s)';
}
function all()   { document.querySelectorAll('[data-m]').forEach(c => c.checked = true);  updateSummary(); }
function none()  { document.querySelectorAll('[data-m]').forEach(c => c.checked = false); updateSummary(); }
function smart() { document.querySelectorAll('[data-m]').forEach(c => { const m = JSON.parse(c.getAttribute('data-m')); c.checked = !m.isSuggestedToIgnore; }); updateSummary(); }

async function inject() {
  const apiKey = document.getElementById('apiKey').value.trim();
  if (!apiKey) { alert('Entre ta clé API !'); return; }
  const selected = getSelected();
  if (!selected.length) { alert('Sélectionne au moins une méthode !'); return; }
  const btn = document.getElementById('injectBtn');
  btn.disabled = true; btn.textContent = '⏳ Injection...';
  const res = await fetch('/api/inject', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ apiKey, methods: selected })
  });
  const r = await res.json();
  document.getElementById('resultCard').style.display = 'block';
  document.getElementById('resultText').textContent = r.injectedCount + ' injection(s) réussie(s) !';
  btn.textContent = '✅ Terminé !';
}
</script>
</body>
</html>
''';
}