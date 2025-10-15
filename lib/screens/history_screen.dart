import 'package:flutter/material.dart';
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

  // Chave para forçar rebuild do FutureBuilder
  Key _futureBuilderKey = UniqueKey();

  void _refreshData() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdminOrManager = _dataService.isAdminOrManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico (30 dias)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de usuário (apenas para admin/gerente)
          if (isAdminOrManager) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String?>(
                value: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por usuário',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos os usuários'),
                  ),
                  ..._dataService.users.map((user) {
                    return DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text('${user.name} (${user.role.displayName})'),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                    _futureBuilderKey = UniqueKey(); // Atualiza dados
                  });
                },
              ),
            ),
          ],

          // Lista de registros usando FutureBuilder para dados do Supabase
          Expanded(
            child: FutureBuilder<List<TimeRecord>>(
              key: _futureBuilderKey,
              future: _selectedUserId != null
                  ? _dataService.getUserRecords(_selectedUserId!)
                  : isAdminOrManager
                      ? _dataService.getAllRecords()
                      : _dataService.getUserRecords(_dataService.currentUser!.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar histórico:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum registro encontrado',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final user = _dataService.users.firstWhere(
                      (u) => u.id == record.userId,
                      orElse: () => User(
                        id: record.userId,
                        name: 'Usuário desconhecido',
                        email: '',
                        password: '',
                        role: UserRole.funcionario,
                      ),
                    );
                    return _buildRecordCard(record, user, isAdminOrManager);
                  },
                );
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

    // Formata data manualmente sem intl
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    String formatTime(DateTime time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

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
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.role == UserRole.admin
                          ? Colors.red.shade100
                          : user.role == UserRole.gerente
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: user.role == UserRole.admin
                            ? Colors.red.shade900
                            : user.role == UserRole.gerente
                                ? Colors.orange.shade900
                                : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Tipo de registro e badge manual
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: record.type == RecordType.trabalho
                        ? Colors.blue.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        record.type == RecordType.trabalho
                            ? Icons.work
                            : Icons.coffee,
                        size: 16,
                        color: record.type == RecordType.trabalho
                            ? Colors.blue.shade900
                            : Colors.orange.shade900,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        record.type == RecordType.trabalho ? 'Trabalho' : 'Pausa',
                        style: TextStyle(
                          color: record.type == RecordType.trabalho
                              ? Colors.blue.shade900
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de lançamento manual (TODO: adicionar campo isManual ao modelo)
                /*if (record.isManual)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.purple.shade900,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Manual',
                          style: TextStyle(
                            color: Colors.purple.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),*/
              ],
            ),
            const SizedBox(height: 12),

            // Data
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  formatDate(record.startTime),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Horários
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${formatTime(record.startTime)} - ${record.endTime != null ? formatTime(record.endTime!) : 'Em andamento'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Duração
            Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  isActive
                      ? 'Em andamento (${hours}h ${minutes}min)'
                      : 'Duração: ${hours}h ${minutes}min',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.green : null,
                  ),
                ),
              ],
            ),

            // Botões de ação (editar/excluir)
            if (canEdit) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecordScreen(record: record),
                        ),
                      );
                      if (result == true && mounted) {
                        _refreshData();
                      }
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(record),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
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

  Future<void> _confirmDelete(TimeRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _dataService.deleteRecord(record.id);
        if (mounted) {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir registro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
