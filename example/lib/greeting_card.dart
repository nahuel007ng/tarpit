import 'package:flutter/material.dart';

/// Shows a spinner, then `Hello, <name>` once [loadName] completes.
class GreetingCard extends StatelessWidget {
  /// Creates the card.
  const GreetingCard({super.key, required this.loadName});

  /// Where the name comes from: a file, an API, a fake in tests.
  final Future<String> Function() loadName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: loadName(),
      builder: (context, snapshot) {
        final name = snapshot.data;
        if (name == null) return const CircularProgressIndicator();
        return Text('Hello, $name');
      },
    );
  }
}
