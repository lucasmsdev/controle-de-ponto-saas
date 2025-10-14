import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../services/theme_service.dart';
import '../models/user.dart';
import '../models/time_record.dart';
import 'history_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'manual_entry_screen.dart';

/// Tela principal (Dashboard) do sistema
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataService = DataService();
  final _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    final user = _dataService.currentUser!;
    final isAdminOrManager = _dataService.isAdminOrManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Toggle de modo claro/escuro
          IconButton(
            icon: Icon(_themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _themeService.toggleTheme();
              });
            },
            tooltip: _themeService.isDarkMode ? 'Modo Claro' : 'Modo Escuro',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _dataService.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de boas-vindas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, ${user.name}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perfil: ${user.role.displayName}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Conteúdo específico por tipo de usuário
            if (!isAdminOrManager) ...[
              _buildEmployeeContent(),
            ] else ...[
              _buildManagerContent(),
            ],

            const SizedBox(height: 24),
            
            // Botão de lançamento manual
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManualEntryScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Lançamento Manual de Horário'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botão de histórico
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver Histórico Completo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Conteúdo para funcionários: botões start/stop e resumo pessoal
  Widget _buildEmployeeContent() {
    final userId = _dataService.currentUser!.id;

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        _dataService.hasActivePeriod(userId: userId, type: RecordType.trabalho),
        _dataService.hasActivePeriod(userId: userId, type: RecordType.pausa),
        _dataService.getDailySummary(userId, DateTime.now()),
      ]).then((results) => {
        'hasActiveWork': results[0],
        'hasActiveBreak': results[1],
        'summary': results[2],
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasActiveWork = snapshot.data!['hasActiveWork'] as bool;
        final hasActiveBreak = snapshot.data!['hasActiveBreak'] as bool;
        final summary = snapshot.data!['summary'] as DailySummary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo diário do funcionário
            _buildDailySummaryCard(summary),
            const SizedBox(height: 24),

            // Botões de controle
            Text(
              'Controle de Ponto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Botões de Trabalho
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasActiveWork
                        ? null
                        : () async {
                            await _dataService.startPeriod(
                              userId: userId,
                              type: RecordType.trabalho,
                            );
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Trabalho iniciado!'),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar\nTrabalho'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasActiveWork ? Colors.grey : null,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !hasActiveWork
                        ? null
                        : () async {
                            await _dataService.stopActivePeriod(
                              userId: userId,
                              type: RecordType.trabalho,
                            );
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Trabalho finalizado!'),
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.stop),
                    label: const Text('Parar\nTrabalho'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !hasActiveWork
                          ? Colors.grey
                          : Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botões de Pausa
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasActiveBreak || !hasActiveWork
                        ? null
                        : () async {
                            await _dataService.startPeriod(
                              userId: userId,
                              type: RecordType.pausa,
                            );
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Pausa iniciada!'),
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.pause),
                    label: const Text('Iniciar\nPausa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: !hasActiveBreak
                        ? null
                        : () async {
                            await _dataService.stopActivePeriod(
                              userId: userId,
                              type: RecordType.pausa,
                            );
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Pausa finalizada!'),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Retornar ao\nTrabalho'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ],
            ),

            // Indicador de status
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasActiveWork
                    ? (hasActiveBreak
                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1))
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasActiveWork
                      ? (hasActiveBreak 
                          ? Theme.of(context).colorScheme.secondary 
                          : Theme.of(context).colorScheme.primary)
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasActiveWork
                        ? (hasActiveBreak ? Icons.pause_circle : Icons.work)
                        : Icons.info_outline,
                    color: hasActiveWork
                        ? (hasActiveBreak 
                            ? Theme.of(context).colorScheme.secondary 
                            : Theme.of(context).colorScheme.primary)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasActiveWork
                        ? (hasActiveBreak ? 'Em Pausa' : 'Trabalhando')
                        : 'Fora do Expediente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: hasActiveWork
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Conteúdo para Admin/Gerente: resumo de todos os funcionários
  Widget _buildManagerContent() {
    final employees = _dataService.getEmployees();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botão de administração
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminScreen(),
              ),
            ).then((_) => setState(() {}));
          },
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text('Administração de Usuários'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 24),

        // Título
        Text(
          'Resumo de Todos os Funcionários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Lista de funcionários com seus resumos
        if (employees.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Nenhum funcionário cadastrado',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...employees.map((employee) {
            return FutureBuilder<DailySummary>(
              future: _dataService.getDailySummary(employee.id, DateTime.now()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                return _buildEmployeeSummaryCard(employee, snapshot.data!);
              },
            );
          }).toList(),
      ],
    );
  }

  /// Card de resumo diário individual
  Widget _buildDailySummaryCard(DailySummary summary) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resumo de Hoje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total Trabalhado:',
              DailySummary.formatHours(summary.totalWorkHours),
              Icons.work,
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total de Pausas:',
              DailySummary.formatHours(summary.totalBreakHours),
              Icons.pause_circle,
              Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Horas Líquidas:',
              DailySummary.formatHours(summary.netWorkHours),
              Icons.check_circle,
              Theme.of(context).colorScheme.primary,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Card de resumo para cada funcionário (visão do gerente)
  Widget _buildEmployeeSummaryCard(User employee, DailySummary summary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    employee.name[0].toUpperCase(),
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
                        employee.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        employee.email,
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
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactSummary(
                  'Trabalhado',
                  DailySummary.formatHours(summary.totalWorkHours),
                  Theme.of(context).colorScheme.primary,
                ),
                _buildCompactSummary(
                  'Pausas',
                  DailySummary.formatHours(summary.totalBreakHours),
                  Theme.of(context).colorScheme.secondary,
                ),
                _buildCompactSummary(
                  'Líquido',
                  DailySummary.formatHours(summary.netWorkHours),
                  Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Linha de resumo com ícone
  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Resumo compacto para cards de funcionários
  Widget _buildCompactSummary(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
