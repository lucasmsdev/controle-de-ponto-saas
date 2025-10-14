import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/time_record.dart';
import '../models/user.dart';

/// Tela de histórico de registros de ponto
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dataService = DataService();
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final isAdminOrManager = _dataService.isAdminOrManager;
    final records = isAdminOrManager && _selectedUserId != null
        ? _dataService.getUserRecords(_selectedUserId!)
        : isAdminOrManager
            ? _dataService.getAllRecords()
            : _dataService.getUserRecords(_dataService.currentUser!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontos'),
      ),
      body: Column(
        children: [
          if (isAdminOrManager) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por usuário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todos os usuários'),
                  ),
                  ..._dataService.users.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text('${user.name} (${user.role.displayName})'),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() => _selectedUserId = value);
                },
              ),
            ),
          ],
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum registro encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final user = _dataService.users.firstWhere(
                        (u) => u.id == record.userId,
                      );
                      return _buildRecordCard(record, user, isAdminOrManager);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    TimeRecord record,
    User user,
    bool showUserInfo,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: record.photoPath != null
            ? () => _showPhotoDialog(record.photoPath!)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (record.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(record.photoPath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_not_supported),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showUserInfo) ...[
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          _getIconForRecordType(record.type),
                          size: 20,
                          color: _getColorForRecordType(record.type),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record.type.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getColorForRecordType(record.type),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(record.timestamp),
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (record.isManual) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Manual',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoDialog(String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Foto do Registro'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Image.file(File(photoPath)),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRecordType(RecordType type) {
    switch (type) {
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

  Color _getColorForRecordType(RecordType type) {
    switch (type) {
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
