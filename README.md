# SignalsWatch

A unified, production-ready reactive framework for `signals_flutter` with auto-registering signal factories, lifecycle callbacks, debouncing, throttling, async helpers, and comprehensive debug tools.

[![pub package](https://img.shields.io/pub/v/signals_watch.svg)](https://pub.dev/packages/signals_watch)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

### ✅ Unified API
- **Single class**: All functionality in `SignalsWatch` - signals, reactive widgets, registry, observer
- **Static factories**: `SignalsWatch.signal<T>()`, `SignalsWatch.computed<T>()` with auto-registration
- **Async helpers**: `SignalsWatch.fromFuture<T>()`, `SignalsWatch.fromStream<T>()` for reactive async values
- **Registry management**: Track and dispose signals globally with `register()`, `disposeAll()`, `size`
- **Selective observer**: `initializeSignalsObserver()` for debug logging of labeled signals only

### 🎯 Reactive Widget
- **Multiple modes**: Single signal, multiple signals, custom read function, selector pattern
- **Lifecycle callbacks**: `onInit`, `onValueUpdated`, `onAfterBuild`, `onDispose` at both signal and widget levels
- **Callback override precedence**: Widget callbacks override signal callbacks (NEW in 0.3.0)
- **Optional previous value**: Callbacks can accept both current and previous values
- **Effect replacement**: `onValueUpdated` (with optional previous value) replaces the need for creating a manual `effect(() { ... })` in `signals_flutter` when you just want to react to changes of the watched signals.
- **StatelessWidget friendly**: No need to write StatefulWidget boilerplate

### �️ Conditional Updates
- **`shouldRebuild`**: Control when the widget rebuilds
- **`shouldNotify`**: Control when callbacks fire
- **Custom equality**: Define how values are compared for complex objects

### ⏱️ Timing Control
- **Debouncing**: Wait for changes to settle (e.g., search input)
- **Throttling**: Limit update frequency (e.g., scroll events)

### 🛡️ Error Handling
- **`onError`**: Catch and handle read errors
- **`errorBuilder`**: Custom error UI (defaults to red text)
- **`loadingBuilder`**: Custom loading UI (defaults to CircularProgressIndicator)

### 🔍 Debug & Development
- **Selective observer**: Log only labeled signals with `initializeSignalsObserver()`
- **Auto-logging**: Built-in `debugPrint` for lifecycle events
- **Debug labels**: Name signals for easier tracking

### 🎨 Advanced Patterns
- **Selector pattern**: Only rebuild when selected part of value changes
- **Batch updates**: Efficiently combine multiple signals
- **Builder caching**: Prevents redundant rebuilds
- **Modular architecture**: Clean separation of concerns with library parts

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  signals_watch: ^0.3.1
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:signals_watch/signals_watch.dart';

// Create auto-registered signals
final counter = SignalsWatch.signal(0);
final doubled = SignalsWatch.computed(() => counter.value * 2);

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Option 1: Fluent syntax (new in 0.2.0)
    return counter.observe(
      (value) => Text('$value'),
      onValueUpdated: (value) => debugPrint('Counter: $value'),
    );
    
    // Option 2: Traditional syntax (still works)
    return SignalsWatch<int>.fromSignal(
      counter,
      onValueUpdated: (value) => debugPrint('Counter: $value'),
      builder: (value) => Text('$value'),
    );
  }
}
```

## Creating Signals

### Static Factories (Auto-Registered)

```dart
// Create a signal (auto-registered for cleanup)
final counter = SignalsWatch.signal(0);

// Signal with lifecycle callbacks (NEW in 0.3.0)
final user = SignalsWatch.signal(
  User.empty(),
  debugLabel: 'user',
  onInit: () => print('User signal initialized'),
  onValueUpdated: (value, previous) => print('User changed: $previous -> $value'),
  onAfterBuild: () => print('Frame rendered with user data'),
  onDispose: () => print('User signal disposed'),
);

// Create a computed signal (auto-registered)
final doubled = SignalsWatch.computed(() => counter.value * 2);

// Computed with callbacks (NEW in 0.3.0)
final fullName = SignalsWatch.computed(
  () => '${firstName.value} ${lastName.value}',
  debugLabel: 'fullName',
  onValueUpdated: (name) => print('Full name: $name'),
);

