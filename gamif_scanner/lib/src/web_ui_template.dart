/// HTML/CSS/JS template for the gamif_scanner Web UI.
String buildWebUIHtml() => r'''
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>gamif_scanner — Setup Tool</title>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&family=Syne:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg:      #07060f;
      --bg2:     #0e0c1a;
      --bg3:     #161428;
      --border:  rgba(139,92,246,0.15);
      --border2: rgba(139,92,246,0.3);
      --purple:  #8b5cf6;
      --purple2: #a78bfa;
      --purple3: #6d28d9;
      --green:   #34d399;
      --blue:    #60a5fa;
      --red:     #f87171;
      --text:    #f1f0fb;
      --muted:   #7c7a99;
      --mono:    'JetBrains Mono', monospace;
      --sans:    'Syne', sans-serif;
    }

    html, body {
      height: 100%;
      background: var(--bg);
      color: var(--text);
      font-family: var(--sans);
      font-size: 14px;
      line-height: 1.5;
    }

    @keyframes jelly {
      0%, 100% { transform: scale(1, 1); }
      25%       { transform: scale(0.9, 1.1); }
      50%       { transform: scale(1.1, 0.9); }
      75%       { transform: scale(0.95, 1.05); }
    }

    @keyframes left-swing {
      50%, 100% { transform: translateX(95%); }
    }
    @keyframes right-swing {
      50%  { transform: translateX(-95%); }
      100% { transform: translateX(100%); }
    }

    @keyframes foolishIn {
      0%   { opacity:0; transform-origin:50% 50%; transform:scale(0,0) rotate(360deg); }
      20%  { opacity:1; transform-origin:0% 100%; transform:scale(0.5,0.5) rotate(0deg); }
      40%  { opacity:1; transform-origin:100% 100%; transform:scale(0.5,0.5) rotate(0deg); }
      60%  { opacity:1; transform-origin:0%; transform:scale(0.5,0.5) rotate(0deg); }
      80%  { opacity:1; transform-origin:0% 0%; transform:scale(0.5,0.5) rotate(0deg); }
      100% { opacity:1; transform-origin:50% 50%; transform:scale(1,1) rotate(0deg); }
    }
    .foolish-in { animation: foolishIn 1s both; }

    .balls {
      width: 3em;
      display: flex;
      flex-flow: row nowrap;
      align-items: center;
      justify-content: space-between;
    }
    .balls div {
      width: 0.6em; height: 0.6em;
      border-radius: 50%;
      background-color: #ffffff;
    }
    .balls div:nth-of-type(1) { transform: translateX(-100%); animation: left-swing 0.5s ease-in alternate infinite; }
    .balls div:nth-of-type(3) { transform: translateX(-95%);  animation: right-swing 0.5s ease-out alternate infinite; }

    /* ── HEADER ── */
    .header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 16px 28px;
      background: var(--bg2);
      border-bottom: 1px solid var(--border);
      position: sticky; top: 0; z-index: 10;
    }
    .logo { display: flex; align-items: center; gap: 10px; font-size: 15px; font-weight: 600; letter-spacing: -0.3px; }
    .logo-icon {
      width: 30px; height: 30px;
      background: linear-gradient(135deg, var(--purple3), var(--purple));
      border-radius: 8px;
      display: flex; align-items: center; justify-content: center;
      font-size: 15px;
    }
    .version {
      font-family: var(--mono); font-size: 11px; color: var(--muted);
      background: var(--bg3); padding: 3px 8px; border-radius: 4px;
      border: 1px solid var(--border);
    }

    /* ── STEPPER ── */
    .stepper {
      display: flex; align-items: center;
      padding: 14px 28px;
      background: var(--bg2);
      border-bottom: 1px solid var(--border);
    }
    .step { display: flex; align-items: center; gap: 8px; font-size: 12px; color: var(--muted); }
    .step.active { color: var(--purple2); }
    .step.done   { color: var(--green); }
    .step-num {
      width: 22px; height: 22px; border-radius: 50%;
      border: 1.5px solid currentColor;
      display: flex; align-items: center; justify-content: center;
      font-size: 10px; font-weight: 600; font-family: var(--mono);
      flex-shrink: 0; transition: all 0.3s;
    }
    .step.done .step-num { background: var(--green); border-color: var(--green); color: #07060f; }
    .step-label { font-weight: 500; }
    .step-arrow { color: var(--border2); margin: 0 12px; font-size: 12px; }

    /* ── LAYOUT ── */
    .layout {
      display: grid;
      grid-template-columns: 1fr 320px;
      min-height: calc(100vh - 106px);
    }
    .main    { padding: 28px; border-right: 1px solid var(--border); overflow-y: auto; }
    .sidebar { padding: 24px; background: var(--bg2); overflow-y: auto; }

    .section-title {
      font-size: 10px; font-weight: 600; letter-spacing: 0.12em;
      text-transform: uppercase; color: var(--muted); margin-bottom: 16px;
    }

    /* ── PROJECT STRUCTURE DROPDOWN ── */
    .proj-wrap {
      position: relative;
      display: inline-block;
      margin-bottom: 20px;
    }
    .proj-btn {
      background: var(--bg3);
      border: 1px solid var(--border2);
      border-radius: 8px;
      padding: 8px 14px;
      display: inline-flex;
      align-items: center;
      gap: 10px;
      cursor: pointer;
      font-size: 12px;
      color: var(--text);
      font-family: var(--sans);
      transition: border-color 0.2s, background 0.2s;
      user-select: none;
    }
    .proj-btn:hover { border-color: var(--purple); background: rgba(109,40,217,0.08); }
    .proj-hint {
      color: var(--muted);
      font-size: 10px;
      margin-left: auto;
      font-family: var(--mono);
    }
    .proj-dropdown {
      position: absolute;
      left: 0;
      top: calc(100% + 8px);
      width: 300px;
      background: var(--bg2);
      border: 1px solid var(--border2);
      border-radius: 10px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.6);
      opacity: 0;
      pointer-events: none;
      transform: translateY(-6px);
      transition: opacity 0.2s ease, transform 0.2s ease;
      z-index: 100;
      max-height: 360px;
      overflow-y: auto;
    }
    /* Show on hover */
    .proj-wrap:hover .proj-dropdown {
      opacity: 1;
      pointer-events: all;
      transform: translateY(0);
    }
    /* Dropdown header label */
    .proj-dropdown-header {
      padding: 10px 14px 8px;
      font-size: 10px;
      font-weight: 600;
      letter-spacing: 0.10em;
      text-transform: uppercase;
      color: var(--muted);
      border-bottom: 1px solid var(--border);
      font-family: var(--mono);
    }
    /* Tree list */
    .proj-tree {
      padding: 10px 0;
      font-family: var(--mono);
      font-size: 11px;
      line-height: 1;
    }
    .proj-tree li {
      list-style: none;
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 5px 14px;
      transition: background 0.1s;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .proj-tree li:hover { background: rgba(139,92,246,0.06); }
    .proj-tree .t-folder  { color: #FFCA28; }
    .proj-tree .t-dart    { color: var(--blue); }
    .proj-tree .t-yaml    { color: var(--green); }
    .proj-tree .t-lock    { color: var(--muted); }
    .proj-tree .t-md      { color: #fb923c; }
    .proj-tree .t-git     { color: var(--muted); }
    .proj-tree .t-name    { color: inherit; }
    .proj-tree .t-meta    {
      margin-left: auto;
      font-size: 9px;
      color: var(--muted);
      opacity: 0.6;
      flex-shrink: 0;
    }
    /* indent levels */
    .proj-tree .d0 { padding-left: 14px; }
    .proj-tree .d1 { padding-left: 28px; }
    .proj-tree .d2 { padding-left: 42px; }
    .proj-tree .d3 { padding-left: 56px; }
    .proj-tree .d4 { padding-left: 70px; }

    /* ── SCAN AREA ── */
    .scan-area {
      border: 1.5px dashed var(--border2);
      border-radius: 12px; padding: 48px 32px;
      text-align: center; background: var(--bg2);
      transition: border-color 0.2s, background 0.2s;
    }
    .scan-area:hover    { border-color: var(--purple); }
    .scan-area.scanning { border-color: var(--purple); background: rgba(109,40,217,0.05); }
    .scan-area.error    { border-color: var(--red); }
    .scan-icon {
      width: 56px; height: 56px;
      background: rgba(139,92,246,0.1);
      border: 1.5px solid rgba(139,92,246,0.25);
      border-radius: 14px;
      display: flex; align-items: center; justify-content: center;
      font-size: 22px; margin: 0 auto 16px;
    }
    .scan-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
    .scan-sub   { font-size: 12px; color: var(--muted); font-family: var(--mono); margin-bottom: 24px; }

    /* ── BUTTONS ── */
    .btn {
      background: var(--purple3); color: #fff; border: none;
      padding: 10px 22px; border-radius: 8px; cursor: pointer;
      font-size: 13px; font-weight: 600; font-family: var(--sans);
      letter-spacing: 0.02em;
      transition: background 0.15s, opacity 0.15s;
      display: inline-flex; align-items: center; justify-content: center;
      gap: 7px; min-width: 160px;
    }
    .btn:hover:not(:disabled) { background: var(--purple); animation: jelly 0.5s; }
    .btn:disabled { opacity: 0.6; cursor: not-allowed; }
    .btn-full { width: 100%; }

    .btn-sm {
      background: var(--bg3); color: var(--text);
      border: 1px solid var(--border2);
      padding: 5px 11px; border-radius: 6px; cursor: pointer;
      font-size: 11px; font-weight: 500; font-family: var(--sans);
      transition: border-color 0.15s, color 0.15s;
      display: inline-flex; align-items: center; gap: 4px;
    }
    .btn-sm:hover { border-color: var(--purple); color: var(--purple2); }

    /* ── TOOLBAR ── */
    .toolbar {
      display: flex; align-items: center; justify-content: space-between;
      margin-bottom: 16px;
    }
    .toolbar-actions { display: flex; gap: 6px; }

    /* ── FILE GROUP ── */
    .file-group { margin-bottom: 12px; border: 1px solid var(--border); border-radius: 10px; overflow: hidden; }
    .file-header {
      display: flex; align-items: center; gap: 8px;
      padding: 9px 14px; background: var(--bg3);
      border-bottom: 1px solid var(--border);
      font-family: var(--mono); font-size: 11px; color: var(--blue);
    }
    .file-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--blue); opacity: 0.5; flex-shrink: 0; }

    /* ── METHOD ROW ── */
    .method {
      display: flex; align-items: center; gap: 10px;
      padding: 9px 14px; cursor: pointer;
      transition: background 0.1s;
      border-bottom: 1px solid var(--border);
    }
    .method:last-child { border-bottom: none; }
    .method:hover   { background: rgba(139,92,246,0.05); }
    .method.ignored { opacity: 0.35; }
    .method-check  { width: 14px; height: 14px; accent-color: var(--purple); flex-shrink: 0; cursor: pointer; }
    .method-name   { font-family: var(--mono); font-size: 12px; color: var(--text); flex: 1; }
    .method-line   { font-family: var(--mono); font-size: 10px; color: var(--muted); }

    /* ── BADGES ── */
    .badge { font-size: 10px; padding: 2px 6px; border-radius: 4px; font-family: var(--mono); font-weight: 500; }
    .badge-async { background: rgba(139,92,246,0.12); color: var(--purple2); border: 1px solid rgba(139,92,246,0.2); }
    .badge-skip  { background: rgba(124,122,153,0.08); color: var(--muted); border: 1px solid rgba(124,122,153,0.15); }

    /* ── STATS ── */
    .stats { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 20px; }
    .stat  { background: var(--bg3); border: 1px solid var(--border); border-radius: 8px; padding: 12px; }
    .stat-val   { font-size: 24px; font-weight: 700; font-family: var(--mono); color: var(--purple2); line-height: 1; }
    .stat-label { font-size: 10px; color: var(--muted); margin-top: 4px; text-transform: uppercase; letter-spacing: 0.06em; }

    .divider { height: 1px; background: var(--border); margin: 20px 0; }

    /* ── INPUT ── */
    .input-wrap { position: relative; margin-bottom: 10px; }
    .input {
      width: 100%; background: var(--bg); border: 1px solid var(--border2);
      color: var(--text); padding: 10px 12px 10px 36px;
      border-radius: 8px; font-size: 12px; font-family: var(--mono);
      outline: none; transition: border-color 0.2s;
    }
    .input:focus { border-color: var(--purple); }
    .input.error { border-color: var(--red); }
    .input::placeholder { color: var(--muted); }
    .input-icon {
      position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
      color: var(--muted); font-size: 12px; pointer-events: none;
    }

    /* ── PRIVACY ── */
    .privacy {
      display: flex; gap: 8px; align-items: flex-start;
      padding: 10px 12px;
      background: rgba(52,211,153,0.04); border: 1px solid rgba(52,211,153,0.12);
      border-radius: 8px; margin-bottom: 14px;
      font-size: 11px; color: #6ee7b7; line-height: 1.6;
    }

    /* ── SUCCESS ── */
    .success-wrap { text-align: center; padding: 40px 24px 24px; }
    .success-icon {
      width: 60px; height: 60px;
      background: rgba(52,211,153,0.08); border: 2px solid rgba(52,211,153,0.25);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 18px; font-size: 24px;
    }
    .success-title { font-size: 17px; font-weight: 600; color: var(--green); margin-bottom: 6px; }
    .success-sub   { font-size: 12px; color: var(--muted); margin-bottom: 20px; }

    /* ── LOG ── */
    .log {
      text-align: left; font-family: var(--mono); font-size: 11px; color: #4ade80;
      background: var(--bg); border: 1px solid var(--border);
      border-radius: 8px; padding: 12px 14px; line-height: 2;
      max-height: 200px; overflow-y: auto;
    }
    .log-line   { display: flex; gap: 8px; align-items: flex-start; }
    .log-prefix { color: var(--muted); flex-shrink: 0; }
    .log-err    { color: #f87171; }

    /* ── ABOUT ── */
    .about           { font-size: 11px; color: var(--muted); line-height: 1.9; font-family: var(--mono); }
    .about-highlight { color: var(--purple2); }

    /* ── SCROLLBAR ── */
    ::-webkit-scrollbar       { width: 4px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 4px; }
  </style>
</head>
<body>

<!-- HEADER -->
<div class="header">
  <div class="logo">
    <div class="logo-icon foolish-in">🎮</div>
    <span>gamif_scanner</span>
  </div>
  <div style="display:flex;gap:10px;align-items:center">
    <span class="version">v1.0.8</span>
    <span style="font-size:11px;color:var(--muted);font-family:var(--mono)">localhost:9090</span>
  </div>
</div>

<!-- STEPPER -->
<div class="stepper">
  <div class="step active" id="step1">
    <div class="step-num">1</div>
    <span class="step-label">Scan</span>
  </div>
  <span class="step-arrow">›</span>
  <div class="step" id="step2">
    <div class="step-num">2</div>
    <span class="step-label">Sélection</span>
  </div>
  <span class="step-arrow">›</span>
  <div class="step" id="step3">
    <div class="step-num">3</div>
    <span class="step-label">Injection</span>
  </div>
</div>

<!-- LAYOUT -->
<div class="layout">
  <div class="main">

    <!-- BLOCK 1 : SCAN -->
    <div id="scanBlock">
      <div class="section-title">Analyse du projet</div>
      <div class="scan-area" id="scanArea">
        <div class="scan-icon foolish-in">⬡</div>
        <div class="scan-title">Analyse AST du projet Flutter</div>
        <div class="scan-sub">Détecte toutes les méthodes Dart via l'Abstract Syntax Tree</div>
        <button class="btn" onclick="scan()" id="scanBtn">
          <span id="scanBtnContent">⬡ Lancer le scan</span>
        </button>
      </div>
    </div>

    <!-- BLOCK 2 : SELECTION -->
    <div id="selBlock" style="display:none">

      <!-- PROJECT STRUCTURE HOVER DROPDOWN -->
      <div class="proj-wrap" id="projWrap" style="display:none">
        <div class="proj-btn">
          <!-- Folder icon (same SVG as original) -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 14" height="16" width="16">
            <path fill="#FFA000" d="M16.2 1.75H8.1L6.3 0H1.8C0.81 0 0 0.7875 0 1.75V12.25C0 13.2125 0.81 14 1.8 14H15.165L18 9.1875V3.5C18 2.5375 17.19 1.75 16.2 1.75Z"/>
            <path fill="#FFCA28" d="M16.2 2H1.8C0.81 2 0 2.77143 0 3.71429V12.2857C0 13.2286 0.81 14 1.8 14H16.2C17.19 14 18 13.2286 18 12.2857V3.71429C18 2.77143 17.19 2 16.2 2Z"/>
          </svg>
          <span>Project Structure</span>
          <span class="proj-hint">hover ▾</span>
        </div>
        <div class="proj-dropdown">
          <div class="proj-dropdown-header">gamif_scanner /</div>
          <ul class="proj-tree" id="projTree"></ul>
        </div>
      </div>

      <div class="toolbar">
        <div class="section-title" style="margin:0">Méthodes détectées</div>
        <div class="toolbar-actions">
          <button class="btn-sm" onclick="all()">✓ Tout</button>
          <button class="btn-sm" onclick="none()">✕ Aucun</button>
          <button class="btn-sm" onclick="smart()">⬡ Intelligent</button>
        </div>
      </div>
      <div id="methodList"></div>
    </div>

    <!-- BLOCK 3 : RÉSULTAT -->
    <div id="resultBlock" style="display:none">
      <div class="success-wrap">
        <div class="success-icon">✓</div>
        <div class="success-title">Injection réussie !</div>
        <div class="success-sub" id="resultSub"></div>
        <div class="log" id="logBox"></div>
      </div>
    </div>

  </div><!-- /.main -->

  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="stats">
      <div class="stat">
        <div class="stat-val" id="totalCount">—</div>
        <div class="stat-label">Méthodes</div>
      </div>
      <div class="stat">
        <div class="stat-val" id="selCount">—</div>
        <div class="stat-label">Sélectionnées</div>
      </div>
    </div>

    <div id="injectBlock" style="display:none">
      <div class="divider"></div>
      <div class="section-title">Configuration</div>
      <div style="font-size:11px;color:var(--muted);margin-bottom:8px">Clé API Gamify</div>
      <div class="input-wrap">
        <span class="input-icon">🔑</span>
        <input type="password" class="input" id="apiKey"
          placeholder="gam_sk_xxxxxxxx"
          oninput="this.classList.remove('error')">
      </div>
      <div class="privacy">
        <span style="flex-shrink:0">🔒</span>
        <span>Scan 100% local. Aucun code source n'est transmis à nos serveurs.</span>
      </div>
      <button class="btn btn-full" onclick="inject()" id="injectBtn">
        <span id="injectBtnContent">💉 Injecter le SDK</span>
      </button>
    </div>

    <div class="divider"></div>

    <div class="section-title">À propos</div>
    <div class="about">
      <div>gamif_scanner injecte</div>
      <div class="about-highlight">GamifTracker.track()</div>
      <div>dans les méthodes choisies</div>
      <br>
      <div>et initialise</div>
      <div class="about-highlight">GamifSDK.init()</div>
      <div>dans main.dart</div>
      <br>
      <div>Le code original reste</div>
      <div>100% intact.</div>
    </div>
  </div><!-- /.sidebar -->
</div><!-- /.layout -->

<script>
let methods = [];
const ballsLoader = '<div class="balls"><div></div><div></div><div></div></div>';

/* ── STEPPER ── */
function setStep(n) {
  [1,2,3].forEach(function(i) {
    var el = document.getElementById('step' + i);
    el.classList.remove('active', 'done');
    if (i < n) el.classList.add('done');
    else if (i === n) el.classList.add('active');
  });
}

/* ── BUILD PROJECT TREE from scanned method file paths ── */
function buildTree(methods) {
  // Collect unique files
  var byFile = {};
  methods.forEach(function(m) {
    if (!byFile[m.filePath]) byFile[m.filePath] = [];
    byFile[m.filePath].push(m.name);
  });

  // Build a nested object tree under "lib/"
  var tree = {};
  Object.keys(byFile).forEach(function(filePath) {
    var norm = filePath.replace(/\\/g, '/');
    var parts = norm.split('/');
    var idx = parts.indexOf('lib');
    if (idx < 0) return;
    var rel = parts.slice(idx);
    var node = tree;
    rel.forEach(function(part, i) {
      if (i === rel.length - 1) {
        node[part] = byFile[filePath]; // leaf = array of method names
      } else {
        if (!node[part] || Array.isArray(node[part])) node[part] = {};
        node = node[part];
      }
    });
  });

  // Static root entries (always present in gamif_scanner structure)
  var staticRoots = [
    { icon: '📁', cls: 't-folder', name: '.dart_tool', depth: 0 },
    { icon: '📁', cls: 't-folder', name: 'bin',        depth: 0 },
    { icon: '📁', cls: 't-folder', name: 'example',    depth: 0 },
  ];

  // Render dynamic lib/ subtree
  function renderNode(obj, depth) {
    var html = '';
    Object.keys(obj).forEach(function(key) {
      var val = obj[key];
      var indent = 'd' + depth;
      if (Array.isArray(val)) {
        // .dart file
        html += '<li class="' + indent + ' t-dart">'
              + '<span>📄</span>'
              + '<span class="t-name">' + key + '</span>'
              + '<span class="t-meta">' + val.length + ' fn</span>'
              + '</li>';
      } else {
        // folder
        html += '<li class="' + indent + ' t-folder">'
              + '<span>📁</span>'
              + '<span class="t-name">' + key + '</span>'
              + '</li>';
        html += renderNode(val, depth + 1);
      }
    });
    return html;
  }

  var html = '';
  // Static top-level entries
  staticRoots.forEach(function(r) {
    html += '<li class="d0 ' + r.cls + '"><span>' + r.icon + '</span><span class="t-name">' + r.name + '</span></li>';
  });
  // lib/ folder (dynamic)
  html += '<li class="d0 t-folder"><span>📁</span><span class="t-name">lib</span></li>';
  html += renderNode(tree['lib'] || tree, 1);
  // Static config files
  html += '<li class="d0 t-git"><span>📄</span><span class="t-name">.gitignore</span></li>';
  html += '<li class="d0 t-md"><span>📄</span><span class="t-name">CHANGELOG.md</span></li>';
  html += '<li class="d0 t-md"><span>📄</span><span class="t-name">README.md</span></li>';
  html += '<li class="d0 t-yaml"><span>📄</span><span class="t-name">pubspec.yaml</span></li>';
  html += '<li class="d0 t-lock"><span>📄</span><span class="t-name">pubspec.lock</span></li>';

  document.getElementById('projTree').innerHTML = html;
  document.getElementById('projWrap').style.display = 'inline-block';
}

/* ── SCAN ── */
async function scan() {
  var btn        = document.getElementById('scanBtn');
  var btnContent = document.getElementById('scanBtnContent');
  var area       = document.getElementById('scanArea');

  btn.disabled = true;
  btnContent.innerHTML = ballsLoader;
  area.classList.add('scanning');

  try {
    var res = await fetch('/api/scan');
    methods = await res.json();

    document.getElementById('totalCount').textContent = methods.length;
    renderList();
    buildTree(methods);

    document.getElementById('scanBlock').style.display  = 'none';
    document.getElementById('selBlock').style.display   = 'block';
    document.getElementById('injectBlock').style.display = 'block';
    setStep(2);
    updateSel();
  } catch(e) {
    btn.disabled = false;
    btnContent.innerHTML = '⬡ Lancer le scan';
    area.classList.remove('scanning');
    area.classList.add('error');
    setTimeout(function() { area.classList.remove('error'); }, 2000);
  }
}

/* ── RENDER METHOD LIST ── */
function renderList() {
  var byFile = {};
  methods.forEach(function(m) {
    if (!byFile[m.filePath]) byFile[m.filePath] = [];
    byFile[m.filePath].push(m);
  });

  var html = '';
  Object.entries(byFile).forEach(function(entry) {
    var file = entry[0];
    var list = entry[1];
    var parts = file.replace(/\\/g, '/').split('/');
    var idx   = parts.indexOf('lib');
    var rel   = idx >= 0 ? parts.slice(idx).join('/') : file;

    html += '<div class="file-group">';
    html += '<div class="file-header"><div class="file-dot"></div>' + rel + '</div>';
    list.forEach(function(m) {
      var ign  = m.isSuggestedToIgnore;
      var data = JSON.stringify(m).replace(/"/g, '&quot;');
      html += '<label class="method' + (ign ? ' ignored' : '') + '">'
            + '<input type="checkbox" class="method-check" '
            + (!ign ? 'checked' : '') + ' onchange="updateSel()" data-m="' + data + '">'
            + '<span class="method-name">' + m.displayName + '</span>'
            + '<span class="method-line">L' + m.lineNumber + '</span>'
            + (m.isAsync ? '<span class="badge badge-async">async</span>' : '')
            + (ign       ? '<span class="badge badge-skip">skip</span>'   : '')
            + '</label>';
    });
    html += '</div>';
  });
  document.getElementById('methodList').innerHTML = html;
}

/* ── SELECTION HELPERS ── */
function getSelected() {
  return Array.from(document.querySelectorAll('[data-m]:checked'))
    .map(function(c) { return JSON.parse(c.getAttribute('data-m').replace(/&quot;/g, '"')); });
}
function updateSel() {
  document.getElementById('selCount').textContent = getSelected().length;
}
function all()  { document.querySelectorAll('[data-m]').forEach(function(c){ c.checked = true;  }); updateSel(); }
function none() { document.querySelectorAll('[data-m]').forEach(function(c){ c.checked = false; }); updateSel(); }
function smart() {
  document.querySelectorAll('[data-m]').forEach(function(c) {
    var m = JSON.parse(c.getAttribute('data-m').replace(/&quot;/g, '"'));
    c.checked = !m.isSuggestedToIgnore;
  });
  updateSel();
}

/* ── INJECT ── */
async function inject() {
  var apiKeyInput = document.getElementById('apiKey');
  var apiKey      = apiKeyInput.value.trim();
  if (!apiKey) { apiKeyInput.classList.add('error'); apiKeyInput.focus(); return; }

  var selected = getSelected();
  if (!selected.length) { alert('Sélectionne au moins une méthode !'); return; }

  var btn        = document.getElementById('injectBtn');
  var btnContent = document.getElementById('injectBtnContent');
  btn.disabled   = true;
  btnContent.innerHTML = ballsLoader;
  setStep(3);

  try {
    var res = await fetch('/api/inject', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ apiKey: apiKey, methods: selected })
    });
    var r = await res.json();

    document.getElementById('selBlock').style.display    = 'none';
    document.getElementById('injectBlock').style.display = 'none';
    document.getElementById('resultBlock').style.display = 'block';
    document.getElementById('resultSub').textContent     = r.injectedCount + ' injection(s) réussie(s)';

    var initLine = '<div class="log-line"><span class="log-prefix">✓</span><span>GamifSDK.init() → main.dart</span></div>';
    var logLines = selected.map(function(m) {
      return '<div class="log-line"><span class="log-prefix">✓</span><span>GamifTracker.track(' + m.name + ')</span></div>';
    }).join('');
    var errLines = r.errors.map(function(e) {
      return '<div class="log-line log-err"><span class="log-prefix">✕</span><span>' + e + '</span></div>';
    }).join('');

    document.getElementById('logBox').innerHTML = initLine + logLines + errLines;

  } catch(e) {
    btn.disabled = false;
    btnContent.innerHTML = '💉 Injecter le SDK';
    setStep(2);
  }
}
</script>
</body>
</html>
''';