/// Represents an immutable 9x9 Latin square.
///
/// A Latin square is a grid where each row and column contains
/// all numbers from 1-9 exactly once.
///
/// Example:
/// ```dart
/// final grid = List.generate(9, (i) => List.generate(9, (j) => ((j + i) % 9) + 1));
/// final square = LatinSquare(grid: grid, startingOrder: 1);
/// print(square.valueAt(0, 0)); // 1
/// ```
class LatinSquare {
  /// The 9x9 grid of values
  final List<List<int>> grid;

  /// The starting order used to generate this square (1-9)
  final int startingOrder;

  /// Creates a new LatinSquare with the given grid and startingOrder.
  ///
  /// [grid] must be a 9x9 matrix of integers.
  /// [startingOrder] must be between 1 and 9 inclusive.
  ///
  /// Throws [AssertionError] if preconditions are violated.
  LatinSquare({
    required this.grid,
    required this.startingOrder,
  })  : assert(grid.length == 9, 'Grid must have exactly 9 rows'),
        assert(
          grid.every((row) => row.length == 9),
          'Each row must have exactly 9 columns',
        ),
        assert(
          startingOrder >= 1 && startingOrder <= 9,
          'Starting order must be between 1 and 9',
        );

  /// Returns the value at the specified [row] and [column].
  ///
  /// [row] and [column] must be between 0 and 8 inclusive.
  ///
  /// Throws [RangeError] if row or column is out of bounds.
  int valueAt(int row, int column) {
    if (row < 0 || row >= 9) {
      throw RangeError('Row index $row is out of bounds (0-8)');
    }
    if (column < 0 || column >= 9) {
      throw RangeError('Column index $column is out of bounds (0-8)');
    }
    return grid[row][column];
  }

  /// Returns an immutable list of all values in the specified [row].
  ///
  /// [row] must be between 0 and 8 inclusive.
  ///
  /// Throws [RangeError] if row is out of bounds.
  List<int> getRow(int row) {
    if (row < 0 || row >= 9) {
      throw RangeError('Row index $row is out of bounds (0-8)');
    }
    return List.unmodifiable(grid[row]);
  }

  /// Returns an immutable list of all values in the specified [column].
  ///
  /// [column] must be between 0 and 8 inclusive.
  ///
  /// Throws [RangeError] if column is out of bounds.
  List<int> getColumn(int column) {
    if (column < 0 || column >= 9) {
      throw RangeError('Column index $column is out of bounds (0-8)');
    }
    return List.unmodifiable(grid.map((row) => row[column]).toList());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LatinSquare) return false;

    if (startingOrder != other.startingOrder) return false;
    if (grid.length != other.grid.length) return false;

    for (int i = 0; i < grid.length; i++) {
      if (grid[i].length != other.grid[i].length) return false;
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] != other.grid[i][j]) return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    int hash = startingOrder.hashCode;
    for (final row in grid) {
      for (final value in row) {
        hash = hash ^ value.hashCode;
      }
    }
    return hash;
  }
}
