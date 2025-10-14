import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/time_record.dart';
import 'history_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

/// Tela principal (Dashboard) do sistema
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final user = _dataService.currentUser!;
    final isAdminOrManager = _dataService.isAdminOrManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
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
                            color: const Color(0xFF000),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perfil: ${user.role.displayName}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
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
            
            // Botão de histórico
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver Histórico Completo'),
              style: ElevatedButton.styleFrom(
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
    final hasActiveWork = _dataService.hasActivePeriod(
      userId: userId,
      type: RecordType.trabalho,
    );
    final hasActiveBreak = _dataService.hasActivePeriod(
      userId: userId,
      type: RecordType.pausa,
    );
    final summary = _dataService.getDailySummary(userId, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Resumo diário do funcionário
        _buildDailySummaryCard(summary),
        const SizedBox(height: 24),

        // Botões de controle
        const Text(
          'Controle de Ponto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000),
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
                    : () {
                        _dataService.startPeriod(
                          userId: userId,
                          type: RecordType.trabalho,
                        );
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trabalho iniciado!'),
                            backgroundColor: Color(0xFF14a25c),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar\nTrabalho'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveWork
                      ? Colors.grey
                      : const Color(0xFF14a25c),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !hasActiveWork
                    ? null
                    : () {
                        _dataService.stopActivePeriod(
                          userId: userId,
                          type: RecordType.trabalho,
                        );
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trabalho finalizado!'),
                            backgroundColor: Color(0xFFf28b4f),
                          ),
                        );
                      },
                icon: const Icon(Icons.stop),
                label: const Text('Parar\nTrabalho'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !hasActiveWork
                      ? Colors.grey
                      : const Color(0xFFf28b4f),
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
                    : () {
                        _dataService.startPeriod(
                          userId: userId,
                          type: RecordType.pausa,
                        );
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pausa iniciada!'),
                            backgroundColor: Color(0xFFf28b4f),
                          ),
                        );
                      },
                icon: const Icon(Icons.pause),
                label: const Text('Iniciar\nPausa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF000),
                  side: const BorderSide(color: Color(0xFFf28b4f), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: !hasActiveBreak
                    ? null
                    : () {
                        _dataService.stopActivePeriod(
                          userId: userId,
                          type: RecordType.pausa,
                        );
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pausa finalizada!'),
                            backgroundColor: Color(0xFF14a25c),
                          ),
                        );
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Retornar ao\nTrabalho'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF000),
                  side: const BorderSide(color: Color(0xFF14a25c), width: 2),
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
                    ? const Color(0xFFf28b4f).withOpacity(0.1)
                    : const Color(0xFF14a25c).withOpacity(0.1))
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasActiveWork
                  ? (hasActiveBreak ? const Color(0xFFf28b4f) : const Color(0xFF14a25c))
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
                    ? (hasActiveBreak ? const Color(0xFFf28b4f) : const Color(0xFF14a25c))
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
                      ? const Color(0xFF000)
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
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
        const Text(
          'Resumo de Todos os Funcionários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000),
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
            final summary = _dataService.getDailySummary(
              employee.id,
              DateTime.now(),
            );
            return _buildEmployeeSummaryCard(employee, summary);
          }).toList(),
      ],
    );
  }

  /// Card de resumo diário individual
  Widget _buildDailySummaryCard(DailySummary summary) {
    return Card(
      color: const Color(0xFF14a25c).withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Color(0xFF14a25c)),
                const SizedBox(width: 8),
                Text(
                  'Resumo de Hoje',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total Trabalhado:',
              DailySummary.formatHours(summary.totalWorkHours),
              Icons.work,
              const Color(0xFF14a25c),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total de Pausas:',
              DailySummary.formatHours(summary.totalBreakHours),
              Icons.pause_circle,
              const Color(0xFFf28b4f),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Horas Líquidas:',
              DailySummary.formatHours(summary.netWorkHours),
              Icons.check_circle,
              const Color(0xFF14a25c),
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
                  backgroundColor: const Color(0xFF14a25c),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000),
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
                  const Color(0xFF14a25c),
                ),
                _buildCompactSummary(
                  'Pausas',
                  DailySummary.formatHours(summary.totalBreakHours),
                  const Color(0xFFf28b4f),
                ),
                _buildCompactSummary(
                  'Líquido',
                  DailySummary.formatHours(summary.netWorkHours),
                  const Color(0xFF000),
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
