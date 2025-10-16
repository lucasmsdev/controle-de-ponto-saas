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

  /// Lista de usuários do sistema (carregada do Supabase)
  List<User> users = [];

  /// Lista de registros de ponto
  final List<TimeRecord> timeRecords = [];

  /// Carrega todos os usuários do Supabase
  Future<void> loadUsers() async {
    users = await _supabaseService.getUsers();
  }

  /// Faz logout do usuário atual
  void logout() {
    currentUser = null;
    users.clear();
  }

  /// Adiciona um novo usuário (usando Supabase)
  Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final result = await _supabaseService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    
    // Recarrega lista de usuários se sucesso
    if (result['success']) {
      await loadUsers();
    }
    
    return result;
  }

  /// Atualiza um usuário existente (usando Supabase)
  Future<bool> updateUser(User updatedUser) async {
    final success = await _supabaseService.updateUser(updatedUser);
    
    // Recarrega lista de usuários se sucesso
    if (success) {
      await loadUsers();
    }
    
    return success;
  }

  /// Remove um usuário (usando Supabase)
  Future<bool> deleteUser(String userId) async {
    final success = await _supabaseService.deleteUser(userId);
    
    // Recarrega lista de usuários se sucesso
    if (success) {
      await loadUsers();
    }
    
    return success;
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

    print('🔍 DEBUG getDailySummary: processando ${dayRecords.length} registros');
    
    double totalWorkHours = 0;
    double totalBreakHours = 0;

    // Calcula total de horas por tipo
    for (final record in dayRecords) {
      // Ignora registros ainda ativos para o cálculo
      if (!record.isActive) {
        if (record.type == 'trabalho') {
          totalWorkHours += record.durationInHours;
          print('🔍   + Trabalho: ${record.durationInHours.toStringAsFixed(2)}h (total: ${totalWorkHours.toStringAsFixed(2)}h)');
        } else {
          totalBreakHours += record.durationInHours;
          print('🔍   + Pausa: ${record.durationInHours.toStringAsFixed(2)}h (total: ${totalBreakHours.toStringAsFixed(2)}h)');
        }
      } else {
        print('🔍   - Registro ativo (ignorado): tipo=${record.type}');
      }
    }

    // Calcula horas líquidas (trabalho - pausa)
    final netWorkHours = totalWorkHours - totalBreakHours;
    
    print('🔍 DEBUG Resultado: Trabalho=${totalWorkHours.toStringAsFixed(2)}h, Pausa=${totalBreakHours.toStringAsFixed(2)}h, Líquido=${netWorkHours.toStringAsFixed(2)}h');

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
    print('🔍 DEBUG DataService: Salvando registro manual tipo="${type.name}"');
    final result = await _supabaseService.addManualRecord(
      userId: userId,
      startTime: startTime,
      endTime: endTime,
      type: type.name,
    );
    print('🔍 DEBUG DataService: Resultado salvamento: $result');
    return result;
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
