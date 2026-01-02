import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/models/latin_square_generator.dart';

void main() {
  group('LatinSquareGenerator Contract Tests', () {
    // T016: Contract test for deterministic generation
    test('CONTRACT: should generate identical squares for same startingOrder', () {
      final square1 = LatinSquareGenerator.generate(startingOrder: 5);
      final square2 = LatinSquareGenerator.generate(startingOrder: 5);

      expect(square1, equals(square2));
      
      // Verify all cells match
      for (int row = 0; row < 9; row++) {
        for (int col = 0; col < 9; col++) {
          expect(
            square1.valueAt(row, col),
            equals(square2.valueAt(row, col)),
            reason: 'Cell ($row, $col) should match',
          );
        }
      }
    });

    test('CONTRACT: should generate different squares for different orders', () {
      final square1 = LatinSquareGenerator.generate(startingOrder: 1);
      final square9 = LatinSquareGenerator.generate(startingOrder: 9);

      expect(square1, isNot(equals(square9)));
    });

    // T017: Contract test for row uniqueness
    test('CONTRACT: should have all numbers 1-9 exactly once per row', () {
      for (int order = 1; order <= 9; order++) {
        final square = LatinSquareGenerator.generate(startingOrder: order);

        for (int row = 0; row < 9; row++) {
          final rowValues = square.getRow(row);
          final uniqueValues = rowValues.toSet();

          expect(
            uniqueValues.length,
            equals(9),
            reason: 'Row $row for order $order should have 9 unique values',
          );

          for (int value = 1; value <= 9; value++) {
            expect(
              rowValues.contains(value),
              isTrue,
              reason: 'Row $row for order $order should contain $value',
            );
          }
        }
      }
    });

    // T018: Contract test for column uniqueness
    test('CONTRACT: should have all numbers 1-9 exactly once per column', () {
      for (int order = 1; order <= 9; order++) {
        final square = LatinSquareGenerator.generate(startingOrder: order);

        for (int col = 0; col < 9; col++) {
          final colValues = square.getColumn(col);
          final uniqueValues = colValues.toSet();

          expect(
            uniqueValues.length,
            equals(9),
            reason: 'Column $col for order $order should have 9 unique values',
          );

          for (int value = 1; value <= 9; value++) {
            expect(
              colValues.contains(value),
              isTrue,
              reason: 'Column $col for order $order should contain $value',
            );
          }
        }
      }
    });

    // T019: Contract test for value range
    test('CONTRACT: should only contain values in range 1-9', () {
      for (int order = 1; order <= 9; order++) {
        final square = LatinSquareGenerator.generate(startingOrder: order);

        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            final value = square.valueAt(row, col);
            expect(
              value,
              greaterThanOrEqualTo(1),
              reason: 'Cell ($row, $col) for order $order should be >= 1',
            );
            expect(
              value,
              lessThanOrEqualTo(9),
              reason: 'Cell ($row, $col) for order $order should be <= 9',
            );
          }
        }
      }
    });

    // Additional contract test: Completeness (all 81 cells populated)
    test('CONTRACT: should populate all 81 cells', () {
      for (int order = 1; order <= 9; order++) {
        final square = LatinSquareGenerator.generate(startingOrder: order);

        expect(square.grid.length, equals(9), reason: 'Should have 9 rows');
        for (int row = 0; row < 9; row++) {
          expect(
            square.grid[row].length,
            equals(9),
            reason: 'Row $row should have 9 columns',
          );
        }
      }
    });

    // Additional contract test: Row rotation algorithm verification
    test('CONTRACT: should follow row rotation algorithm', () {
      for (int order = 1; order <= 9; order++) {
        final square = LatinSquareGenerator.generate(startingOrder: order);

        // First row should start with startingOrder and increment mod 9
        for (int col = 0; col < 9; col++) {
          final expected = ((order - 1 + col) % 9) + 1;
          final actual = square.valueAt(0, col);
          expect(
            actual,
            equals(expected),
            reason:
                'First row, column $col for order $order should be ((order-1+col)%9)+1',
          );
        }

        // Each row should be a left-rotation of the previous row
        for (int row = 1; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            final expected = square.valueAt(row - 1, (col + 1) % 9);
            final actual = square.valueAt(row, col);
            expect(
              actual,
              equals(expected),
              reason:
                  'Row $row, col $col should equal previous row col ${(col + 1) % 9}',
            );
          }
        }
      }
    });

    // Edge case: Invalid starting order
    test('should throw assertion error for invalid startingOrder', () {
      expect(
        () => LatinSquareGenerator.generate(startingOrder: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => LatinSquareGenerator.generate(startingOrder: 10),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => LatinSquareGenerator.generate(startingOrder: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
