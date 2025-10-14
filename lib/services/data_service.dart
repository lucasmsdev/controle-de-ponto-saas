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

  /// Adiciona um registro de ponto
  TimeRecord addTimeRecord({
    required String userId,
    required DateTime timestamp,
    required RecordType type,
    String? photoPath,
    bool isManual = false,
  }) {
    final record = TimeRecord(
      id: (_recordIdCounter++).toString(),
      userId: userId,
      timestamp: timestamp,
      type: type,
      photoPath: photoPath,
      isManual: isManual,
    );
    timeRecords.add(record);
    return record;
  }

  /// Obtém registros de um usuário específico
  List<TimeRecord> getUserRecords(String userId) {
    return timeRecords.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Obtém todos os registros (ordenados por data)
  List<TimeRecord> getAllRecords() {
    return List.from(timeRecords)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
