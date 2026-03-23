/// Person Statistics Model based on Stats table structure
/// Table: Stats (Id, Email, Password, Член-профсоюза, ФИО, Общая сумма)
class PersonStats {
  final String id; // String ID from Stats table
  final String email;
  final String? passwordHash; // MD5 hash
  final bool isUnionMember; // Член-профсоюза (0/1)
  final String fullName; // ФИО - Full name in Russian
  final int totalAmount; // Общая сумма - Total amount
  final DateTime? lastUpdate;

  PersonStats({
    required this.id,
    required this.email,
    this.passwordHash,
    required this.isUnionMember,
    required this.fullName,
    required this.totalAmount,
    this.lastUpdate,
  });

  factory PersonStats.fromJson(Map<String, dynamic> json) {
    // Handle both English and Russian field names
    final unionMember = json['Член-профсоюза'] as String? ?? 
                       json['union_member'] as String? ?? 
                       json['is_union_member'] as String? ?? '0';
    final name = json['ФИО'] as String? ?? 
                 json['full_name'] as String? ?? 
                 json['name'] as String? ?? '';
    final amount = json['Общая сумма'] as int? ?? 
                   json['total_amount'] as int? ?? 
                   json['amount'] as int? ?? 0;

    return PersonStats(
      id: json['Id'] as String? ?? json['id'] as String? ?? '',
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      passwordHash: json['Password'] as String? ?? json['password'] as String?,
      isUnionMember: unionMember == '1' || unionMember == 'true',
      fullName: name,
      totalAmount: amount,
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Email': email,
      'Password': passwordHash,
      'Член-профсоюза': isUnionMember ? '1' : '0',
      'ФИО': fullName,
      'Общая сумма': totalAmount,
      'last_update': lastUpdate?.toIso8601String(),
    };
  }

  // Convenience getters for compatibility
  int get personId => int.tryParse(id) ?? 0;
  String get personName => fullName;
  String get login => email.split('@').first;

  // Stats map for UI display
  Map<String, dynamic> get stats {
    return {
      'total_amount': totalAmount,
      'is_union_member': isUnionMember,
      'full_name': fullName,
    };
  }
}
