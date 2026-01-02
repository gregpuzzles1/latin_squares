import 'package:flutter_test/flutter_test.dart';
import 'package:latin_squares/utils/starting_order_input.dart';

void main() {
  group('StartingOrderInput Tests', () {
    // T049: Test parsing valid inputs (1-9)
    test('should parse valid inputs 1-9', () {
      for (int i = 1; i <= 9; i++) {
        final result = StartingOrderInput.parse('$i');
        expect(result.isValid, isTrue);
        expect(result.value, equals(i));
        expect(result.error, isNull);
      }
    });

    test('should handle leading/trailing whitespace', () {
      final result = StartingOrderInput.parse('  5  ');
      expect(result.isValid, isTrue);
      expect(result.value, equals(5));
    });

    // T050: Test rejecting invalid inputs
    test('should reject 0', () {
      final result = StartingOrderInput.parse('0');
      expect(result.isValid, isFalse);
      expect(result.value, isNull);
      expect(result.error, isNotNull);
    });

    test('should reject 10 and above', () {
      final result10 = StartingOrderInput.parse('10');
      expect(result10.isValid, isFalse);
      expect(result10.value, isNull);

      final result99 = StartingOrderInput.parse('99');
      expect(result99.isValid, isFalse);
      expect(result99.value, isNull);
    });

    test('should reject negative numbers', () {
      final result = StartingOrderInput.parse('-1');
      expect(result.isValid, isFalse);
      expect(result.value, isNull);
    });

    test('should reject non-numeric input', () {
      final resultText = StartingOrderInput.parse('abc');
      expect(resultText.isValid, isFalse);
      expect(resultText.value, isNull);

      final resultEmpty = StartingOrderInput.parse('');
      expect(resultEmpty.isValid, isFalse);
      expect(resultEmpty.value, isNull);

      final resultSpecial = StartingOrderInput.parse('!@#');
      expect(resultSpecial.isValid, isFalse);
      expect(resultSpecial.value, isNull);
    });

    test('should reject decimal numbers', () {
      final result = StartingOrderInput.parse('5.5');
      expect(result.isValid, isFalse);
      expect(result.value, isNull);
    });

    // T051: Test error messages
    test('should provide error message for empty input', () {
      final result = StartingOrderInput.parse('');
      expect(result.error, equals('Please enter a number'));
    });

    test('should provide error message for non-numeric input', () {
      final result = StartingOrderInput.parse('abc');
      expect(result.error, equals('Please enter a valid number'));
    });

    test('should provide error message for out of range input', () {
      final result0 = StartingOrderInput.parse('0');
      expect(result0.error, equals('Number must be between 1 and 9'));

      final result10 = StartingOrderInput.parse('10');
      expect(result10.error, equals('Number must be between 1 and 9'));
    });

    test('should provide error message for decimal input', () {
      final result = StartingOrderInput.parse('5.5');
      expect(result.error, equals('Please enter a whole number'));
    });

    // Edge cases
    test('should handle null input gracefully', () {
      final result = StartingOrderInput.parse(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Please enter a number'));
    });
  });
}
