import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../models/time_record.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  app_user.User? _currentUser;
  
  app_user.User? get currentUser => _currentUser;

  static Future<void> initialize() async {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      print('ERRO: Credenciais do Supabase não configuradas!');
      print('SUPABASE_URL: ${supabaseUrl.isEmpty ? "VAZIO" : "OK"}');
      print('SUPABASE_ANON_KEY: ${supabaseAnonKey.isEmpty ? "VAZIO" : "OK"}');
      throw Exception('Credenciais do Supabase não configuradas');
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('Supabase inicializado com sucesso');
    } catch (e) {
      print('ERRO ao inicializar Supabase: $e');
      rethrow;
    }
  }

  Future<app_user.User?> login(String email, String password) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('email', email.toLowerCase())
          .eq('password', password)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      _currentUser = app_user.User(
        id: response['id'].toString(),
        name: response['name'],
        email: response['email'],
        password: response['password'],
        role: _parseRole(response['role']),
      );

      return _currentUser;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required app_user.UserRole role,
  }) async {
    try {
      await client.from('users').insert({
        'name': name,
        'email': email.toLowerCase(),
        'password': password,
        'role': role.name,
      });

      return {'success': true, 'message': 'Usuário cadastrado com sucesso'};
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      
      final errorMessage = e.toString();
      if (errorMessage.contains('duplicate') || errorMessage.contains('unique')) {
        return {'success': false, 'message': 'Este email já está cadastrado'};
      }
      
      return {'success': false, 'message': 'Erro ao cadastrar usuário'};
    }
  }

  Future<List<app_user.User>> getUsers() async {
    try {
      final response = await client.from('users').select();

      return (response as List).map((userData) {
        return app_user.User(
          id: userData['id'].toString(),
          name: userData['name'],
          email: userData['email'],
          password: userData['password'],
          role: _parseRole(userData['role']),
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  Future<bool> updateUser(app_user.User user) async {
    try {
      await client.from('users').update({
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'role': user.role.name,
      }).eq('id', int.parse(user.id));

      return true;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await client.from('users').delete().eq('id', int.parse(userId));
      return true;
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      return false;
    }
  }

  Future<bool> startPeriod(String userId, String type) async {
    try {
      await client.from('time_records').insert({
        'user_id': int.parse(userId),
        'start_time': DateTime.now().toIso8601String(),
        'type': type,
        'is_manual': false,
      });

      return true;
    } catch (e) {
      print('Erro ao iniciar período: $e');
      return false;
    }
  }

  Future<bool> stopActivePeriod(String userId) async {
    try {
      final activeRecord = await getActivePeriod(userId);
      if (activeRecord == null) return false;

      await client.from('time_records').update({
        'end_time': DateTime.now().toIso8601String(),
      }).eq('id', int.parse(activeRecord.id));

      return true;
    } catch (e) {
      print('Erro ao parar período: $e');
      return false;
    }
  }

  Future<TimeRecord?> getActivePeriod(String userId) async {
    try {
      final response = await client
          .from('time_records')
          .select()
          .eq('user_id', int.parse(userId))
          .isFilter('end_time', null)
          .maybeSingle();

      if (response == null) return null;

      return TimeRecord(
        id: response['id'].toString(),
        userId: response['user_id'].toString(),
        startTime: DateTime.parse(response['start_time']),
        endTime: response['end_time'] != null 
            ? DateTime.parse(response['end_time']) 
            : null,
        type: response['type'],
      );
    } catch (e) {
      print('Erro ao buscar período ativo: $e');
      return null;
    }
  }

  Future<List<TimeRecord>> getRecordsForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await client
          .from('time_records')
          .select()
          .eq('user_id', int.parse(userId))
          .gte('start_time', startOfDay.toIso8601String())
          .lte('start_time', endOfDay.toIso8601String())
          .order('start_time');

      return (response as List).map((record) {
        return TimeRecord(
          id: record['id'].toString(),
          userId: record['user_id'].toString(),
          startTime: DateTime.parse(record['start_time']),
          endTime: record['end_time'] != null 
              ? DateTime.parse(record['end_time']) 
              : null,
          type: record['type'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar registros do dia: $e');
      return [];
    }
  }

  Future<List<TimeRecord>> getRecordsLastDays(String userId, int days) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final response = await client
          .from('time_records')
          .select()
          .eq('user_id', int.parse(userId))
          .gte('start_time', cutoffDate.toIso8601String())
          .order('start_time', ascending: false);

      return (response as List).map((record) {
        return TimeRecord(
          id: record['id'].toString(),
          userId: record['user_id'].toString(),
          startTime: DateTime.parse(record['start_time']),
          endTime: record['end_time'] != null 
              ? DateTime.parse(record['end_time']) 
              : null,
          type: record['type'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      return [];
    }
  }

  Future<List<TimeRecord>> getAllRecordsLastDays(int days) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final response = await client
          .from('time_records')
          .select()
          .gte('start_time', cutoffDate.toIso8601String())
          .order('start_time', ascending: false);

      return (response as List).map((record) {
        return TimeRecord(
          id: record['id'].toString(),
          userId: record['user_id'].toString(),
          startTime: DateTime.parse(record['start_time']),
          endTime: record['end_time'] != null 
              ? DateTime.parse(record['end_time']) 
              : null,
          type: record['type'],
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar todos os registros: $e');
      return [];
    }
  }

  Future<bool> addManualRecord({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required String type,
  }) async {
    try {
      print('🔍 DEBUG SupabaseService: Recebido type="$type"');
      final payload = {
        'user_id': int.parse(userId),
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'type': type,
        'is_manual': true,
      };
      print('🔍 DEBUG SupabaseService: Payload completo: $payload');
      
      await client.from('time_records').insert(payload);

      return true;
    } catch (e) {
      print('❌ Erro ao adicionar registro manual: $e');
      return false;
    }
  }

  Future<bool> updateRecord(TimeRecord record) async {
    try {
      await client.from('time_records').update({
        'start_time': record.startTime.toIso8601String(),
        'end_time': record.endTime?.toIso8601String(),
        'type': record.type,
      }).eq('id', int.parse(record.id));

      return true;
    } catch (e) {
      print('Erro ao atualizar registro: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId) async {
    try {
      await client.from('time_records').delete().eq('id', int.parse(recordId));
      return true;
    } catch (e) {
      print('Erro ao deletar registro: $e');
      return false;
    }
  }

  Future<bool> hasManualRecordToday(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final response = await client
          .from('time_records')
          .select('id')
          .eq('user_id', int.parse(userId))
          .eq('is_manual', true)
          .gte('start_time', startOfDay.toIso8601String())
          .lte('start_time', endOfDay.toIso8601String());

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Erro ao verificar registro manual: $e');
      return false;
    }
  }

  app_user.UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return app_user.UserRole.admin;
      case 'gerente':
        return app_user.UserRole.gerente;
      case 'funcionario':
        return app_user.UserRole.funcionario;
      default:
        return app_user.UserRole.funcionario;
    }
  }
}
