# Data Model: Latin Square Display App

**Feature**: 001-latin-square-display  
**Created**: 2026-01-02  
**Source**: Derived from [spec.md](spec.md) Key Entities section

## Overview

This document defines the data structures for the Latin square display app. All models are immutable value objects with clear validation rules and relationships.

---

## Entity 1: LatinSquare

**Purpose**: Represents a completed 9x9 Latin square with its configuration

**Properties**:

| Property | Type | Constraints | Description |
|----------|------|-------------|-------------|
| `grid` | `List<List<int>>` | 9x9, values 1-9, immutable | The Latin square data as a 2D list |
| `startingOrder` | `int` | 1-9 inclusive | The starting order parameter used to generate this square |
| `size` | `int` | Always 9 (const) | Dimension of the square (rows and columns) |

**Invariants**:
1. Every row contains each number 1-9 exactly once
2. Every column contains each number 1-9 exactly once
3. Grid dimensions are exactly 9x9
4. Starting order is in range [1, 9]

**Validation Rules**:
```dart
bool isValid() {
  // Check dimensions
  if (grid.length != 9) return false;
  if (grid.any((row) => row.length != 9)) return false;
  
  // Check each row has 1-9 exactly once
  for (var row in grid) {
    if (!_containsExactlyOneToNine(row)) return false;
  }
  
  // Check each column has 1-9 exactly once
  for (var col = 0; col < 9; col++) {
    final column = [for (var row in grid) row[col]];
    if (!_containsExactlyOneToNine(column)) return false;
  }
  
  return true;
}

bool _containsExactlyOneToNine(List<int> values) {
  if (values.length != 9) return false;
  final sorted = [...values]..sort();
  return sorted.toString() == '[1, 2, 3, 4, 5, 6, 7, 8, 9]';
}
```

**Dart Implementation**:
```dart
@immutable
class LatinSquare {
  final List<List<int>> grid;
  final int startingOrder;
  static const int size = 9;
  
  const LatinSquare({
    required this.grid,
    required this.startingOrder,
  }) : assert(startingOrder >= 1 && startingOrder <= 9);
  
  /// Get value at specific position
  int valueAt(int row, int col) {
    assert(row >= 0 && row < size);
    assert(col >= 0 && col < size);
    return grid[row][col];
  }
  
  /// Get entire row
  List<int> getRow(int rowIndex) {
    assert(rowIndex >= 0 && rowIndex < size);
    return List.unmodifiable(grid[rowIndex]);
  }
  
  /// Get entire column
  List<int> getColumn(int colIndex) {
    assert(colIndex >= 0 && colIndex < size);
    return List.unmodifiable([
      for (var row in grid) row[colIndex]
    ]);
  }
  
  /// Validate Latin square properties
  bool isValid() {
    // Implementation as shown above
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is LatinSquare &&
    runtimeType == other.runtimeType &&
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

**Relationships**:
- Created by `LatinSquareGenerator.generate(int startingOrder)`
- Consumed by `LatinSquareGrid` widget for display
- No persistence (in-memory only)

---

## Entity 2: LatinSquareGenerator (Static Utility)

**Purpose**: Generates valid Latin squares using cyclic algorithm

**Public API**:

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `generate` | `int startingOrder` (1-9) | `LatinSquare` | Generates a valid 9x9 Latin square |

**Algorithm**:
```
For position (i, j) where i, j ∈ [0, 8]:
  value = ((i + j * startingOrder) mod 9) + 1
```

**Dart Implementation**:
```dart
class LatinSquareGenerator {
  /// Generate a 9x9 Latin square with given starting order
  /// 
  /// The starting order parameter determines the generation pattern.
  /// Same starting order always produces the same Latin square (deterministic).
  /// 
  /// Complexity: O(n²) time, O(n²) space where n = 9
  /// 
  /// [startingOrder] must be in range [1, 9]
  /// 
  /// Example:
  /// ```dart
  /// final square = LatinSquareGenerator.generate(3);
  /// print(square.grid[0]); // First row
  /// ```
  static LatinSquare generate(int startingOrder) {
    assert(startingOrder >= 1 && startingOrder <= 9,
      'Starting order must be between 1 and 9');
    
    final grid = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => ((i + j * startingOrder) % 9) + 1,
        growable: false,
      ),
      growable: false,
    );
    
    final square = LatinSquare(
      grid: grid,
      startingOrder: startingOrder,
    );
    
    assert(square.isValid(), 
      'Generated square failed validation');
    
    return square;
  }
}
```

**Properties**:
- Pure function (no side effects)
- Deterministic (same input → same output)
- Fast: O(81) operations for 9x9 grid
- Cannot fail with valid input

---

## Entity 3: StartingOrderInput (Value Object)

**Purpose**: Represents and validates user input for starting order

**Properties**:

| Property | Type | Constraints | Description |
|----------|------|-------------|-------------|
| `value` | `int?` | 1-9 or null | The parsed integer value, or null if invalid |
| `rawInput` | `String` | Any string | The raw user input before parsing |
| `isValid` | `bool` | Computed | Whether the input is valid (1-9) |
| `errorMessage` | `String?` | Computed | Error message if invalid, null if valid |

**Validation Rules**:
1. Must be non-empty
2. Must parse as an integer
3. Integer must be in range [1, 9]

**Dart Implementation**:
```dart
@immutable
class StartingOrderInput {
  final String rawInput;
  
