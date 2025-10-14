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
    final isActive = record.isActive;
    final duration = record.durationInMinutes;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showUserInfo) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF14a25c),
                    radius: 16,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: record.type == RecordType.trabalho
                        ? const Color(0xFF14a25c).withOpacity(0.1)
                        : const Color(0xFFf28b4f).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: record.type == RecordType.trabalho
                          ? const Color(0xFF14a25c)
                          : const Color(0xFFf28b4f),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        record.type == RecordType.trabalho
                            ? Icons.work
                            : Icons.pause_circle,
                        size: 18,
                        color: record.type == RecordType.trabalho
                            ? const Color(0xFF14a25c)
                            : const Color(0xFFf28b4f),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        record.type.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: record.type == RecordType.trabalho
                              ? const Color(0xFF14a25c)
                              : const Color(0xFFf28b4f),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Em andamento',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(record.startTime),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(record.startTime),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.endTime != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '→',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(record.endTime!),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Color(0xFF000)),
                const SizedBox(width: 6),
                Text(
                  'Duração: ${hours}h ${minutes}min',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
