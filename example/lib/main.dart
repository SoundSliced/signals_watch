import 'package:flutter/material.dart';
import 'package:signals_watch/signals_watch.dart';

void main() {
  // Enable selective signal tracking - only labeled signals will be logged
  SignalsWatch.initializeSignalsObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalsWatch Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: const ExamplesPage(),
    );
  }
}

// Global signals with debug labels for tracking
final counter = SignalsWatch.signal(0, debugLabel: 'counter');
final searchQuery = SignalsWatch.signal('', debugLabel: 'search.query');
final user =
    SignalsWatch.signal(User(name: 'John', age: 25), debugLabel: 'user');

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  String toString() => 'User(name: $name, age: $age)';
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WatchValue Signal Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Basic Counter',
            'Simple signal watching with callback',
            const BasicCounterExample(),
          ),
          _buildSection(
            'Debounced Search',
            'Search with 500ms debounce',
            const DebouncedSearchExample(),
          ),
          _buildSection(
            'Conditional Updates',
            'Only notifies when counter > 10',
            const ConditionalExample(),
          ),
          _buildSection(
            'Selector Pattern',
            'Only rebuilds when age changes',
            const SelectorExample(),
          ),
          _buildSection(
            'Multiple Signals',
            'Combines name and age',
            const MultipleSignalsExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            example,
          ],
        ),
      ),
    );
  }
}

// Example 1: Basic Counter
class BasicCounterExample extends StatelessWidget {
  const BasicCounterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalsWatch.fromSignal(
          counter,
          onValueUpdated: (value, previous) {
            debugPrint('Counter changed: $previous -> $value');
          },
          builder: (value) =>
              Text('Count: $value', style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('Increment'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => counter.value--,
              child: const Text('Decrement'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 2: Debounced Search
class DebouncedSearchExample extends StatelessWidget {
  const DebouncedSearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search',
            hintText: 'Type to search...',
            border: OutlineInputBorder(),
          ),
          onChanged: (text) => searchQuery.value = text,
        ),
        const SizedBox(height: 8),
        SignalsWatch.fromSignal(
          searchQuery,
          debounce: const Duration(milliseconds: 500),
          onValueUpdated: (query) {
            debugPrint('Searching for: $query');
          },
          builder: (query) => Text(
            query.isEmpty ? 'Start typing...' : 'Searching: "$query"',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// Example 3: Conditional Updates
class ConditionalExample extends StatelessWidget {
  const ConditionalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalsWatch.fromSignal(
          counter,
          shouldNotify: (value, _) => value > 10,
          onValueUpdated: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Threshold exceeded: $value')),
            );
          },
          builder: (value) => Column(
            children: [
              Text('Count: $value', style: const TextStyle(fontSize: 24)),
              Text(
                value > 10 ? '✓ Above threshold' : 'Below threshold (10)',
                style: TextStyle(
                  color: value > 10 ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Example 4: Selector Pattern
class SelectorExample extends StatelessWidget {
  const SelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalsWatch.select(
          user,
          selector: (u) => u.age,
          onValueUpdated: (age, previousAge) {
            debugPrint('Age changed: $previousAge -> $age');
          },
          builder: (age) =>
              Text('Age: $age', style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => user.value = User(
                name: user.value.name,
                age: user.value.age + 1,
              ),
              child: const Text('Birthday'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // This won't trigger rebuild (name change ignored)
                user.value = User(
                  name: '${user.value.name}!',
                  age: user.value.age,
                );
              },
              child: const Text('Change Name'),
            ),
          ],
        ),
      ],
    );
  }
}

// Example 5: Multiple Signals
class MultipleSignalsExample extends StatelessWidget {
  const MultipleSignalsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final firstName = SignalsWatch.signal('John');
    final lastName = SignalsWatch.signal('Doe');

    return Column(
      children: [
        SignalsWatch.fromSignals(
          [firstName, lastName],
          combine: (values) => '${values[0]} ${values[1]}',
          onValueUpdated: (fullName) {
            debugPrint('Full name: $fullName');
          },
          builder: (fullName) =>
              Text(fullName, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => firstName.value = 'Jane',
              child: const Text('Change First'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => lastName.value = 'Smith',
              child: const Text('Change Last'),
            ),
          ],
        ),
      ],
    );
  }
}