// Create from Future
final userData = SignalsWatch.fromFuture(
  fetchUser(),
  initialValue: null,
  debugLabel: 'user-data',
);

// fromFuture with callbacks (NEW in 0.3.0)
final profile = SignalsWatch.fromFuture(
  fetchProfile(),
  initialValue: null,
  onInit: () => print('Loading profile...'),
  onValueUpdated: (data) => print('Profile loaded: $data'),
  onDispose: () => print('Profile signal disposed'),
);

// Create from Stream
final messages = SignalsWatch.fromStream(
  messageStream,
  initialValue: [],
  cancelOnError: false,
);

// fromStream with callbacks (NEW in 0.3.0)
final chatMessages = SignalsWatch.fromStream(
  chatStream,
  initialValue: <Message>[],
  onInit: () => print('Listening to chat stream'),
  onValueUpdated: (messages) => print('New messages: ${messages.length}'),
  onDispose: () => print('Stopped listening to chat'),
);
```

### Signal Methods (NEW in 0.3.0)

```dart
// Reset signal to initial value
counter.reset();  // Returns to the value passed to SignalsWatch.signal(initialValue)

// Works with all signal types
user.reset();
computed.reset();  // Recomputes from dependencies
asyncSignal.reset();  // Returns to initialValue
```

### Registry Management

```dart
// Manually register a signal
final mySignal = signal(0);
SignalsWatch.register(mySignal);

// Check registry size
print('Tracked signals: ${SignalsWatch.size}');

// Dispose all tracked signals (e.g., on app logout)
SignalsWatch.disposeAll();
```

## Reactive Widget API

### Single Signal - Fluent Syntax (NEW in 0.2.0)
```dart
// Works with any signal type: signal, computed, fromFuture, fromStream
counter.observe(
  (value) => Text('$value'),
  onValueUpdated: (value) => print('Value: $value'),
  debounce: Duration(milliseconds: 300),
)
```

### Multiple Signals - Fluent Syntax (NEW in 0.2.0)
```dart
[firstName, lastName].observe(
  combine: (values) => '${values[0]} ${values[1]}',
  builder: (fullName) => Text(fullName),
)
```

### Selector Pattern - Fluent Syntax (NEW in 0.2.0)
```dart
user.selectObserve(
  (u) => (u as User).age,  // Only rebuild when age changes
  (age) => Text('Age: $age'),
)
```

### Traditional Constructors (Still Available)

#### `SignalsWatch.fromSignal` - Single Signal
```dart
SignalsWatch<int>.fromSignal(
  mySignal,
  onValueUpdated: (value) => print('Value: $value'),
  builder: (value) => Text('$value'),
)
```

#### `SignalsWatch.fromSignals` - Multiple Signals
```dart
SignalsWatch<int>.fromSignals(
  [signal1, signal2, signal3],
  combine: (values) => values[0] + values[1] + values[2],
  builder: (sum) => Text('Sum: $sum'),
)
```

#### `SignalsWatch.select` - Selector Pattern
```dart
SignalsWatch<String>.select(
  userSignal,
  selector: (user) => user.name,  // Only rebuild when name changes
  builder: (name) => Text(name),
)
```

#### `SignalsWatch` - Custom Read
```dart
SignalsWatch<int>(
  read: () => counter.value * 2 + anotherSignal.value,
  builder: (result) => Text('$result'),
)
```

## Common Use Cases

### Search with Debouncing
```dart
final searchQuery = SignalsWatch.signal('');

// Fluent syntax
searchQuery.observe(
  (query) => TextField(onChanged: (text) => searchQuery.value = text),
  debounce: Duration(milliseconds: 300),
  onValueUpdated: (query) => performSearch(query), // Called 300ms after user stops typing
)

