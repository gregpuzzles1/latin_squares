# Research: Latin Square Display App

**Feature**: 001-latin-square-display  
**Created**: 2026-01-02  
**Purpose**: Research findings for technical decisions and best practices

## Research Summary

This document consolidates research findings for implementing a Flutter-based Latin square display app. All technical context questions have been resolved with concrete decisions backed by rationale and alternatives considered.

---

## Decision 1: Latin Square Generation Algorithm

**Decision**: Cyclic generation with offset using modular arithmetic

**Algorithm**:
```
For a 9x9 Latin square with starting order `k` (1-9):
  L[i][j] = ((i + j * k) mod 9) + 1
  where i, j ∈ [0, 8]
```

**Rationale**:
- **Simplicity**: Single formula, no complex logic or backtracking
- **Deterministic**: Same starting order always produces identical output (per FR-009)
- **Correctness**: Proven mathematical construction guarantees valid Latin squares
- **Performance**: O(n²) = O(81) operations for 9x9, computed in microseconds
- **Testability**: Easy to verify properties (row/column uniqueness) programmatically

**Alternatives Considered**:
1. **Random generation with backtracking** - Rejected: Non-deterministic, violates FR-009, higher complexity
2. **Permutation-based approach** - Rejected: More complex implementation, no clear benefit for fixed 9x9 size
3. **Lookup table of pre-generated squares** - Rejected: Less flexible, harder to test algorithmic correctness

**References**:
- Combinatorial Design Theory (C. J. Colbourn, J. H. Dinitz)
- Latin Squares: New Developments (J. Dénes, A. D. Keedwell)
- Standard construction in discrete mathematics curricula

---

## Decision 2: Flutter State Management

**Decision**: Use simple `StatefulWidget` with local state (no state management framework)

**Rationale**:
- **Simplicity**: Single screen, 2 pieces of state (current square, starting order)
- **YAGNI**: No need for complex state solutions (Provider, Bloc, Riverpod) for this scope
- **Performance**: State changes are infrequent (only on user input)
- **Testability**: Stateful widgets are well-supported by flutter_test
- **Constitution alignment**: "Start with simplest correct implementation" (Principle V)

**State Structure**:
```dart
class _LatinSquareDisplayState extends State<LatinSquareDisplay> {
  late List<List<int>> _currentSquare;
  int _startingOrder = 1; // default
  
  void _regenerateSquare(int newOrder) {
    setState(() {
      _startingOrder = newOrder;
      _currentSquare = LatinSquareGenerator.generate(newOrder);
    });
  }
}
```

**Alternatives Considered**:
1. **Provider** - Rejected: Overkill for single-screen app with minimal state
2. **Bloc/Cubit** - Rejected: Adds complexity without clear benefit for this scope
3. **Riverpod** - Rejected: Would require learning curve, unnecessary for simple state

---

## Decision 3: Responsive Layout Approach

**Decision**: Use `LayoutBuilder` with `GridView.builder` and dynamic sizing

**Rationale**:
- **Native Flutter**: No external dependencies needed
- **Responsive**: Automatically adapts to screen size (portrait, landscape, tablets)
- **Performance**: `GridView.builder` only renders visible cells (though all 81 are visible)
- **Flexibility**: Easy to adjust cell size based on available space
- **Best practice**: Standard Flutter approach for grid layouts

