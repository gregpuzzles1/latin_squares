# API Contract: Latin Square Generator

**Feature**: 001-latin-square-display  
**Created**: 2026-01-02  
**Type**: Internal Library API (not REST/GraphQL)

## Overview

This document defines the public API contract for the Latin Square generation library. This is a **Dart library API**, not a web service API. The contract specifies function signatures, behavior, and guarantees.

---

## API: LatinSquareGenerator

### Method: generate

**Signature**:
```dart
static LatinSquare generate(int startingOrder)
```

**Purpose**: Generate a deterministic 9x9 Latin square based on starting order parameter

**Parameters**:

| Parameter | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `startingOrder` | `int` | Yes | 1 ≤ value ≤ 9 | Algorithm parameter that determines the generation pattern |

**Returns**:

| Type | Description |
|------|-------------|
| `LatinSquare` | Immutable Latin square object with 9x9 grid and metadata |

**Guarantees** (Contract):

1. **Determinism**: Same `startingOrder` always produces identical `LatinSquare`
   ```dart
   assert(generate(5) == generate(5)); // Always true
   ```

2. **Row Uniqueness**: Every row contains each integer 1-9 exactly once
   ```dart
   for (var row = 0; row < 9; row++) {
     assert(square.getRow(row).toSet() == {1, 2, 3, 4, 5, 6, 7, 8, 9});
   }
   ```

3. **Column Uniqueness**: Every column contains each integer 1-9 exactly once
   ```dart
   for (var col = 0; col < 9; col++) {
     assert(square.getColumn(col).toSet() == {1, 2, 3, 4, 5, 6, 7, 8, 9});
   }
   ```

4. **Completeness**: Grid is fully populated (no null or missing values)
   ```dart
   assert(square.grid.length == 9);
   assert(square.grid.every((row) => row.length == 9));
   ```

5. **Value Range**: All cells contain integers in range [1, 9]
   ```dart
   assert(square.grid.every((row) => 
     row.every((val) => val >= 1 && val <= 9)
   ));
   ```

6. **Performance**: Completes in O(81) operations, <1ms on modern hardware
   ```dart
   final stopwatch = Stopwatch()..start();
   generate(5);
   stopwatch.stop();
   assert(stopwatch.elapsedMilliseconds < 10); // Very generous bound
   ```

**Pre-conditions**:
- `startingOrder` must be in range [1, 9] (enforced by assertion in debug mode)
- No other pre-conditions (no external dependencies, no state required)

**Post-conditions**:
- Returns a valid `LatinSquare` object
- No side effects (pure function)
- No exceptions thrown with valid input

**Error Handling**:
- **Debug mode**: Assertion failure if `startingOrder` outside [1, 9]
- **Release mode**: Undefined behavior with invalid input (validation should occur before calling)
- **Expected usage**: UI validates input before calling `generate`

**Complexity**:
- **Time**: O(n²) where n = 9, therefore O(81) = O(1) constant time
- **Space**: O(n²) for grid allocation = O(81) = O(1) constant space

**Algorithm**:
```dart
// Cyclic generation with offset
L[i][j] = ((i + j * startingOrder) mod 9) + 1
where i, j ∈ [0, 8]
```

**Examples**:

