import 'package:flutter/material.dart';
import 'models/latin_square.dart';
import 'models/latin_square_generator.dart';
import 'widgets/latin_square_grid.dart';
import 'utils/starting_order_input.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latin Squares',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LatinSquareScreen(),
    );
  }
}

/// Screen displaying a Latin square
class LatinSquareScreen extends StatefulWidget {
  const LatinSquareScreen({super.key});

  @override
  State<LatinSquareScreen> createState() => _LatinSquareScreenState();
}

class _LatinSquareScreenState extends State<LatinSquareScreen> {
  late LatinSquare _currentSquare;
  final TextEditingController _orderController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Generate default square with starting order 1
    _currentSquare = LatinSquareGenerator.generate(startingOrder: 1);
    _orderController.text = '1';
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  void _handleOrderChange(String value) {
    final result = StartingOrderInput.parse(value);

    setState(() {
      if (result.isValid && result.value != null) {
        _errorText = null;
        _currentSquare =
            LatinSquareGenerator.generate(startingOrder: result.value!);
      } else {
        _errorText = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Latin Square Display'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input section
            Row(
              children: [
                const Text(
                  'Starting Order: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _orderController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: '1-9',
                      errorText: _errorText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: _handleOrderChange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Grid display
            Expanded(
              child: Center(
                child: LatinSquareGrid(square: _currentSquare),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
