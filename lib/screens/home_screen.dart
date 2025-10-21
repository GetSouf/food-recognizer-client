// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/scan_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _weightController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = '';
          _isLoading = true;
        });
        await _sendToApi();
      }
    } catch (e) {
      setState(() {
        _result = 'Ошибка при выборе фото: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendToApi() async {
    try {
      final json = await ScanService.predictImage(_image!, weightG: _weightController.text.isNotEmpty ? _weightController.text : null);
      setState(() {
        _result = '''
Блюдо: ${json["dish"]}
Вес: ${json["estimated_weight_g"].toStringAsFixed(1)} г
Калории: ${json["calories"].toStringAsFixed(1)} ккал
Белки: ${json["proteins"].toStringAsFixed(1)} г
Жиры: ${json["fats"].toStringAsFixed(1)} г
Углеводы: ${json["carbs"].toStringAsFixed(1)} г
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: () async {}, // Ничего не обновляем
      child: Scaffold(
        appBar: AppBar(title: const Text('Сканирование')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null) Image.file(_image!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Вес (г, опционально)'),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                    child: const Text('Сфоткать еду'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                    child: const Text('Выбрать фото'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
              if (_result.isNotEmpty) Text(_result),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
}