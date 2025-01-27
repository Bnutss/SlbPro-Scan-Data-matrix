import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _articleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final List<String> _codes = [];
  String _errorMessage = '';

  final String _telegramBotToken = '7428891276:AAFevI_0HhcEjELCvJp6afdgmFQxxMUvJCo';
  final String _telegramChatId = '-1002150617251';

  void _addItem() {
    final String code = _codeController.text.trim();
    if (_articleController.text.isEmpty || _sizeController.text.isEmpty || code.isEmpty) {
      setState(() {
        _errorMessage = 'Заполните все поля!';
        _codeController.clear();
        _codeFocusNode.requestFocus();
      });
      return;
    }

    if (_codes.contains(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Код уже существует!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      _codeController.clear();
      _codeFocusNode.requestFocus();
      return;
    }

    setState(() {
      _codes.insert(0, code);
      _errorMessage = '';
      _codeController.clear();
      _codeFocusNode.requestFocus();
    });
  }

  Future<void> _sendToTelegram() async {
    try {
      final content = _codes.join('\n');
      final articleName = _articleController.text.trim();
      final size = _sizeController.text.trim();

      if (articleName.isEmpty || size.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Введите артикул и размер для отправки файла!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final fileName = '${articleName}_$size.txt';

      final url = Uri.parse(
          'https://api.telegram.org/bot$_telegramBotToken/sendDocument');
      final request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = _telegramChatId
        ..files.add(http.MultipartFile.fromString(
          'document',
          content,
          filename: fileName,
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Файл успешно отправлен!'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuPage()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка отправки файла!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _articleController.dispose();
    _sizeController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SLBPRO',
              style: TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                const Icon(Icons.list, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Кодов: ${_codes.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _articleController,
                decoration: const InputDecoration(
                  labelText: 'Артикул',
                  prefixIcon: Icon(Icons.article),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Размер',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Код',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _addItem();
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _codes.length,
                  itemBuilder: (context, index) {
                    final displayNumber = _codes.length - index;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '$displayNumber',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_codes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _codes.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: _sendToTelegram,
                  icon: const Icon(Icons.send),
                  label: const Text('Завершить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}