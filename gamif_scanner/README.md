# gamif_scanner

Auto-scanner and code injector for the Gamification Flutter SDK.

## Installation
```sh
dart pub global activate gamif_scanner
```

## Usage

Run from your Flutter project root:
```sh
dart pub global run gamif_scanner
```

Or target a specific project:
```sh
dart pub global run gamif_scanner /path/to/flutter/project
```

## What it does

1. Scans all Dart files in your Flutter project
2. Detects all methods automatically
3. You choose which methods to track
4. Injects SDK tracking code automatically

## Requirements

- Dart SDK >= 3.0.0
- A Flutter project with a `lib/` folder