import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/latin_square.dart';
import 'models/latin_square_generator.dart';
import 'widgets/latin_square_grid.dart';
import 'utils/starting_order_input.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latin Squares',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: LatinSquareScreen(onThemeToggle: _toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
    );
  }
}

/// Screen displaying a Latin square
class LatinSquareScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const LatinSquareScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<LatinSquareScreen> createState() => _LatinSquareScreenState();
}

class _LatinSquareScreenState extends State<LatinSquareScreen> {
  late LatinSquare _currentSquare;
  final TextEditingController _orderController = TextEditingController();
  String? _errorText;
  bool _showColors = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

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
    _scrollController.dispose();
    _focusNode.dispose();
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
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Mode'),
                    Switch(
                      value: widget.isDarkMode,
                      onChanged: (bool value) {
                        widget.onThemeToggle(value);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              const scrollAmount = 50.0;
              if (event.logicalKey.keyLabel == 'Arrow Down') {
                _scrollController.jumpTo(
                  (_scrollController.offset + scrollAmount).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ),
                );
                return KeyEventResult.handled;
              } else if (event.logicalKey.keyLabel == 'Arrow Up') {
                _scrollController.jumpTo(
                  (_scrollController.offset - scrollAmount).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ),
                );
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
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
              Center(
                child: LatinSquareGrid(
                  square: _currentSquare,
                  showColors: _showColors,
                ),
              ),
              const SizedBox(height: 24),
              // Toggle button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showColors = !_showColors;
                  });
                },
                icon: Icon(_showColors ? Icons.numbers : Icons.palette),
                label: Text(_showColors ? 'Show Numbers' : 'Show Colors'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Instructions
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to Use',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A Latin square is a 9×9 grid where each number from 1 to 9 appears exactly once in each row and column. Enter a starting order (1-9) above to generate a different Latin square pattern.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the "Show Colors" button to visualize the pattern with colors instead of numbers. Each number is assigned a unique color, making it easy to verify that each color appears exactly once per row and column.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // History section
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Latin squares have a rich mathematical history dating back to the 18th century. They were first studied extensively by Swiss mathematician Leonhard Euler, who called them "Latin squares" because he used Latin letters as symbols.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Euler\'s work on these squares was motivated by a famous problem called the "36 officers problem." Today, Latin squares have important applications in experimental design, cryptography, error-correcting codes, and are the mathematical foundation behind Sudoku puzzles.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Applications section
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applications',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Latin squares have numerous practical applications across various fields. In agriculture, they are used for experimental design to test different fertilizers, crop varieties, or growing conditions while controlling for variations in soil quality and sunlight across a field.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Other applications include statistical experimental design, tournament scheduling, error-correcting codes in telecommunications, cryptography, and puzzle design. The popular Sudoku puzzle is based on a special type of Latin square with additional constraints.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '\u00a9 2025-${DateTime.now().year} Greg Christian \u00b7 MIT License',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        InkWell(
                          onTap: () async {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: 'gregpuzzles1@gmail.com',
                            );
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            }
                          },
                          child: Text(
                            'gregpuzzles1@gmail.com',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text('\u00b7', style: Theme.of(context).textTheme.bodySmall),
                        InkWell(
                          onTap: () async {
                            final Uri repoUri = Uri.parse('https://github.com/gregpuzzles1/latin_squares');
                            if (await canLaunchUrl(repoUri)) {
                              await launchUrl(repoUri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Text(
                            'Repository',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text('\u00b7', style: Theme.of(context).textTheme.bodySmall),
                        InkWell(
                          onTap: () async {
                            final Uri issueUri = Uri.parse('https://github.com/gregpuzzles1/latin_squares/issues/new');
                            if (await canLaunchUrl(issueUri)) {
                              await launchUrl(issueUri, mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Text(
                            'Open an Issue',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}
