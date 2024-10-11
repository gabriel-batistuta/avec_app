import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Terminal Command Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Terminal Command Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _output = ''; // To store the current line being displayed
  List<String> _outputLines = []; // To store the entire output
  int _currentLineIndex = 0; // To track the current line being displayed
  Timer? _timer; // Timer to update the UI progressively

  // Function to execute a shell command and update the UI with the result
  Future<void> _runCommand(String command) async {
    var shell = Shell();
    try {
      var result = await shell.run(command);
      _outputLines = result.outText.split('\n'); // Split output by lines
      _startDisplayingOutput();
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  // Function to display the output line by line, progressively
  void _startDisplayingOutput() {
    _currentLineIndex = 0;
    _output = '';
    
    _timer?.cancel(); // Cancel any existing timer

    // Start a new timer that updates the displayed line every 500ms
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentLineIndex < _outputLines.length) {
        setState(() {
          _output = _outputLines[_currentLineIndex]; // Update the output with the current line
        });
        _currentLineIndex++;
      } else {
        timer.cancel(); // Stop the timer when all lines have been displayed
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose of the timer when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _runCommand('echo Hello World'),
              child: const Text('Run echo Hello World'),
            ),
            ElevatedButton(
              onPressed: () => _runCommand('ls'),
              child: const Text('Run ls'),
            ),
            ElevatedButton(
              onPressed: () => _runCommand('pwd'),
              child: const Text('Run pwd'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Command output:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _output,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, backgroundColor: Colors.black, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
