import 'package:enc/history_page.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Encryption Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> _history = []; // List to store history of encrypted messages
  String _encryptedMessage = '';
  String _decryptedMessage = '';
  enc.IV? _lastIV;

  void _encryptData() {
    final key = enc.Key.fromUtf8(_passwordController.text.padRight(32, '#'));
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encrypt(_textController.text, iv: iv);
    setState(() {
      _encryptedMessage = encrypted.base64;
      _lastIV = iv;
      _history.add(_encryptedMessage); // Add encrypted message to history
    });
  }

  void _decryptData() {
    final key = enc.Key.fromUtf8(_passwordController.text.padRight(32, '#'));
    if (_lastIV != null && _encryptedMessage.isNotEmpty) {
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter
          .decrypt(enc.Encrypted.fromBase64(_encryptedMessage), iv: _lastIV);
      setState(() {
        _decryptedMessage = decrypted;
      });
    }
  }

  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage(history: _history)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _encryptData,
                    child: const Text('Encrypt'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _decryptData,
                    child: Text('Decrypt'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _viewHistory,
                    child: const Text('History'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SelectableText('Encrypted Message: $_encryptedMessage'),
            const SizedBox(height: 20),
            SelectableText('Decrypted Message: $_decryptedMessage'),
          ],
        ),
      ),
    );
  }
}
