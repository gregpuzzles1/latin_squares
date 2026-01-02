/// Result of parsing a starting order input string.
///
/// Contains the validation result, the parsed value (if valid),
/// and an error message (if invalid).
class StartingOrderInputResult {
  /// Whether the input is valid
  final bool isValid;

  /// The parsed value (1-9), or null if invalid
  final int? value;

  /// Error message, or null if valid
  final String? error;

  const StartingOrderInputResult({
    required this.isValid,
    this.value,
    this.error,
  });
}

/// Utility class for parsing and validating starting order input.
///
/// Starting order must be an integer between 1 and 9 inclusive.
class StartingOrderInput {
  // Private constructor to prevent instantiation
  StartingOrderInput._();

  /// Parses a string input and returns a validation result.
  ///
  /// Returns [StartingOrderInputResult] containing:
  /// - `isValid`: true if input is a valid integer 1-9
  /// - `value`: the parsed integer (1-9), or null if invalid
  /// - `error`: error message string, or null if valid
  ///
  /// Valid inputs:
  /// - Integers 1-9 (inclusive)
  /// - Leading/trailing whitespace is trimmed
  ///
  /// Invalid inputs:
  /// - Empty or null strings
  /// - Non-numeric strings
  /// - Decimal numbers
  /// - Numbers less than 1 or greater than 9
  ///
  /// Example:
  /// ```dart
  /// final result = StartingOrderInput.parse('5');
  /// if (result.isValid) {
  ///   print('Value: ${result.value}'); // Value: 5
  /// } else {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  static StartingOrderInputResult parse(String? input) {
    // Handle null or empty input
    if (input == null || input.trim().isEmpty) {
      return const StartingOrderInputResult(
        isValid: false,
        error: 'Please enter a number',
      );
    }

    final trimmed = input.trim();

    // Try to parse as integer
    final parsed = int.tryParse(trimmed);

    if (parsed == null) {
      // Check if it's a decimal number
      if (double.tryParse(trimmed) != null) {
        return const StartingOrderInputResult(
          isValid: false,
          error: 'Please enter a whole number',
        );
      }

      // Not a number at all
      return const StartingOrderInputResult(
        isValid: false,
        error: 'Please enter a valid number',
      );
    }

    // Check range (1-9)
    if (parsed < 1 || parsed > 9) {
      return const StartingOrderInputResult(
        isValid: false,
        error: 'Number must be between 1 and 9',
      );
    }

    // Valid!
    return StartingOrderInputResult(
      isValid: true,
      value: parsed,
    );
  }
}
