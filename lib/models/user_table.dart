class UserTable {
  final int? id;
  final String emailOrPhone;
  final String password;

  UserTable({this.id, required this.emailOrPhone, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailOrPhone': emailOrPhone,
      'password': password,
    };
  }

  factory UserTable.fromMap(Map<String, dynamic> map) {
    return UserTable(
      id: map['id'],
      emailOrPhone: map['emailOrPhone'],
      password: map['password'],
    );
  }
}
