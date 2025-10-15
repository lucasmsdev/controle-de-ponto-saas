import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/time_record.dart';

/// Tela para edição de registros (apenas para gerentes, últimos 30 dias)
class EditRecordScreen extends StatefulWidget {
  final TimeRecord record;
  
  const EditRecordScreen({super.key, required this.record});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _dataService = DataService();
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late RecordType _recordType;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.record.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.record.startTime);
    _endTime = widget.record.endTime != null 
        ? TimeOfDay.fromDateTime(widget.record.endTime!)
        : TimeOfDay.now();
    _recordType = widget.record.type;
  }

  @override
  Widget build(BuildContext context) {
    final user = _dataService.users.firstWhere((u) => u.id == widget.record.userId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Registro'),
        actions: [
          // Botão de deletar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
            tooltip: 'Excluir registro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informações do funcionário
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tipo de registro
              const Text(
                'Tipo de Registro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<RecordType>(
                segments: const [
                  ButtonSegment(
                    value: RecordType.trabalho,
                    label: Text('Trabalho'),
                    icon: Icon(Icons.work),
                  ),
                  ButtonSegment(
                    value: RecordType.pausa,
                    label: Text('Pausa'),
                    icon: Icon(Icons.pause_circle),
                  ),
                ],
                selected: {_recordType},
                onSelectionChanged: (Set<RecordType> selected) {
                  setState(() {
                    _recordType = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Data
              const Text(
                'Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horário de início
              const Text(
                'Horário de Início',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _startTime.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horário de término
              const Text(
                'Horário de Término',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _endTime.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botão de salvar
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Cria os DateTime completos
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Valida se horário de término é depois do início
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O horário de término deve ser posterior ao de início'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Atualiza o registro
      final updatedRecord = widget.record.copyWith(
        startTime: startDateTime,
        endTime: endDateTime,
        type: _recordType,
      );

      final success = await _dataService.updateRecord(updatedRecord);

      if (!mounted) return;

      if (success) {
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registro atualizado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Volta para a tela anterior com sucesso
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar registro. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: const Text('Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await _dataService.deleteRecord(widget.record.id);
                
                if (!mounted) return;
                
                Navigator.of(context).pop(); // Fecha o diálogo
                
                if (success) {
                  Navigator.of(context).pop(true); // Volta para o histórico com sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao excluir registro. Tente novamente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                
                Navigator.of(context).pop(); // Fecha o diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
