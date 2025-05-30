import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Music', style: TextStyle(fontSize: 20)),
            Switch(value: true, onChanged: (value) {}),
            const SizedBox(height: 20),
            const Text('Sound Effects', style: TextStyle(fontSize: 20)),
            Switch(value: true, onChanged: (value) {}),
            const SizedBox(height: 20),
            const Text('Difficulty', style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: 'Normal',
              items: ['Easy', 'Normal', 'Hard']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