// Or traditional syntax
SignalsWatch<String>.fromSignal(
  searchQuery,
  debounce: Duration(milliseconds: 300),
  onValueUpdated: (query) => performSearch(query),
  builder: (query) => TextField(
    onChanged: (text) => searchQuery.value = text,
  ),
)
```

### Conditional Updates
```dart
// Fluent syntax
counter.observe(
  (value) => Text('$value'),
  shouldNotify: (value, _) => value > 10,  // Only notify above threshold
  onValueUpdated: (value) => showAlert('Threshold exceeded: $value'),
)
```

### Combining Multiple Signals
```dart
// Fluent syntax
[firstName, lastName].observe(
  combine: (values) => '${values[0]} ${values[1]}',
  builder: (fullName) => Text(fullName),
  onValueUpdated: (fullName) => print('Full name: $fullName'),
)
```

### Efficient Selector Pattern
```dart
// Only rebuilds when age changes, ignores name changes
user.selectObserve(
  (u) => (u as User).age,
  (age) => Text('Age: $age'),
)
```

### Error Handling
```dart
SignalsWatch<int>(
  read: () {
    if (value < 0) throw Exception('Negative!');
    return value * 2;
  },
  onError: (error, stack) => logError(error, stack),
  errorBuilder: (error) => ErrorCard(error: error),
  builder: (value) => Text('$value'),
)
```

## API Reference

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `builder` | `Widget Function(T)` | **Required**. Builds UI with current value |
| `onInit` | `Function?` | Called once on initialization |
| `onValueUpdated` | `Function?` | Called when value changes |
| `onAfterBuild` | `Function?` | Called post-frame after every build |
| `onDispose` | `Function?` | Called when widget is disposed |
| `shouldRebuild` | `bool Function(T, T)?` | Control when to rebuild |
| `shouldNotify` | `bool Function(T, T)?` | Control when to fire callbacks |
| `equals` | `bool Function(T, T)?` | Custom equality check |
| `debounce` | `Duration?` | Wait duration after last change |
| `throttle` | `Duration?` | Minimum time between updates |
| `onError` | `void Function(Object, StackTrace)?` | Error callback |
| `errorBuilder` | `Widget Function(Object)?` | Custom error UI |
| `loadingBuilder` | `Widget Function()?` | Custom loading UI |
| `debugLabel` | `String?` | Label for logging |
| `debugPrint` | `bool` | Auto-log lifecycle events (default: false) |

### Callback Signatures

All lifecycle callbacks support both:
- `(T value)` - Just the current value
- `(T value, T? previous)` - Current and previous values

```dart
// Single parameter
onValueUpdated: (value) => print(value),

// With previous value
onValueUpdated: (value, previous) => print('$previous -> $value'),
```

### Lifecycle Callbacks (NEW in 0.3.0)

#### Signal-Level Callbacks
Define callbacks when creating signals - they apply to all widgets observing that signal:

```dart
final counter = SignalsWatch.signal(
  0,
  onInit: () => print('Counter initialized'),
  onValueUpdated: (value, previous) => logAnalytics('counter', value),
  onDispose: () => print('Counter disposed'),
);

// All widgets observing this signal inherit these callbacks
counter.observe((value) => Text('$value'));
```

#### Widget-Level Callbacks
Define callbacks on the widget - they override signal-level callbacks:

```dart
// Widget callback overrides signal callback for this widget only
counter.observe(
  (value) => Text('$value'),
  onValueUpdated: (value) => print('Widget-specific callback: $value'),
  // Signal's onValueUpdated is NOT called for this widget
);
```

#### Callback Precedence Rules
1. **Widget callbacks override signal callbacks** - When you provide a callback on the widget, the signal's callback is NOT called
2. **Separate lifecycle hooks** - Override is per-callback type (`onInit`, `onValueUpdated`, etc.)
3. **Other widgets unaffected** - Overriding in one widget doesn't affect other widgets

```dart
final user = SignalsWatch.signal(
  User(),
  onValueUpdated: (u) => print('Signal: User updated'),
  onDispose: () => print('Signal: User disposed'),
);

// Widget A: Uses signal callbacks
user.observe((u) => Text(u.name));  // Prints "Signal: User updated"

// Widget B: Overrides onValueUpdated, inherits onDispose
user.observe(
  (u) => Text(u.email),
  onValueUpdated: (u) => print('Widget B: User updated'),  // Overrides signal callback
  // Still inherits signal's onDispose
);

// Widget C: Overrides both callbacks
user.observe(
  (u) => Text(u.age.toString()),
  onValueUpdated: (u) => print('Widget C: User updated'),
  onDispose: () => print('Widget C: Disposed'),
);
```

#### Reset Method (NEW in 0.3.0)
All signals can be reset to their initial value:

```dart
final counter = SignalsWatch.signal(0);
counter.value = 10;
counter.reset();  // Returns to 0

