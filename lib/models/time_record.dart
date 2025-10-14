/// Modelo de dados para representar um registro de ponto
class TimeRecord {
  final String id;
  final String userId;
  final DateTime timestamp;
  final RecordType type;
  final String? photoPath;
  final bool isManual;

  TimeRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    this.photoPath,
    this.isManual = false,
  });

  /// Cria uma cópia do registro com campos atualizados
  TimeRecord copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    RecordType? type,
    String? photoPath,
    bool? isManual,
  }) {
    return TimeRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      photoPath: photoPath ?? this.photoPath,
      isManual: isManual ?? this.isManual,
    );
  }
}

/// Tipos de registro de ponto
enum RecordType {
  entrada,
  saida,
  inicioPausa,
  fimPausa,
}

/// Extensão para obter o nome legível do tipo de registro
extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.entrada:
        return 'Entrada';
      case RecordType.saida:
        return 'Saída';
      case RecordType.inicioPausa:
        return 'Início Pausa';
      case RecordType.fimPausa:
        return 'Fim Pausa';
    }
  }
}