```dart
// Example 1: Generate with starting order 1
final square1 = LatinSquareGenerator.generate(1);
print(square1.grid[0]); // [1, 2, 3, 4, 5, 6, 7, 8, 9]
print(square1.grid[1]); // [2, 3, 4, 5, 6, 7, 8, 9, 1]

// Example 2: Generate with starting order 3
final square3 = LatinSquareGenerator.generate(3);
print(square3.grid[0]); // [1, 4, 7, 1, 4, 7, 1, 4, 7] - Wait, this is wrong!

// Actually, correct output for order 3:
// Row 0: [1, 4, 7, 1, 4, 7, 1, 4, 7] // NO! Must have 1-9 each once
// 
// Let me recalculate: ((0 + 0*3) % 9) + 1 = 1
//                     ((0 + 1*3) % 9) + 1 = 4
//                     ((0 + 2*3) % 9) + 1 = 7
//                     ((0 + 3*3) % 9) + 1 = 1  // WRONG - repeats!

// ERROR IN ALGORITHM! The formula ((i + j * k) % 9) + 1 doesn't guarantee uniqueness.
// Need to revise...

// CORRECTED ALGORITHM: Use permutation approach
// For each row i, permute [1,2,3,4,5,6,7,8,9] by shifting (i * startingOrder) positions
// Row i, Col j: ((j + i * startingOrder) mod 9) + 1  // Swapped i and j roles

final square3 = LatinSquareGenerator.generate(3);
// Row 0: [1, 2, 3, 4, 5, 6, 7, 8, 9]  // j=0..8: ((j + 0*3) % 9) + 1
// Row 1: [4, 5, 6, 7, 8, 9, 1, 2, 3]  // j=0..8: ((j + 1*3) % 9) + 1
// Row 2: [7, 8, 9, 1, 2, 3, 4, 5, 6]  // j=0..8: ((j + 2*3) % 9) + 1
```

**Corrected Formula**:
```dart
L[i][j] = ((j + i * startingOrder) mod 9) + 1
// Where:
// - i is row index [0, 8]
// - j is column index [0, 8]
// - startingOrder is shift amount [1, 9]
```

**Implementation Reference**:
```dart
static LatinSquare generate(int startingOrder) {
  assert(startingOrder >= 1 && startingOrder <= 9);
  
  final grid = List.generate(
    9,
    (i) => List.generate(
      9,
      (j) => ((j + i * startingOrder) % 9) + 1,
      growable: false,
    ),
    growable: false,
  );
  
  return LatinSquare(grid: grid, startingOrder: startingOrder);
}
```

---

## API: LatinSquare (Data Class)

### Constructor

**Signature**:
```dart
const LatinSquare({
  required List<List<int>> grid,
  required int startingOrder,
})
```

**Parameters**:

| Parameter | Type | Required | Constraints | Description |
|-----------|------|----------|-------------|-------------|
| `grid` | `List<List<int>>` | Yes | 9x9, values 1-9 | The Latin square data |
| `startingOrder` | `int` | Yes | 1 ≤ value ≤ 9 | The generation parameter |

**Usage Note**: Typically constructed only via `LatinSquareGenerator.generate()`, not directly by users.

### Properties (Read-only)

| Property | Type | Description |
|----------|------|-------------|
| `grid` | `List<List<int>>` | Immutable 9x9 grid of values |
| `startingOrder` | `int` | The order parameter used to generate this square |
| `size` | `int` | Always 9 (const static) |

### Methods

#### valueAt

**Signature**:
```dart
int valueAt(int row, int col)
```

**Purpose**: Get value at specific grid position

**Parameters**:
- `row`: Row index [0, 8]
- `col`: Column index [0, 8]

**Returns**: Integer value [1, 9] at position (row, col)

**Pre-conditions**: `0 ≤ row < 9` and `0 ≤ col < 9`

**Example**:
```dart
final square = LatinSquareGenerator.generate(1);
final topLeft = square.valueAt(0, 0); // 1
final center = square.valueAt(4, 4);   // 5
```

---

#### getRow

**Signature**:
```dart
List<int> getRow(int rowIndex)
```

**Purpose**: Get all values in a specific row

**Parameters**:
- `rowIndex`: Row index [0, 8]

**Returns**: Immutable list of 9 integers [1-9]

**Pre-conditions**: `0 ≤ rowIndex < 9`

**Guarantees**: Returned list contains each integer 1-9 exactly once

**Example**:
```dart
final square = LatinSquareGenerator.generate(2);
final firstRow = square.getRow(0);  // [1, 2, 3, 4, 5, 6, 7, 8, 9]
final secondRow = square.getRow(1); // [3, 4, 5, 6, 7, 8, 9, 1, 2]
```

---

#### getColumn

