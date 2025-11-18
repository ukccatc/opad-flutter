/// Person Account Model based on Users table structure
/// Table: Users (id, Email, Password, user_id)
class PersonAccount {
  final int id;
  final String email;
  final String? passwordHash; // MD5 hash, stored for authentication only
  final int userId; // WordPress user_id reference

  PersonAccount({
    required this.id,
    required this.email,
    this.passwordHash,
    required this.userId,
  });

  factory PersonAccount.fromJson(Map<String, dynamic> json) {
    return PersonAccount(
      id: json['id'] as int? ?? json['Id'] as int? ?? 0,
      email: json['Email'] as String? ?? json['email'] as String? ?? '',
      passwordHash: json['Password'] as String? ?? json['password'] as String?,
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Email': email,
      'Password': passwordHash,
      'user_id': userId,
    };
  }

  // Extract login from email (part before @)
  String get login {
    return email.split('@').first;
  }
}
