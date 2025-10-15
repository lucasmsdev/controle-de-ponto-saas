/// Modelo de dados para representar um registro de ponto (start/stop)
class TimeRecord {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime; // null = ainda em andamento
  final String type; // trabalho ou pausa (string do banco)

  TimeRecord({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.type,
  });
  
  /// Converte o tipo String para enum RecordType
  RecordType get recordType {
    return type == 'trabalho' ? RecordType.trabalho : RecordType.pausa;
  }

  /// Verifica se o registro ainda está em andamento
  bool get isActive => endTime == null;

  /// Calcula a duração do registro em minutos
  int get durationInMinutes {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMinutes;
    }
    return endTime!.difference(startTime).inMinutes;
  }

  /// Calcula a duração do registro em horas (decimal)
  double get durationInHours {
    return durationInMinutes / 60.0;
  }

  /// Cria uma cópia do registro com campos atualizados
  TimeRecord copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
  }) {
    return TimeRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
    );
  }
}

/// Tipos de registro de ponto
enum RecordType {
  trabalho, // Período de trabalho
  pausa, // Período de break/pausa
}

/// Extensão para obter o nome legível do tipo de registro
extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.trabalho:
        return 'Trabalho';
      case RecordType.pausa:
        return 'Pausa';
    }
  }
}

/// Classe para representar o resumo diário de um usuário
class DailySummary {
  final String userId;
  final DateTime date;
  final double totalWorkHours; // Total de horas trabalhadas
  final double totalBreakHours; // Total de horas de pausa
  final double netWorkHours; // Horas líquidas (trabalho - pausa)

  DailySummary({
    required this.userId,
    required this.date,
    required this.totalWorkHours,
    required this.totalBreakHours,
    required this.netWorkHours,
  });

  /// Formata as horas em string (ex: "8.5" -> "8h 30min")
  static String formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}min';
  }
}
