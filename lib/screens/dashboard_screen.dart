import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/user.dart';
import '../models/time_record.dart';
import 'time_record_screen.dart';
import 'manual_record_screen.dart';
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, ${user.name}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Perfil: ${user.role.displayName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!isAdminOrManager) ...[
              const Text(
                'Registro de Ponto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildEmployeeActions(),
            ] else ...[
              const Text(
                'Gerenciamento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildManagerActions(),
            ],
            const SizedBox(height: 24),
            const Text(
              'Histórico',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver Histórico de Pontos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ações disponíveis para funcionários
  Widget _buildEmployeeActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimeRecordScreen(
                  recordType: RecordType.entrada,
                ),
              ),
            );
          },
          icon: const Icon(Icons.login),
          label: const Text('Registrar Entrada'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimeRecordScreen(
                  recordType: RecordType.saida,
                ),
              ),
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Registrar Saída'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimeRecordScreen(
                  recordType: RecordType.inicioPausa,
                ),
              ),
            );
          },
          icon: const Icon(Icons.pause_circle),
          label: const Text('Iniciar Pausa'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimeRecordScreen(
                  recordType: RecordType.fimPausa,
                ),
              ),
            );
          },
          icon: const Icon(Icons.play_circle),
          label: const Text('Encerrar Pausa'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ManualRecordScreen(),
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Lançamento Manual'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// Ações disponíveis para admin/gerente
  Widget _buildManagerActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total de funcionários: ${_dataService.users.where((u) => u.role == UserRole.funcionario).length}',
                ),
                Text(
                  'Total de registros: ${_dataService.timeRecords.length}',
                ),
                Text(
                  'Registros hoje: ${_dataService.timeRecords.where((r) {
                    final now = DateTime.now();
                    return r.timestamp.year == now.year &&
                        r.timestamp.month == now.month &&
                        r.timestamp.day == now.day;
                  }).length}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
