/// Modelo de dados para representar um usuário do sistema
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  /// Cria uma cópia do usuário com campos atualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}

/// Tipos de usuário do sistema
enum UserRole {
  admin,
  gerente,
  funcionario,
}

/// Extensão para obter o nome legível do tipo de usuário
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.gerente:
        return 'Gerente';
      case UserRole.funcionario:
        return 'Funcionário';
    }
  }
}
