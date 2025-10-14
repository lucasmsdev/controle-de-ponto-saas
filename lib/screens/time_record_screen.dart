import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/time_record.dart';

/// Tela para registro de ponto com foto
class TimeRecordScreen extends StatefulWidget {
  final RecordType recordType;

  const TimeRecordScreen({
    super.key,
    required this.recordType,
  });

  @override
  State<TimeRecordScreen> createState() => _TimeRecordScreenState();
}

class _TimeRecordScreenState extends State<TimeRecordScreen> {
  final _dataService = DataService();
  final _imagePicker = ImagePicker();
  String? _imagePath;
  bool _isProcessing = false;

  /// Captura foto usando a câmera
  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
      );

      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Seleciona foto da galeria (alternativa)
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Registra o ponto
  Future<void> _registerTimeRecord() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, tire uma foto primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final record = _dataService.addTimeRecord(
      userId: _dataService.currentUser!.id,
      timestamp: DateTime.now(),
      type: widget.recordType,
      photoPath: _imagePath,
      isManual: false,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.recordType.displayName} registrado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar ${widget.recordType.displayName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _getIconForRecordType(),
                      size: 64,
                      color: _getColorForRecordType(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.recordType.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_imagePath != null) ...[
              const Text(
                'Foto capturada:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Text(
                'Nenhuma foto capturada',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tirar Foto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Escolher da Galeria'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _registerTimeRecord,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _getColorForRecordType(),
                foregroundColor: Colors.white,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar ${widget.recordType.displayName}',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRecordType() {
    switch (widget.recordType) {
      case RecordType.entrada:
        return Icons.login;
      case RecordType.saida:
        return Icons.logout;
      case RecordType.inicioPausa:
        return Icons.pause_circle;
      case RecordType.fimPausa:
        return Icons.play_circle;
    }
  }

  Color _getColorForRecordType() {
    switch (widget.recordType) {
      case RecordType.entrada:
        return Colors.green;
      case RecordType.saida:
        return Colors.red;
      case RecordType.inicioPausa:
        return Colors.orange;
      case RecordType.fimPausa:
        return Colors.blue;
    }
  }
}
