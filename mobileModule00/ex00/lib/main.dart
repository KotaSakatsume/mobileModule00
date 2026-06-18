import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('A basic display'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => debugPrint('Button pressed'),
                child: const Text('Click me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
