import '../models/user.dart';
import '../models/time_record.dart';

/// Serviço para gerenciar dados localmente (simulando banco de dados)
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  /// Usuário atualmente logado
  User? currentUser;

  /// Lista de usuários do sistema (dados mockados para MVP)
  final List<User> users = [
    User(
      id: '1',
      name: 'Admin Sistema',
      email: 'admin@empresa.com',
      password: 'admin123',
      role: UserRole.admin,
    ),
    User(
      id: '2',
      name: 'João Gerente',
      email: 'gerente@empresa.com',
      password: 'gerente123',
      role: UserRole.gerente,
    ),
    User(
      id: '3',
      name: 'Maria Funcionária',
      email: 'funcionario@empresa.com',
      password: 'func123',
      role: UserRole.funcionario,
    ),
  ];

  /// Lista de registros de ponto
  final List<TimeRecord> timeRecords = [];

  /// Contador para gerar IDs únicos
  int _userIdCounter = 4;
  int _recordIdCounter = 1;

  /// Autentica um usuário
  User? login(String email, String password) {
    try {
      final user = users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Faz logout do usuário atual
  void logout() {
    currentUser = null;
  }

  /// Adiciona um novo usuário
  User addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    final user = User(
      id: (_userIdCounter++).toString(),
      name: name,
      email: email,
      password: password,
      role: role,
    );
    users.add(user);
    return user;
  }

  /// Atualiza um usuário existente
  void updateUser(User updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
    }
  }

  /// Remove um usuário
  void deleteUser(String userId) {
    users.removeWhere((u) => u.id == userId);
    timeRecords.removeWhere((r) => r.userId == userId);
  }

  /// Inicia um novo período (trabalho ou pausa)
  TimeRecord startPeriod({
    required String userId,
    required RecordType type,
  }) {
    final record = TimeRecord(
      id: (_recordIdCounter++).toString(),
      userId: userId,
      startTime: DateTime.now(),
      type: type,
    );
    timeRecords.add(record);
    return record;
  }

  /// Encerra o período ativo atual (trabalho ou pausa)
  TimeRecord? stopActivePeriod({
    required String userId,
    required RecordType type,
  }) {
    // Encontra o registro ativo do tipo especificado
    final activeRecord = timeRecords.firstWhere(
      (r) => r.userId == userId && r.type == type && r.isActive,
      orElse: () => throw Exception('Nenhum período ativo encontrado'),
    );

    // Atualiza o registro com o horário de término
    final updatedRecord = activeRecord.copyWith(
      endTime: DateTime.now(),
    );

    // Substitui o registro antigo pelo atualizado
    final index = timeRecords.indexOf(activeRecord);
    timeRecords[index] = updatedRecord;

    return updatedRecord;
  }

  /// Verifica se há um período ativo para o usuário
  bool hasActivePeriod({
    required String userId,
    required RecordType type,
  }) {
    return timeRecords.any(
      (r) => r.userId == userId && r.type == type && r.isActive,
    );
  }

  /// Obtém o registro ativo atual (se houver)
  TimeRecord? getActivePeriod({
    required String userId,
    required RecordType type,
  }) {
    try {
      return timeRecords.firstWhere(
        (r) => r.userId == userId && r.type == type && r.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtém registros de um usuário específico
  List<TimeRecord> getUserRecords(String userId) {
    return timeRecords.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Obtém todos os registros (ordenados por data)
  List<TimeRecord> getAllRecords() {
    return List.from(timeRecords)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Calcula o resumo diário para um usuário em uma data específica
  DailySummary getDailySummary(String userId, DateTime date) {
    // Filtra registros do usuário na data especificada
    final dayRecords = timeRecords.where((r) {
      return r.userId == userId &&
          r.startTime.year == date.year &&
          r.startTime.month == date.month &&
          r.startTime.day == date.day;
    }).toList();

    double totalWorkHours = 0;
    double totalBreakHours = 0;

    // Calcula total de horas por tipo
    for (final record in dayRecords) {
      // Ignora registros ainda ativos para o cálculo
      if (!record.isActive) {
        if (record.type == RecordType.trabalho) {
          totalWorkHours += record.durationInHours;
        } else {
          totalBreakHours += record.durationInHours;
        }
      }
    }

    // Calcula horas líquidas (trabalho - pausa)
    final netWorkHours = totalWorkHours - totalBreakHours;

    return DailySummary(
      userId: userId,
      date: date,
      totalWorkHours: totalWorkHours,
      totalBreakHours: totalBreakHours,
      netWorkHours: netWorkHours,
    );
  }

  /// Obtém lista de todos os funcionários
  List<User> getEmployees() {
    return users.where((u) => u.role == UserRole.funcionario).toList();
  }

  /// Verifica se o usuário atual tem permissão de admin ou gerente
  bool get isAdminOrManager {
    return currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.gerente;
  }

  /// Verifica se o usuário atual é admin
  bool get isAdmin {
    return currentUser?.role == UserRole.admin;
  }
}
