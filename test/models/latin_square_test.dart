import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square.dart';

void main() {
  group('LatinSquare Model', () {
    // T011: Test LatinSquare model creation
    test('should create LatinSquare with valid grid and startingOrder', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => i + j + 1));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(square.grid, equals(grid));
      expect(square.startingOrder, equals(1));
    });

    test('should throw error for null grid', () {
      expect(
        () => LatinSquare(grid: null as dynamic, startingOrder: 1),
        throwsA(anything), // Type error or assertion error, both acceptable
      );
    });

    test('should throw assertion error for non-9x9 grid', () {
      final invalidGrid = List.generate(8, (i) => List.generate(8, (j) => 1));
      expect(
        () => LatinSquare(grid: invalidGrid, startingOrder: 1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw assertion error for invalid startingOrder', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => 1));
      expect(
        () => LatinSquare(grid: grid, startingOrder: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => LatinSquare(grid: grid, startingOrder: 10),
        throwsA(isA<AssertionError>()),
      );
    });

    // T012: Test LatinSquare.valueAt() method
    test('should return correct value at given row and column', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => (i * 9) + j));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(square.valueAt(0, 0), equals(0));
      expect(square.valueAt(4, 5), equals(41));
      expect(square.valueAt(8, 8), equals(80));
    });

    test('should throw RangeError for out-of-bounds row', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => 1));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(() => square.valueAt(-1, 0), throwsA(isA<RangeError>()));
      expect(() => square.valueAt(9, 0), throwsA(isA<RangeError>()));
    });

    test('should throw RangeError for out-of-bounds column', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => 1));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(() => square.valueAt(0, -1), throwsA(isA<RangeError>()));
      expect(() => square.valueAt(0, 9), throwsA(isA<RangeError>()));
    });

    // T013: Test LatinSquare.getRow() method
    test('should return correct immutable row', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => (i * 9) + j));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      final row4 = square.getRow(4);
      expect(row4, equals([36, 37, 38, 39, 40, 41, 42, 43, 44]));
      
      // Verify immutability by attempting to modify
      expect(() => row4.add(999), throwsUnsupportedError);
    });

    test('should throw RangeError for out-of-bounds row in getRow', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => 1));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(() => square.getRow(-1), throwsA(isA<RangeError>()));
      expect(() => square.getRow(9), throwsA(isA<RangeError>()));
    });

    // T014: Test LatinSquare.getColumn() method
    test('should return correct immutable column', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => (i * 9) + j));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      final col5 = square.getColumn(5);
      expect(col5, equals([5, 14, 23, 32, 41, 50, 59, 68, 77]));
      
      // Verify immutability by attempting to modify
      expect(() => col5.add(999), throwsUnsupportedError);
    });

    test('should throw RangeError for out-of-bounds column in getColumn', () {
      final grid = List.generate(9, (i) => List.generate(9, (j) => 1));
      final square = LatinSquare(grid: grid, startingOrder: 1);

      expect(() => square.getColumn(-1), throwsA(isA<RangeError>()));
      expect(() => square.getColumn(9), throwsA(isA<RangeError>()));
    });

    // Test equality operator and hashCode (for T025)
    test('should correctly compare two LatinSquare instances', () {
      final grid1 = List.generate(9, (i) => List.generate(9, (j) => i + j));
      final grid2 = List.generate(9, (i) => List.generate(9, (j) => i + j));
      final grid3 = List.generate(9, (i) => List.generate(9, (j) => i + j + 1));

      final square1 = LatinSquare(grid: grid1, startingOrder: 1);
      final square2 = LatinSquare(grid: grid2, startingOrder: 1);
      final square3 = LatinSquare(grid: grid3, startingOrder: 1);
      final square4 = LatinSquare(grid: grid1, startingOrder: 2);

      expect(square1, equals(square2));
      expect(square1.hashCode, equals(square2.hashCode));
      expect(square1, isNot(equals(square3)));
      expect(square1, isNot(equals(square4)));
    });
  });
}
