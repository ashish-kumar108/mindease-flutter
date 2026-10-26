import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Journal')),
      body: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book, size: 96, color: Colors.deepPurple),
          const SizedBox(height: 12),
          const Text('Your Journal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () {}, child: const Text('Add Entry')),
        ],
      )),
    );
  }
}
