import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _articleController = TextEditingController();
  final _sizeController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final List<String> _codes = [];
  bool _hasError = false;

  final String _botToken = '7428891276:AAGWpszMVc_Pcz-qU5a00EEFpRnIuCeoNRY';
  final String _chatId = '-1002150617251';

  void _addCode() {
    final code = _codeController.text.trim();

    if (_articleController.text
        .trim()
        .isEmpty ||
        _sizeController.text
            .trim()
            .isEmpty ||
        code.isEmpty) {
      setState(() => _hasError = true);
      _codeController.clear();
      _codeFocusNode.requestFocus();
      return;
    }

    if (_codes.contains(code)) {
      _showSnack('Код уже добавлен', isError: true);
      _codeController.clear();
      _codeFocusNode.requestFocus();
      return;
    }

    setState(() {
      _codes.insert(0, code);
      _hasError = false;
      _codeController.clear();
    });
    _codeFocusNode.requestFocus();
    _showSnack('Добавлено: ${_codes.length}', isError: false);
  }

  Future<void> _send() async {
    final article = _articleController.text.trim();
    final size = _sizeController.text.trim();

    if (article.isEmpty || size.isEmpty) {
      _showSnack('Заполните артикул и размер', isError: true);
      return;
    }
    if (_codes.isEmpty) {
      _showSnack('Нет кодов для отправки', isError: true);
      return;
    }

    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$_botToken/sendDocument');
      final request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = _chatId
        ..files.add(http.MultipartFile.fromString(
          'document',
          _codes.join('\n'),
          filename: '${article}_$size.txt',
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        _showSnack('Файл отправлен!', isError: false);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MenuPage()),
          );
        }
      } else {
        _showSnack('Ошибка отправки', isError: true);
      }
    } catch (e) {
      _showSnack('Ошибка: $e', isError: true);
    }
  }

  void _showSnack(String text, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontSize: 13)),
        backgroundColor: isError ? const Color(0xFFc0392b) : const Color(
            0xFF27ae60),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 2 : 1),
      ),
    );
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
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2c3e50), Color(0xFF3498db)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Сканирование КМ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '${_codes.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              children: [
                _buildField(_articleController, 'Артикул', Icons.label_outline),
                const SizedBox(height: 10),
                _buildField(_sizeController, 'Размер', Icons.straighten),
                const SizedBox(height: 10),
                _buildCodeField(),
                if (_hasError) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe74c3c).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe74c3c)
                          .withOpacity(0.5)),
                    ),
                    child: const Text(
                      'Заполните все поля',
                      style: TextStyle(color: Color(0xFFe74c3c), fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: _codes.isEmpty ? _buildEmpty() : _buildList(),
                ),
                const SizedBox(height: 12),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      IconData icon) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF4a69bd), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: TextField(
        controller: _codeController,
        focusNode: _codeFocusNode,
        onSubmitted: (_) => _addCode(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: 'Код маркировки',
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 13),
          prefixIcon: const Icon(
              Icons.qr_code_scanner, color: Color(0xFF4a69bd), size: 18),
          suffixIcon: IconButton(
            icon: const Icon(
                Icons.add_circle_outline, color: Color(0xFF4a69bd), size: 20),
            onPressed: _addCode,
            padding: EdgeInsets.zero,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _codes.length,
      itemBuilder: (context, index) {
        final num = _codes.length - index;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4a69bd), Color(0xFF1e3799)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$num',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _codes[index],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _codes.removeAt(index)),
                child: Icon(Icons.close, color: Colors.white.withOpacity(0.4),
                    size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 44, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'Нет кодов',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Начните сканирование',
            style: TextStyle(
                color: Colors.white.withOpacity(0.25), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4a69bd), Color(0xFF0c2461)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498db).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _send,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, size: 20, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Отправить в Telegram',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}