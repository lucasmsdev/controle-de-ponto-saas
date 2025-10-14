import '../models/user.dart';
import '../models/time_record.dart';
import 'supabase_service.dart';

/// Serviço para gerenciar dados usando Supabase
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();
  
  final _supabaseService = SupabaseService();

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
  Future<bool> startPeriod({
    required String userId,
    required RecordType type,
  }) async {
    return await _supabaseService.startPeriod(userId, type.name);
  }

  /// Encerra o período ativo atual (trabalho ou pausa)
  Future<bool> stopActivePeriod({
    required String userId,
    required RecordType type,
  }) async {
    return await _supabaseService.stopActivePeriod(userId);
  }

  /// Verifica se há um período ativo para o usuário
  Future<bool> hasActivePeriod({
    required String userId,
    required RecordType type,
  }) async {
    final activeRecord = await _supabaseService.getActivePeriod(userId);
    return activeRecord != null && activeRecord.type == type.name;
  }

  /// Obtém o registro ativo atual (se houver)
  Future<TimeRecord?> getActivePeriod({
    required String userId,
    required RecordType type,
  }) async {
    final activeRecord = await _supabaseService.getActivePeriod(userId);
    if (activeRecord != null && activeRecord.type == type.name) {
      return activeRecord;
    }
    return null;
  }

  /// Obtém registros de um usuário específico (últimos 30 dias)
  Future<List<TimeRecord>> getUserRecords(String userId) async {
    return await _supabaseService.getRecordsLastDays(userId, 30);
  }

  /// Obtém todos os registros (últimos 30 dias, ordenados por data)
  Future<List<TimeRecord>> getAllRecords() async {
    return await _supabaseService.getAllRecordsLastDays(30);
  }

  /// Calcula o resumo diário para um usuário em uma data específica
  Future<DailySummary> getDailySummary(String userId, DateTime date) async {
    // Busca registros do Supabase para a data especificada
    final dayRecords = await _supabaseService.getRecordsForDate(userId, date);

    double totalWorkHours = 0;
    double totalBreakHours = 0;

    // Calcula total de horas por tipo
    for (final record in dayRecords) {
      // Ignora registros ainda ativos para o cálculo
      if (!record.isActive) {
        if (record.type == RecordType.trabalho.name) {
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

  /// Adiciona um registro manual (com horários específicos)
  Future<bool> addManualRecord({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required RecordType type,
  }) async {
    return await _supabaseService.addManualRecord(
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      type: type.name,
    );
  }

  /// Edita um registro existente
  Future<bool> updateRecord(TimeRecord updatedRecord) async {
    return await _supabaseService.updateRecord(updatedRecord);
  }

  /// Remove um registro
  Future<bool> deleteRecord(String recordId) async {
    return await _supabaseService.deleteRecord(recordId);
  }

  /// Verifica se o funcionário já fez lançamento manual hoje
  Future<bool> hasManualRecordToday(String userId) async {
    return await _supabaseService.hasManualRecordToday(userId);
  }

  /// Obtém registros dos últimos N dias
  List<TimeRecord> getRecordsLastDays(int days, {String? userId}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    var records = timeRecords.where((r) {
      return r.startTime.isAfter(cutoffDate);
    }).toList();
    
    if (userId != null) {
      records = records.where((r) => r.userId == userId).toList();
    }
    
    return records..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Verifica se um registro pode ser editado (últimos 30 dias)
  bool canEditRecord(TimeRecord record) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return record.startTime.isAfter(thirtyDaysAgo);
  }
}
