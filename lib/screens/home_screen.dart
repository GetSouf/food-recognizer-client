// lib/screens/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/scan_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final TextEditingController _weightController = TextEditingController();
  Map<String, dynamic>? _apiResult; // ← храним как Map, а не строку
  bool _isLoading = false;

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  static List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_cameras == null) {
      _cameras = await availableCameras();
    }
    final firstCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras![0],
    );

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) return;

    try {
      await _initializeControllerFuture;
      final XFile image = await _cameraController.takePicture();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(image.path).copy(file.path);

      setState(() {
        _image = file;
        _apiResult = null;
        _isLoading = true;
      });

      await _sendToApi(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiResult = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _image = file;
        _apiResult = null;
        _isLoading = true;
      });
      await _sendToApi(file);
    }
  }

  Future<void> _sendToApi(File imageFile) async {
    try {
      final json = await ScanService.predictImage(
        imageFile,
        weightG: _weightController.text.isNotEmpty ? _weightController.text : null,
      );

      if (!mounted) return;

      setState(() {
        _apiResult = json; // ← сохраняем как Map
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiResult = null;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 1. Превью камеры — квадратное
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.85,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black,
                  child: _image == null
                      ? FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return CameraPreview(_cameraController);
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        )
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Вес | 3. Сфоткать | 4. Галерея
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: 'Вес, г',
                        hintStyle: const TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePicture,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Сфоткать', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Галерея', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. КРАСИВЫЙ ВЫВОД ИЗ API
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor!),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _apiResult != null
                        ? _buildNutritionCard(_apiResult!)
                        : const Center(
                            child: Text(
                              'Сделайте фото или выберите из галереи',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Красивая карточка на основе реального API-ответа
  Widget _buildNutritionCard(Map<String, dynamic> data) {
    final dish = data["dish"] ?? "Не распознано";
    final weight = (data["estimated_weight_g"] as num?)?.toStringAsFixed(1) ?? "—";
    final calories = (data["calories"] as num?)?.toStringAsFixed(1) ?? "—";
    final proteins = (data["proteins"] as num?)?.toStringAsFixed(1) ?? "—";
    final fats = (data["fats"] as num?)?.toStringAsFixed(1) ?? "—";
    final carbs = (data["carbs"] as num?)?.toStringAsFixed(1) ?? "—";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dish,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 24, thickness: 1),
        Row(
          children: [
            Expanded(child: _buildNutrientItem("⚖️", "Вес", "$weight г")),
            Expanded(child: _buildNutrientItem("🔥", "Калории", "$calories ккал")),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildNutrientItem("🍗", "Белки", "$proteins г")),
            Expanded(child: _buildNutrientItem("🧈", "Жиры", "$fats г")),
            Expanded(child: _buildNutrientItem("🍞", "Углеводы", "$carbs г")),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientItem(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}