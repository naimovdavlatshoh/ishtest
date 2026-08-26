class UserMe {
  final int id;
  final String? email;
  final String phone;
  final String? firstName;
  final String? lastName;
  final dynamic telegramId;

  UserMe({
    required this.id,
    this.email,
    required this.phone,
    this.firstName,
    this.lastName,
    this.telegramId,
  });

  factory UserMe.fromJson(Map<String, dynamic> json) {
    return UserMe(
      id: json['id'] as int,
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      telegramId: json['telegram_id'],
    );
  }
}
