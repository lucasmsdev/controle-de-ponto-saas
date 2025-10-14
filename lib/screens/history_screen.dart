import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/time_record.dart';
import '../models/user.dart';
import 'edit_record_screen.dart';

/// Tela de histórico de registros de ponto (últimos 30 dias)
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
    
    // Obtém registros dos últimos 30 dias
    final records = _dataService.getRecordsLastDays(
      30,
      userId: _selectedUserId ?? (!isAdminOrManager ? _dataService.currentUser!.id : null),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico (30 dias)'),
      ),
      body: Column(
        children: [
          // Filtro de usuário (apenas para admin/gerente)
          if (isAdminOrManager) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por usuário',
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
          
          // Lista de registros
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
    bool isManager,
  ) {
    final isActive = record.isActive;
    final duration = record.durationInMinutes;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    final canEdit = isManager && _dataService.canEditRecord(record);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do usuário (para gerente)
            if (isManager) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Botão de editar (apenas para gerente e registros editáveis)
                  if (canEdit)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditRecordScreen(record: record),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      tooltip: 'Editar registro',
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Badge de tipo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: record.type == RecordType.trabalho
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: record.type == RecordType.trabalho
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        record.type.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: record.type == RecordType.trabalho
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radio_button_checked, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Em Andamento',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            
            // Data e horários
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(record.startTime),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('HH:mm').format(record.startTime)} - ${record.endTime != null ? DateFormat('HH:mm').format(record.endTime!) : '...'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Duração
            if (!isActive) ...[
              Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Duração: ${hours}h ${minutes}min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
