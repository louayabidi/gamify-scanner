# gamif_scanner

[![Dart SDK Version](https://img.shields.io/badge/Dart-3.0%2B-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Pub Version](https://img.shields.io/pub/v/gamif_scanner)](https://pub.dev/packages/gamif_scanner)

**Auto-scanner and code injector for the Gamification Flutter SDK.**  
Automatically instruments your Flutter app with tracking calls – no manual work needed.

---

## 📖 Overview

`gamif_scanner` is a command-line tool that scans your Flutter project, detects all methods, and lets you choose which ones should send tracking events. It then **injects** the necessary SDK calls (`GamifSDK.init()` and `GamifTracker.track()`) directly into your source code, preserving your original logic.

> ⏱️ **Time saved**: Integrating 100 methods goes from 2 days of manual work to **30 seconds** with 3 clicks.

---

## ✨ Features

- ✅ **Automatic method detection** – uses Dart AST to list every method in your project.
- ✅ **Smart default exclusions** – ignores Flutter lifecycle methods (`build`, `initState`, …).
- ✅ **Two interfaces** – choose between a terminal CLI or a local Web UI.
- ✅ **Safe injection** – inserts code after the opening brace, never overwrites existing code.
- ✅ **Idempotent** – won't duplicate tracking calls if you run the tool again.
- ✅ **100% local** – your source code never leaves your machine.

---

## 📦 Installation

### Install globally (recommended)
```bash
dart pub global activate gamif_scanner
```

### Or add as a dev dependency

In your `pubspec.yaml`:
```yaml
dev_dependencies:
  gamif_scanner: ^1.0.4
```

Then run:
```bash
flutter pub get
```

---

## 🚀 Usage

### Basic command

From the root of your Flutter project:
```bash
dart pub global run gamif_scanner:setup .
```

If installed as a dev dependency:
```bash
dart run gamif_scanner
```

You can also specify a custom project path:
```bash
dart pub global run gamif_scanner /path/to/your/flutter/project
```

### What happens next?

1. The tool detects your project and asks you to choose an interface:
```
[1] 💻 CLI (interactive terminal)
[2] 🌐 Web UI (opens in your browser)
```

2. It scans all `.dart` files inside `lib/` (excluding generated files like `*.g.dart`).
3. You select the methods you want to track.
4. Enter your API key.
5. The tool injects the tracking code and saves a config file (`.gamif_config.json`).

---

## 🖥️ Interfaces

### CLI mode

- Navigate with `↑`/`↓` arrows
- Press `SPACE` to toggle selection
- Press `A` to select all, `N` to deselect all
- Press `ENTER` to confirm

### Web UI mode

A local server starts at `http://localhost:8080`. Three simple steps:

1. **Scan** – click to see all methods grouped by file
2. **Select** – use checkboxes to choose methods
3. **Configure & Inject** – enter your API key and inject

> 🔒 The server listens only on `127.0.0.1` – no external access possible.

---

## 🔍 How it works

- **AST analysis** – uses the `analyzer` package to parse your code without executing it.
- **Offset-based injection** – inserts code after the opening brace `{`. Processes methods from the bottom of each file to avoid shifting offsets.
- **Configuration file** – after injection, `.gamif_config.json` is created with your API key and the list of injected methods. Add this file to `.gitignore`!

---

## 📁 Example

**Before** (`lib/features/game/game_service.dart`):
```dart
class GameService {
  Future<void> completeLevel(int level) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _playerScore += level * 100;
  }
}
```

**After** (automatic injection):
```dart
import 'package:gamification_flutter_sdk/gamification_flutter_sdk.dart';

class GameService {
  Future<void> completeLevel(int level) async {
    // 🎮 Gamification SDK – auto-injected by gamif_scanner
    GamifTracker.track('completeLevel');
    await Future.delayed(const Duration(milliseconds: 300));
    _playerScore += level * 100;
  }
}
```

**And in `main.dart`:**
```dart
void main() async {   // ← made async automatically
  WidgetsFlutterBinding.ensureInitialized();
  // 🎮 Gamification SDK – auto-injected by gamif_scanner
  await GamifSDK.init(apiKey: 'your_api_key');
  runApp(const MyApp());
}
```

---

## ⚙️ Requirements

- Dart SDK ≥ 3.0.0
- Flutter SDK ≥ 3.10.0 (any Flutter project with a `lib/` folder)

---

## ❓ FAQ

**Q: Will it overwrite my existing code?**  
A: No. The tool only adds lines after the opening brace — it never deletes or modifies your original logic. That said, it's wise to commit your code before running it.

**Q: What if I run it twice?**  
A: The scanner checks for existing `GamifTracker.track()` calls and won't inject duplicates.

**Q: Does it work with generated files (`.g.dart`)?**  
A: No, those are automatically ignored.

**Q: Are methods inside mixins/extensions detected?**  
A: Yes, the AST visitor picks them up.

**Q: The browser doesn't open automatically.**  
A: Open `http://localhost:8080` manually. If the port is busy, change it in `web_ui_server.dart`.

**Q: How do I get the actual SDK (`gamification_flutter_sdk`)?**  
A: This package is just the scanner. The SDK itself is a separate package (coming soon). The scanner injects calls that will work once the SDK is added to your project.

---

## 🔒 Security & Privacy

- Your source code is **never transmitted** – all analysis and injection happen locally.
- The Web UI server listens only on `127.0.0.1`.
- The `.gamif_config.json` file contains your API key – add it to `.gitignore` to avoid accidental commits.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🚀 What's next?

After instrumenting your app with `gamif_scanner`, add the actual **Gamification Flutter SDK** to your `pubspec.yaml`. That SDK will send the tracked events to your backend. Stay tuned!
