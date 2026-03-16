# gamif_scanner

A Dart CLI tool that scans Flutter projects using AST analysis, detects
all Dart methods, and injects gamification tracking code automatically.

## Installation
```sh
dart pub global activate gamif_scanner
```

## Usage

Run from your Flutter project root:
```sh
dart pub global run gamif_scanner:setup .
```

Or target a specific project:
```sh
dart pub global run gamif_scanner:setup /path/to/flutter/project
```

## What it does

1. Scans all Dart files using AST analysis
2. Detects all methods automatically
3. You choose which methods to track (CLI or Web UI)
4. Injects `GamifTracker.track()` into selected methods
5. Sends registered events to your Gamify dashboard

## Requirements

- Dart SDK >= 3.0.0
- A Flutter project with a `lib/` folder
- A Gamify API key from your dashboard