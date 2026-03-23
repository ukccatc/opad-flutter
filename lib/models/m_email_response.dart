/// Email Response Model
/// Represents the response from email API endpoints
class EmailResponse {
  final bool success;
  final String message;
  final String? error;

  EmailResponse({required this.success, required this.message, this.error});

  factory EmailResponse.fromJson(Map<String, dynamic> json) {
    return EmailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? json['error'] ?? 'Unknown response',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'error': error};
  }

  @override
  String toString() => 'EmailResponse(success: $success, message: $message)';
}
