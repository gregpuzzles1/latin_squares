import 'package:flutter/material.dart';
import '../models/latin_square.dart';

/// A stateless widget that displays a Latin square in a grid format.
///
/// The grid displays all 81 cells (9x9) with borders and centered numbers or colors.
/// The widget is responsive and adapts to different screen sizes.
class LatinSquareGrid extends StatelessWidget {
  /// The Latin square to display
  final LatinSquare square;
  
  /// Whether to display colors instead of numbers
  final bool showColors;

  /// Creates a LatinSquareGrid widget.
  ///
  /// The [square] parameter must not be null and should be a valid 9x9 Latin square.
  /// The [showColors] parameter determines whether to show colors (true) or numbers (false).
  const LatinSquareGrid({
    super.key,
    required this.square,
    this.showColors = false,
  });
  
  /// Map each number (1-9) to a distinct color
  static const Map<int, Color> _colorMap = {
    1: Color(0xFFE53935), // Red
    2: Color(0xFF1E88E5), // Blue
    3: Color(0xFF43A047), // Green
    4: Color(0xFFFB8C00), // Orange
    5: Color(0xFF8E24AA), // Purple
    6: Color(0xFFFFEB3B), // Yellow
    7: Color(0xFF00ACC1), // Cyan
    8: Color(0xFFD81B60), // Pink
    9: Color(0xFF6D4C41), // Brown
  };

  @override
  Widget build(BuildContext context) {
    // T040: Use LayoutBuilder for responsive sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size based on available space
        // Constrain to maximum 400px to keep cells smaller
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final availableSize =
            availableWidth < availableHeight ? availableWidth : availableHeight;
        final constrainedSize = availableSize > 400 ? 400.0 : availableSize;
        final cellSize = (constrainedSize - 40) / 9; // 40 for padding

        // T041: Implement GridView.builder with 9x9 layout (81 items)
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: constrainedSize,
              height: constrainedSize,
              child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final value = square.valueAt(row, col);
                final cellColor = _colorMap[value] ?? Colors.grey;

                // T042: Add cell borders using Container with BoxDecoration
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    color: showColors ? cellColor : Colors.white,
                  ),
                  child: Center(
                    // T043: Style cell text (centered, bold, responsive font size)
                    child: showColors
                        ? const SizedBox.shrink()
                        : Text(
                            '$value',
                            style: TextStyle(
                              fontSize: cellSize * 0.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                  ),
                );
              },
            ),
            ),
          ),
        );
      },
    );
  }
}
