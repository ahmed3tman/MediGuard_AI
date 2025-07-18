import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// صفحة اختبار لتشخيص مشكلة حفظ اللغة
class LanguageTestScreen extends StatefulWidget {
  const LanguageTestScreen({super.key});

  @override
  State<LanguageTestScreen> createState() => _LanguageTestScreenState();
}

class _LanguageTestScreenState extends State<LanguageTestScreen> {
  String? _savedLanguage;
  String? _currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code');
    setState(() {
      _savedLanguage = savedLang;
      _currentLanguage = savedLang ?? 'en';
    });
    print('Loaded language from SharedPreferences: $savedLang');
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    print('Saved language to SharedPreferences: $languageCode');
    _loadLanguage(); // إعادة تحميل للتأكد
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Test'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Language: ${_savedLanguage ?? "Not set"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Language: ${_currentLanguage ?? "Not set"}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _saveLanguage('en'),
                  child: const Text('Save English'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _saveLanguage('ar'),
                  child: const Text('Save Arabic'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLanguage,
              child: const Text('Reload Language'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('1. Press "Save Arabic"'),
            const Text('2. Hot restart the app'),
            const Text('3. Check if language is still "ar"'),
          ],
        ),
      ),
    );
  }
}
