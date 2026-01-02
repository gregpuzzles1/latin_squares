# Quickstart Guide: Latin Square Display App

**Feature**: 001-latin-square-display  
**Created**: 2026-01-02  
**Audience**: Developers implementing this feature

## Overview

This guide provides step-by-step instructions for developing the Latin Square Display App using test-driven development (TDD) and the project's constitution principles.

---

## Prerequisites

**Required**:
- Flutter SDK 3.x or later ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.x (included with Flutter)
- iOS Simulator (Mac) or Android Emulator, or physical device
- IDE: VS Code with Flutter extension OR Android Studio

**Verify Installation**:
```bash
flutter doctor
# Should show checkmarks for Flutter, Dart, and at least one platform
```

---

## Project Setup

### 1. Initialize Flutter Project

```bash
# From repository root
flutter create --org com.latinsquares --platforms ios,android .

# This will create the standard Flutter structure
# Note: May warn about existing files - that's expected
```

### 2. Configure Project

Edit `pubspec.yaml`:
```yaml
name: latin_squares
description: A Flutter app that generates and displays 9x9 Latin squares
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

### 3. Enable Null Safety

Create/edit `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    missing_required_param: error
    missing_return: error

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - avoid_print
    - always_declare_return_types
    - require_trailing_commas
```

### 4. Verify Setup

```bash
flutter pub get
flutter analyze  # Should show no issues
```

---

## TDD Workflow (Constitution Principle II)

Follow this cycle for EVERY feature:

1. **RED**: Write failing test
2. **Verify**: Confirm test fails
3. **GREEN**: Write minimal code to pass
4. **Verify**: Confirm test passes
5. **REFACTOR**: Improve code quality
6. **Verify**: Confirm test still passes

---

## Phase 1: Core Algorithm (User Story 1 - P1)

### Step 1.1: Create Data Model Test (RED)

Create `test/models/latin_square_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square.dart';

void main() {
  group('LatinSquare', () {
    test('creates valid 9x9 grid', () {
      final grid = List.generate(9, (i) => 
        List.generate(9, (j) => j + 1));
      
      final square = LatinSquare(
        grid: grid,
        startingOrder: 1,
      );
      
      expect(square.grid.length, 9);
      expect(square.grid[0].length, 9);
      expect(square.startingOrder, 1);
    });
    
    test('valueAt returns correct value', () {
      final grid = List.generate(9, (i) => 
        List.generate(9, (j) => (i + j) % 9 + 1));
      
      final square = LatinSquare(grid: grid, startingOrder: 1);
      
      expect(square.valueAt(0, 0), 1);
      expect(square.valueAt(0, 1), 2);
    });
  });
}
```

**Run test (should FAIL)**:
```bash
flutter test test/models/latin_square_test.dart
# Error: Cannot find 'lib/models/latin_square.dart'
```

### Step 1.2: Implement Data Model (GREEN)

Create `lib/models/latin_square.dart`:
```dart
import 'package:flutter/foundation.dart';

@immutable
class LatinSquare {
  final List<List<int>> grid;
  final int startingOrder;
  static const int size = 9;
  
  const LatinSquare({
    required this.grid,
    required this.startingOrder,
  }) : assert(startingOrder >= 1 && startingOrder <= 9);
  
  int valueAt(int row, int col) {
    assert(row >= 0 && row < size);
    assert(col >= 0 && col < size);
    return grid[row][col];
  }
  
  List<int> getRow(int rowIndex) {
    assert(rowIndex >= 0 && rowIndex < size);
    return List.unmodifiable(grid[rowIndex]);
  }
  
  List<int> getColumn(int colIndex) {
    assert(colIndex >= 0 && colIndex < size);
    return List.unmodifiable([
      for (var row in grid) row[colIndex]
    ]);
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LatinSquare &&
    startingOrder == other.startingOrder &&
    _deepListEquals(grid, other.grid);
  
  @override
  int get hashCode => Object.hash(startingOrder, Object.hashAll(grid));
}

bool _deepListEquals(List<List<int>> a, List<List<int>> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].length != b[i].length) return false;
    for (var j = 0; j < a[i].length; j++) {
      if (a[i][j] != b[i][j]) return false;
    }
  }
  return true;
}
```

**Run test (should PASS)**:
```bash
flutter test test/models/latin_square_test.dart
# All tests should pass
```

### Step 1.3: Create Generator Contract Test (RED)

Create `test/models/latin_square_generator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square_generator.dart';

void main() {
  group('LatinSquareGenerator', () {
    group('Contract Tests', () {
      test('generates deterministic squares', () {
        final square1 = LatinSquareGenerator.generate(5);
        final square2 = LatinSquareGenerator.generate(5);
        expect(square1, equals(square2));
      });
      
      test('all rows contain 1-9 exactly once', () {
        for (var order = 1; order <= 9; order++) {
          final square = LatinSquareGenerator.generate(order);
          for (var row = 0; row < 9; row++) {
            final rowValues = square.getRow(row);
            expect(rowValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}),
              reason: 'Row $row of order $order failed');
          }
        }
      });
      
      test('all columns contain 1-9 exactly once', () {
        for (var order = 1; order <= 9; order++) {
          final square = LatinSquareGenerator.generate(order);
          for (var col = 0; col < 9; col++) {
            final colValues = square.getColumn(col);
            expect(colValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}),
              reason: 'Column $col of order $order failed');
          }
        }
      });
    });
  });
}
```

**Run test (should FAIL)**:
```bash
flutter test test/models/latin_square_generator_test.dart
# Error: Cannot find 'lib/models/latin_square_generator.dart'
```

### Step 1.4: Implement Generator (GREEN)

Create `lib/models/latin_square_generator.dart`:
```dart
import 'latin_square.dart';