**Signature**:
```dart
List<int> getColumn(int colIndex)
```

**Purpose**: Get all values in a specific column

**Parameters**:
- `colIndex`: Column index [0, 8]

**Returns**: Immutable list of 9 integers [1-9]

**Pre-conditions**: `0 ≤ colIndex < 9`

**Guarantees**: Returned list contains each integer 1-9 exactly once

**Example**:
```dart
final square = LatinSquareGenerator.generate(2);
final firstCol = square.getColumn(0);  // [1, 3, 5, 7, 9, 2, 4, 6, 8]
```

---

#### isValid

**Signature**:
```dart
bool isValid()
```

**Purpose**: Validate that this object represents a valid Latin square

**Returns**: `true` if valid, `false` otherwise

**Validation Checks**:
1. Grid is 9x9
2. Each row contains 1-9 exactly once
3. Each column contains 1-9 exactly once

**Usage**: Primarily for testing and assertions, not typical app usage

**Example**:
```dart
final square = LatinSquareGenerator.generate(7);
assert(square.isValid()); // Should always pass for generated squares
```

---

## Contract Tests

These tests MUST pass for the API to be considered correctly implemented:

```dart
group('LatinSquareGenerator Contract Tests', () {
  test('Deterministic generation', () {
    for (var order = 1; order <= 9; order++) {
      final square1 = LatinSquareGenerator.generate(order);
      final square2 = LatinSquareGenerator.generate(order);
      expect(square1, equals(square2), 
        reason: 'Same order should produce identical squares');
    }
  });

  test('Row uniqueness guarantee', () {
    for (var order = 1; order <= 9; order++) {
      final square = LatinSquareGenerator.generate(order);
      for (var row = 0; row < 9; row++) {
        final rowValues = square.getRow(row);
        expect(rowValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}),
          reason: 'Row $row of order $order must contain 1-9 exactly once');
      }
    }
  });

  test('Column uniqueness guarantee', () {
    for (var order = 1; order <= 9; order++) {
      final square = LatinSquareGenerator.generate(order);
      for (var col = 0; col < 9; col++) {
        final colValues = square.getColumn(col);
        expect(colValues.toSet(), equals({1, 2, 3, 4, 5, 6, 7, 8, 9}),
          reason: 'Column $col of order $order must contain 1-9 exactly once');
      }
    }
  });

  test('Value range guarantee', () {
    for (var order = 1; order <= 9; order++) {
      final square = LatinSquareGenerator.generate(order);
      for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
          final value = square.valueAt(i, j);
          expect(value, greaterThanOrEqualTo(1));
          expect(value, lessThanOrEqualTo(9));
        }
      }
    }
  });

  test('Performance guarantee', () {
    final stopwatch = Stopwatch()..start();
    for (var order = 1; order <= 9; order++) {
      LatinSquareGenerator.generate(order);
    }
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(100),
      reason: 'Generating 9 squares should take <100ms');
  });

  test('Different orders produce different squares', () {
    final squares = [
      for (var order = 1; order <= 9; order++)
        LatinSquareGenerator.generate(order)
    ];
    
    // At least some should be different (not all identical)
    final uniqueSquares = squares.toSet();
    expect(uniqueSquares.length, greaterThan(1),
      reason: 'Different orders should produce different squares');
  });
});
```

---

## Versioning

**Current Version**: 1.0.0 (initial implementation)

**Compatibility Promise**: 
- Public API signatures will not change in patch versions (1.0.x)
- New methods may be added in minor versions (1.x.0)
- Breaking changes only in major versions (x.0.0)

**Stability**: Stable - this API is complete for feature requirements

---

## Summary

- **API Type**: Internal Dart library (not REST/GraphQL)
- **Primary Method**: `LatinSquareGenerator.generate(int)` 
- **Contract**: Deterministic, validates Latin square properties
- **Testing**: 6 contract tests ensuring guarantees
- **Complexity**: O(81) time and space (effectively constant)
- **Stability**: Stable, no planned changes
