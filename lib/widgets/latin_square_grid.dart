import 'package:flutter/material.dart';
import '../models/latin_square.dart';

/// A stateless widget that displays a Latin square in a grid format.
///
/// The grid displays all 81 cells (9x9) with borders and centered numbers.
/// The widget is responsive and adapts to different screen sizes.
class LatinSquareGrid extends StatelessWidget {
  /// The Latin square to display
  final LatinSquare square;

  /// Creates a LatinSquareGrid widget.
  ///
  /// The [square] parameter must not be null and should be a valid 9x9 Latin square.
  const LatinSquareGrid({
    super.key,
    required this.square,
  });

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

                // T042: Add cell borders using Container with BoxDecoration
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    color: Colors.white,
                  ),
                  child: Center(
                    // T043: Style cell text (centered, bold, responsive font size)
                    child: Text(
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
