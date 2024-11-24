// models/user.dart
class User {
  late final int id;
  late final String name;
  late final String username;
  late final String role;
  late final bool accountNonLocked;
  late final bool accountNonExpired;
  late final bool credentialsNonExpired;
  late final bool enabled;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.accountNonLocked,
    required this.accountNonExpired,
    required this.credentialsNonExpired,
    required this.enabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? -1,
      username: json['username'] ?? 'username',
      name: json['name'] ?? 'name',
      accountNonExpired: json['accountNonExpired'] ?? false,
      credentialsNonExpired: json['credentialsNonExpired'] ?? false,
      accountNonLocked: json['accountNonLocked'] ?? false,
      enabled: json['enabled'] ?? false,
      role: json['role'] ?? 'guest',
    );
  }
}