  const StartingOrderInput(this.rawInput);
  
  int? get value {
    final parsed = int.tryParse(rawInput.trim());
    if (parsed == null) return null;
    if (parsed < 1 || parsed > 9) return null;
    return parsed;
  }
  
  bool get isValid => value != null;
  
  String? get errorMessage {
    if (rawInput.trim().isEmpty) {
      return 'Please enter a number';
    }
    
    final parsed = int.tryParse(rawInput.trim());
    if (parsed == null) {
      return 'Must be a valid number';
    }
    
    if (parsed < 1 || parsed > 9) {
      return 'Must be between 1 and 9';
    }
    
    return null; // Valid
  }
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StartingOrderInput &&
    runtimeType == other.runtimeType &&
    rawInput == other.rawInput;
  
  @override
  int get hashCode => rawInput.hashCode;
}
```

**Usage in UI**:
```dart
// In widget state
StartingOrderInput _input = const StartingOrderInput('1');

// In TextFormField
TextFormField(
  initialValue: _input.rawInput,
  decoration: InputDecoration(
    labelText: 'Starting Order (1-9)',
    errorText: _input.errorMessage,
  ),
  onChanged: (text) {
    setState(() {
      _input = StartingOrderInput(text);
    });
  },
)

// When generating
if (_input.isValid) {
  final square = LatinSquareGenerator.generate(_input.value!);
  // Update display
}
```

---

## State Transitions

```
[App Launch]
    ↓
[Initial State: startingOrder = 1]
    ↓
[Generate default square with order 1]
    ↓
[Display square] ←─────────────┐
    ↓                           │
[User enters new order]         │
    ↓                           │
[Validate input] ──→ Invalid?   │
    ↓                  ↓        │
  Valid          [Show error]   │
    ↓                           │
[Generate new square]           │
    ↓                           │
[Update display] ───────────────┘
```

**State Invariants**:
1. Display always shows a valid Latin square (never partial/invalid)
2. Starting order in memory always matches displayed square
3. UI is never blocked (generation is fast enough for synchronous execution)

---

## Data Flow

```
User Input (String)
    ↓
StartingOrderInput.rawInput
    ↓
StartingOrderInput.value (int?) [validation]
    ↓
LatinSquareGenerator.generate(int)
    ↓
LatinSquare (immutable)
    ↓
LatinSquareGrid widget (display)
    ↓
GridView.builder (Flutter rendering)
    ↓
Screen (visible to user)
```

**Key Points**:
- One-way data flow (no circular dependencies)
- Validation happens before generation
- All transformations are pure functions
- UI updates via `setState` with new `LatinSquare` instance

---

## Memory Considerations

**Per Latin Square**:
- Grid: 9 rows × 9 cols × 4 bytes (int32) = 324 bytes
- Metadata: ~100 bytes (object overhead, startingOrder)
- **Total: ~450 bytes per LatinSquare instance**

**App State**:
- Current square: ~450 bytes
- Input state: ~100 bytes
- Widget tree: ~50KB (Flutter framework)
- **Total runtime: <1MB**

**No persistence**: All data is in-memory only, discarded on app close (per user requirement).

---

## Testing Contract

All data models must pass these contract tests:

### LatinSquare Contract Tests
```dart
test('Generated Latin square has valid rows', () {
  for (var order = 1; order <= 9; order++) {
    final square = LatinSquareGenerator.generate(order);
    for (var row = 0; row < 9; row++) {
      final rowValues = square.getRow(row);
      expect(rowValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}));
    }
  }
});

test('Generated Latin square has valid columns', () {
  for (var order = 1; order <= 9; order++) {
    final square = LatinSquareGenerator.generate(order);
    for (var col = 0; col < 9; col++) {
      final colValues = square.getColumn(col);
      expect(colValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}));
    }
  }
});

test('Same starting order produces identical squares', () {
  final square1 = LatinSquareGenerator.generate(5);
  final square2 = LatinSquareGenerator.generate(5);
  expect(square1, equals(square2));
});

test('Different starting orders produce different squares', () {
  final square1 = LatinSquareGenerator.generate(1);
  final square2 = LatinSquareGenerator.generate(2);
  expect(square1, isNot(equals(square2)));
});
```

### StartingOrderInput Contract Tests
```dart
test('Valid inputs parse correctly', () {
  for (var i = 1; i <= 9; i++) {
    final input = StartingOrderInput(i.toString());
    expect(input.isValid, isTrue);
    expect(input.value, equals(i));
    expect(input.errorMessage, isNull);
  }
});

test('Invalid inputs are rejected', () {
  final invalidInputs = ['', '0', '10', 'abc', '-1', '5.5'];
  for (var raw in invalidInputs) {
    final input = StartingOrderInput(raw);
    expect(input.isValid, isFalse);
    expect(input.value, isNull);
    expect(input.errorMessage, isNotNull);
  }
});
```

---

## Summary

**Entities**: 3 (LatinSquare, LatinSquareGenerator, StartingOrderInput)  
**Relationships**: Simple one-way flow (Input → Generator → Square → Display)  
**Validation**: At input layer (before generation) and assertion-based (after generation)  
**Persistence**: None (all in-memory)  
**Complexity**: Minimal - appropriate for single-screen app scope
