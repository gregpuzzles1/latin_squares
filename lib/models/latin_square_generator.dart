import 'latin_square.dart';

/// Static utility class for generating Latin squares.
///
/// Uses the cyclic generation algorithm:
/// L[i][j] = ((j + i * startingOrder) % 9) + 1
///
/// This ensures every row and column contains exactly one instance
/// of each number from 1 to 9.
class LatinSquareGenerator {
  // Private constructor to prevent instantiation
  LatinSquareGenerator._();

  /// Generates a 9x9 Latin square using row rotation.
  ///
  /// The [startingOrder] parameter determines the starting value for the
  /// first row and must be between 1 and 9 inclusive.
  ///
  /// Algorithm: First row starts with [startingOrder] and continues sequentially
  /// wrapping around (e.g., if startingOrder=3: [3,4,5,6,7,8,9,1,2]).
  /// Each subsequent row is a left-rotation of the previous row by 1 position.
  ///
  /// Example:
  /// ```dart
  /// final square = LatinSquareGenerator.generate(startingOrder: 1);
  /// // Row 0: [1,2,3,4,5,6,7,8,9]
  /// // Row 1: [2,3,4,5,6,7,8,9,1]
  /// // ...
  /// ```
  ///
  /// Throws [AssertionError] if [startingOrder] is not between 1 and 9.
  static LatinSquare generate({required int startingOrder}) {
    assert(
      startingOrder >= 1 && startingOrder <= 9,
      'Starting order must be between 1 and 9, got $startingOrder',
    );

    // Generate first row starting with startingOrder
    final firstRow = List.generate(
      9,
      (i) => ((startingOrder - 1 + i) % 9) + 1,
    );

    // Generate all rows by rotating the first row
    final grid = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => firstRow[(col + row) % 9],
      ),
    );

    return LatinSquare(grid: grid, startingOrder: startingOrder);
  }
}
