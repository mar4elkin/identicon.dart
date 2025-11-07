# Identicon Generator
A lightweight Dart library for generating GitHub-style identicons from any string input.

<img width="250" height="250" alt="изображение" src="https://github.com/user-attachments/assets/c32c8cd9-2421-4236-b4c0-c5d8af20f9fb" />

## Features
- 🎨 Generate unique identicons from strings

- 🖼️ Multiple output formats: PNG file, Base64 string

- 🎯 Customizable size and grid complexity

## Installation
Add to your `pubspec.yaml`:
```yaml
dependencies:
  identicon: ^1.0.0
```

## Quick Start
```dart
import 'package:identicon/identicon.dart';

void main() {
  // Create identicon
  final identicon = Identicon(value: 'hello@world.com');
  
  // Save as file
  identicon.toFile(filename: 'my_identicon');
  
  // Get as base64 for web
  final base64String = identicon.toBase64();
  print('Base64: $base64String');
  
  // Get raw grid data
  final grid = identicon.raw();
  print('Grid: $grid');
}
```

## Customization
```dart
final identicon = Identicon(
  value: 'custom',
  size: 300,        // Image size in pixels
  cellsCount: 7,    // Grid complexity (3-7)
);
```
