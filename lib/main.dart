import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Importando shared_preferences

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
  String _output = ''; // Para armazenar a saída do comando
  List<String> _outputLines = []; // Para armazenar a saída completa
  int _currentLineIndex = 0; // Para controlar a linha atual sendo exibida
  Timer? _timer; // Timer para atualizar a UI progressivamente

  String _folderPath = ''; // Para armazenar o caminho da pasta
  final TextEditingController _folderPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedFolderPath(); // Carregar o caminho salvo quando o app iniciar
  }

  Future<void> _loadSavedFolderPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _folderPath = prefs.getString('folderPath') ?? ''; // Carregar o caminho salvo
      _folderPathController.text = _folderPath; // Atualizar o campo de texto com o valor salvo
    });
  }

  Future<void> _saveFolderPath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('folderPath', path); // Salvar o caminho da pasta
  }

  Future<void> _runCommand(String command) async {
    var shell = Shell();
    try {
      var result = await shell.run(command);
      _outputLines = result.outText.split('\n'); // Dividir a saída por linhas
      _startDisplayingOutput();
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }
  }

  void _startDisplayingOutput() {
    _currentLineIndex = 0;
    _output = '';

    _timer?.cancel(); // Cancelar qualquer timer existente

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentLineIndex < _outputLines.length) {
        setState(() {
          _output = _outputLines[_currentLineIndex]; // Atualizar a saída com a linha atual
        });
        _currentLineIndex++;
      } else {
        timer.cancel(); // Parar o timer quando todas as linhas forem exibidas
      }
    });
  }

  // Função para baixar dependências
  Future<void> _downloadDependencies() async {
    if (_folderPath.isNotEmpty) {
      String command = 'pip install -r $_folderPath/requirements.txt';
      await _runCommand(command); // Rodar o comando e exibir a saída
    } else {
      setState(() {
        _output = 'Please enter a valid folder path.';
      });
    }
  }

  // Função para rodar o programa
  Future<void> _runProgram() async {
    if (_folderPath.isNotEmpty) {
      String command = 'python -u $_folderPath/main.py';
      await _runCommand(command); // Rodar o comando e exibir a saída
    } else {
      setState(() {
        _output = 'Please enter a valid folder path.';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _folderPathController.dispose();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _folderPathController,
                decoration: const InputDecoration(
                  labelText: 'Enter Folder Path',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _folderPath = value;
                  });
                  _saveFolderPath(value); // Salvar o caminho quando o usuário der enter
                },
              ),
            ),
            ElevatedButton(
              onPressed: _downloadDependencies, // Chama a função de baixar dependências
              child: const Text('Baixar Dependências'),
            ),
            ElevatedButton(
              onPressed: _runProgram, // Chama a função de rodar o programa
              child: const Text('Rodar Programa'),
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
