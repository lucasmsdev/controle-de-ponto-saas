import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/time_record.dart';

/// Tela para lançamento manual de horários
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _dataService = DataService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  RecordType _recordType = RecordType.trabalho;
  User? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    final currentUser = _dataService.currentUser!;
    final isManager = _dataService.isAdminOrManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamento Manual'),
      ),
      body: isManager
          ? _buildManagerForm()
          : FutureBuilder<bool>(
              future: _dataService.hasManualRecordToday(currentUser.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final hasManualToday = snapshot.data!;
                
                return hasManualToday
                    ? _buildAlreadyRegisteredMessage()
                    : _buildEmployeeForm();
              },
            ),
    );
  }

  Widget _buildEmployeeForm() {
    return _buildFormContent(false);
  }

  Widget _buildManagerForm() {
    return _buildFormContent(true);
  }

  Widget _buildFormContent(bool isManager) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mensagem informativa
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isManager
                            ? 'Você pode lançar horários para qualquer funcionário'
                            : 'Você pode lançar um horário manual por dia',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seleção de funcionário (apenas para gerente)
            if (isManager) ...[
              const Text(
                'Funcionário',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
                      DropdownButtonFormField<User>(
                        value: _selectedEmployee,
                        decoration: const InputDecoration(
                          hintText: 'Selecione o funcionário',
                        ),
                        items: _dataService.getEmployees().map((employee) {
                          return DropdownMenuItem(
                            value: employee,
                            child: Text(employee.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployee = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um funcionário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

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
                      onPressed: _saveManualEntry,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Registro'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            );
  }

  Widget _buildAlreadyRegisteredMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Você já fez um lançamento manual hoje',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionários podem fazer apenas um lançamento manual por dia',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveManualEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = _dataService.currentUser!;
    final isManager = _dataService.isAdminOrManager;
    
    // Define o usuário para quem o registro será feito
    final targetUserId = isManager && _selectedEmployee != null
        ? _selectedEmployee!.id
        : currentUser.id;

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
      // Adiciona o registro com await
      final success = await _dataService.addManualRecord(
        userId: targetUserId,
        startTime: startDateTime,
        endTime: endDateTime,
        type: _recordType,
      );

      if (!mounted) return;

      if (success) {
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registro salvo com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Volta para a tela anterior
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar registro. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