class LatinSquareGenerator {
  /// Generate a deterministic 9x9 Latin square
  /// 
  /// Uses cyclic permutation: L[i][j] = ((j + i * startingOrder) % 9) + 1
  /// 
  /// Complexity: O(81) time, O(81) space
  static LatinSquare generate(int startingOrder) {
    assert(startingOrder >= 1 && startingOrder <= 9,
      'Starting order must be between 1 and 9');
    
    final grid = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => ((j + i * startingOrder) % 9) + 1,
        growable: false,
      ),
      growable: false,
    );
    
    return LatinSquare(
      grid: grid,
      startingOrder: startingOrder,
    );
  }
}
```

**Run test (should PASS)**:
```bash
flutter test test/models/latin_square_generator_test.dart
# All tests should pass, including contract tests
```

---

## Phase 2: UI Components (User Story 3 - P3)

### Step 2.1: Create Grid Widget Test (RED)

Create `test/widgets/latin_square_grid_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square_generator.dart';
import 'package:latin_squares/widgets/latin_square_grid.dart';

void main() {
  group('LatinSquareGrid Widget', () {
    testWidgets('displays 81 cells', (tester) async {
      final square = LatinSquareGenerator.generate(1);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LatinSquareGrid(square: square),
        ),
      ));
      
      expect(find.byType(GridView), findsOneWidget);
    });
    
    testWidgets('displays correct numbers', (tester) async {
      final square = LatinSquareGenerator.generate(1);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: LatinSquareGrid(square: square),
        ),
      ));
      
      // First cell should be 1
      expect(find.text('1'), findsWidgets);
    });
  });
}
```

**Run test (should FAIL)**:
```bash
flutter test test/widgets/latin_square_grid_test.dart
```

### Step 2.2: Implement Grid Widget (GREEN)

Create `lib/widgets/latin_square_grid.dart`:
```dart
import 'package:flutter/material.dart';
import '../models/latin_square.dart';

class LatinSquareGrid extends StatelessWidget {
  final LatinSquare square;
  
  const LatinSquareGrid({
    super.key,
    required this.square,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final cellSize = size / 9 - 2; // 2px for padding
        
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1.0,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final value = square.valueAt(row, col);
                
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: cellSize * 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
```

**Run test (should PASS)**:
```bash
flutter test test/widgets/latin_square_grid_test.dart
```

---

## Phase 3: Integration (User Story 2 - P2)

### Step 3.1: Create Main App

Create `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'models/latin_square.dart';
import 'models/latin_square_generator.dart';
import 'widgets/latin_square_grid.dart';

void main() {
  runApp(const LatinSquareApp());
}

class LatinSquareApp extends StatelessWidget {
  const LatinSquareApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latin Square Display',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LatinSquareScreen(),
    );
  }
}

class LatinSquareScreen extends StatefulWidget {
  const LatinSquareScreen({super.key});
  
  @override
  State<LatinSquareScreen> createState() => _LatinSquareScreenState();
}

class _LatinSquareScreenState extends State<LatinSquareScreen> {
  late LatinSquare _currentSquare;
  final _controller = TextEditingController(text: '1');
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    _currentSquare = LatinSquareGenerator.generate(1);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _regenerateSquare() {
    final input = _controller.text.trim();
    final order = int.tryParse(input);
    
    if (order == null) {
      setState(() => _errorText = 'Must be a number');
      return;
    }
    
    if (order < 1 || order > 9) {
      setState(() => _errorText = 'Must be between 1 and 9');
      return;
    }
    
    setState(() {
      _errorText = null;
      _currentSquare = LatinSquareGenerator.generate(order);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latin Square Display'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Starting Order (1-9)',
                      errorText: _errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _regenerateSquare,
                  child: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LatinSquareGrid(square: _currentSquare),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 3.2: Run the App

```bash
# On iOS Simulator
flutter run -d ios

# On Android Emulator
flutter run -d android

# On Web (for quick testing)
flutter run -d chrome
```

---

## Testing Commands

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/latin_square_generator_test.dart

# Run integration tests (requires emulator/device)
flutter test integration_test/app_test.dart

# Analyze code
flutter analyze
```

---

## Verification Checklist

After implementing, verify:

- [ ] All unit tests pass (`flutter test`)
- [ ] All contract tests pass (rows/columns validation)
- [ ] App launches and displays default Latin square
- [ ] Input validation works (rejects 0, 10, non-numbers)
- [ ] Changing order regenerates square
- [ ] Same order produces same square
- [ ] Grid is responsive (test portrait and landscape)
- [ ] No lint errors (`flutter analyze`)

---

## Next Steps

1. Run `/speckit.tasks` to generate detailed task breakdown
2. Follow tasks in order (TDD workflow for each)
3. Commit frequently with descriptive messages
4. Review against constitution before merging

---

## Troubleshooting

**Issue**: Tests fail with "MissingPluginException"
- **Solution**: Make sure to run `flutter pub get`

**Issue**: UI doesn't update when changing order
- **Solution**: Verify `setState` is called in `_regenerateSquare`

**Issue**: Grid doesn't fit on small screens
- **Solution**: Check `LayoutBuilder` logic, ensure `cellSize` calculation

**Issue**: Assertion failure in generator
- **Solution**: Verify starting order is 1-9 before calling `generate`

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Material Design 3](https://m3.material.io/)
- Project Constitution: [.specify/memory/constitution.md](../../.specify/memory/constitution.md)