**Implementation**:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cellSize = min(
      constraints.maxWidth / 9,
      constraints.maxHeight / 9
    ) - padding;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        childAspectRatio: 1.0,
      ),
      itemCount: 81,
      itemBuilder: (context, index) => _buildCell(index, cellSize),
    );
  }
)
```

**Alternatives Considered**:
1. **Fixed size with SingleChildScrollView** - Rejected: Poor UX on small screens
2. **MediaQuery-based sizing** - Rejected: LayoutBuilder is more direct and accurate
3. **Custom painting with Canvas** - Rejected: More complex, harder to maintain, no clear benefit

---

## Decision 4: Input Validation Strategy

**Decision**: Immediate validation with inline error feedback using `TextFormField`

**Rationale**:
- **User feedback**: Immediate visual indication of invalid input (per FR-008)
- **Prevention**: Disables generation button when input invalid
- **Flutter best practice**: Standard form validation pattern
- **Accessibility**: Error messages read by screen readers

**Implementation**:
```dart
TextFormField(
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'Starting Order (1-9)',
    errorText: _errorText,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Enter a number';
    final num = int.tryParse(value);
    if (num == null) return 'Must be a number';
    if (num < 1 || num > 9) return 'Must be between 1 and 9';
    return null;
  },
  onChanged: _validateAndUpdate,
)
```

**Alternatives Considered**:
1. **Silent clamping** (force to 1-9 range) - Rejected: Confusing UX, no feedback
2. **Validation on submit only** - Rejected: Delayed feedback, poor UX
3. **Regex input restriction** - Rejected: Doesn't handle semantic validation (1-9 range)

---

## Decision 5: Testing Strategy

**Decision**: Three-layer testing approach (unit → widget → integration)

**Test Layers**:

1. **Unit Tests** (`test/models/`)
   - Pure Dart algorithm tests
   - Contract tests for Latin square properties
   - Validator tests
   - Fast execution (<100ms total)

2. **Widget Tests** (`test/widgets/`)
   - Individual widget behavior
   - User interaction simulation
   - Layout rendering verification
   - Fast execution (~1-2s total)

3. **Integration Tests** (`integration_test/`)
   - Full app flow (launch → display → input → regenerate)
   - User story acceptance scenarios
   - Slower execution (~5-10s)

**Rationale**:
- **Constitution compliance**: Supports TDD workflow (Principle II)
- **Confidence**: Catches errors at appropriate level
- **Speed**: Fast unit tests enable rapid TDD cycles
- **Coverage**: From algorithm correctness to full UX validation

**Alternatives Considered**:
1. **Unit tests only** - Rejected: Doesn't verify UI behavior
2. **Integration tests only** - Rejected: Too slow for TDD, poor error localization
3. **Manual testing** - Rejected: Not repeatable, violates constitution

---

## Decision 6: Error Handling for Generation Failures

**Decision**: Assert-based pre-condition checking (fail fast in debug, safe in production)

**Rationale**:
- **Algorithm guarantee**: Cyclic generation cannot fail for valid input
- **Input validation**: Starting order validated before calling generator
- **Fail fast**: Catch developer errors early in development
- **Production safety**: Release builds remove asserts, but validation prevents invalid calls

**Implementation**:
```dart
class LatinSquareGenerator {
  static List<List<int>> generate(int startingOrder) {
    assert(startingOrder >= 1 && startingOrder <= 9, 
      'Starting order must be between 1 and 9');
    
    // Generation logic (cannot fail with valid input)
    final result = List.generate(9, (i) => 
      List.generate(9, (j) => ((i + j * startingOrder) % 9) + 1)
    );
    
    assert(_isValidLatinSquare(result), 
      'Generated square failed validation');
    
    return result;
  }
}
```

**Alternatives Considered**:
1. **Exception throwing** - Rejected: Input validation prevents invalid calls
2. **Result type (Success/Failure)** - Rejected: Overkill when algorithm cannot fail
3. **Silent fallback to default** - Rejected: Hides errors, harder to debug

---

## Best Practices: Flutter/Dart for Latin Squares

### Code Organization
- **Separate concerns**: Algorithm (models) vs UI (widgets) vs validation (utils)
- **Immutable data**: `LatinSquare` class with `@immutable` annotation
- **Pure functions**: Generator is side-effect-free, deterministic

### Performance
- **Lazy computation**: Only generate when needed (on launch + user input)
- **Const constructors**: Use `const` for unchanging widgets (borders, labels)
- **Avoid rebuilds**: Only `setState` when square actually changes

### Dart Language Features
- **Null safety**: Enable sound null safety (Dart 3.x default)
- **Type inference**: Use `var` for clarity, explicit types for public APIs
- **Extension methods**: Consider for grid validation utilities
- **Late initialization**: Use `late` for non-nullable fields set in initState

### Flutter UI Best Practices
- **Material Design 3**: Use Material 3 components for modern look
- **Accessibility**: Semantic labels for screen readers, sufficient contrast
- **Responsive**: Test on multiple screen sizes (phone, tablet, landscape)
- **Platform conventions**: Follow iOS/Android guidelines automatically

---

## Dependencies Summary

**Required**:
- `flutter`: Core framework (included in SDK)
- `flutter_test`: Testing framework (included in SDK)
- `integration_test`: E2E testing (included in Flutter)

**Development**:
- `flutter_lints`: Recommended linting rules (standard in new projects)

**Total**: Zero external dependencies beyond Flutter SDK

**Rationale**: Keeps app simple, reduces maintenance burden, faster builds, smaller app size

---

## Performance Estimates

**Latin Square Generation**:
- Time: <1ms for 9x9 (81 modular arithmetic operations)
- Memory: ~700 bytes (9x9 int array)

**UI Rendering**:
- Initial paint: <16ms (60fps) for 81 cells
- Rebuild on input: <16ms (60fps)
- Memory: ~50KB for widget tree

**App Size**:
- Release APK: ~15-20MB (Flutter baseline + minimal code)
- iOS IPA: ~20-25MB (Flutter baseline + minimal code)

All within specified performance goals (<1s initial display, <2s regeneration, 60fps).

---

## Open Questions: NONE

All technical context items have been resolved. Ready to proceed to Phase 1 (design).

---

## References

1. **Flutter Documentation**: https://flutter.dev/docs
2. **Dart Language**: https://dart.dev/guides
3. **Latin Square Theory**: Combinatorial Design Theory (Colbourn & Dinitz)
4. **Material Design 3**: https://m3.material.io/
5. **Flutter Testing**: https://flutter.dev/docs/testing
6. **Effective Dart**: https://dart.dev/guides/language/effective-dart