// Works with computed signals (re-evaluates)
final doubled = SignalsWatch.computed(() => counter.value * 2);
doubled.reset();  // Re-evaluates computation

// Works with async signals (returns to initialValue)
final data = SignalsWatch.fromFuture(fetchData(), initialValue: null);
data.reset();  // Returns to null
```

## Debug Tools

### Selective Observer

Track specific signals by their debug labels without cluttering logs:

```dart
import 'package:signals_watch/signals_watch.dart';

void main() {
  // Enable selective signal tracking (only labeled signals)
  SignalsWatch.initializeSignalsObserver();
  
  // Only signals with labels will be logged
  final counter = SignalsWatch.signal(0, debugLabel: 'counter');
  final user = SignalsWatch.signal(User(), debugLabel: 'user.profile');
  
  // This won't be logged (no label)
  final internal = SignalsWatch.signal(false);
  
  runApp(MyApp());
}
```

**Output:**
```
SelectiveSignalsObserver.onSignalCreated | counter => 0
SelectiveSignalsObserver.onSignalUpdated | counter => 1 (previously: 0)
SelectiveSignalsObserver.onSignalCreated | user.profile => User(...)
SelectiveSignalsObserver.onSignalUpdated | user.profile => User(...) (previously: ...)
```

**Best Practices:**
- Use dot notation for namespacing: `'user.name'`, `'cart.total'`
- Only label signals you want to track
- Disable in production if needed:
  ```dart
  if (kDebugMode) {
    SelectiveSignalsObserver.initialize();
  }
  ```

## Migration Guide

### From signals_flutter

**Creating Signals (Before):**
```dart
import 'package:signals/signals_flutter.dart';

final counter = signal(0);
final doubled = computed(() => counter.value * 2);

// Manual cleanup needed
void cleanup() {
  counter.dispose();
  doubled.dispose();
}
```

**Creating Signals (After - Auto-registered):**
```dart
import 'package:signals_watch/signals_watch.dart';

final counter = SignalsWatch.signal(0);
final doubled = SignalsWatch.computed(() => counter.value * 2);

// Cleanup all tracked signals at once
void cleanup() {
  SignalsWatch.disposeAll();
}
```

### From StatefulWidget + effect()

**Before:**
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final EffectCleanup _cleanup;
  
  @override
  void initState() {
    super.initState();
    _cleanup = effect(() {
      debugPrint('Counter: ${counter.value}');
    });
  }
  
  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Watch((ctx) => Text('${counter.value}'));
  }
}
```

**After:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignalsWatch<int>.fromSignal(
      counter,
      onValueUpdated: (value) => debugPrint('Counter: $value'),
      builder: (value) => Text('$value'),
    );
  }
}
```

Here `onValueUpdated` fully replaces the earlier `effect(() { ... })` pattern for responding to signal changes. You also gain access to the previous value by using `(value, previous)` if desired, eliminating extra boilerplate and cleanup logic.

## Best Practices

1. **Use static factories for signal creation**
   - `SignalsWatch.signal()` for auto-registered signals
   - `SignalsWatch.computed()` for auto-registered computed values
   - `SignalsWatch.fromFuture()` / `fromStream()` for async data

2. **Use the right widget constructor**
   - `.fromSignal()` for single signals
   - `.fromSignals()` for combining multiple signals
   - `.select()` for efficient updates to parts of complex objects

3. **Debounce vs Throttle**
   - Debounce: Wait for user to finish (search, form input)
   - Throttle: Limit update frequency (scroll, resize)

4. **Performance**
   - Use `shouldRebuild` to prevent unnecessary rebuilds
   - Use `.select()` to watch only relevant parts of objects
   - Use custom `equals` for deep equality checks

5. **Error Handling**
   - Always provide `onError` and `errorBuilder` for operations that might fail

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please open an issue or PR on [GitHub](https://github.com/soundsliced/signals_watch).

## Publishing

For first publish run:

```bash
dart pub get
dart pub publish --dry-run
dart pub publish
```

Update the version in `pubspec.yaml` and add a new section in `CHANGELOG.md` for subsequent releases.
