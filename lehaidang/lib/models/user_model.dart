/// User Roles
enum UserRole {
  admin, // 16 permissions
  manager, // 9 permissions
  user; // 5 permissions

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'User';
    }
  }
}

class User {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final bool isAdmin; // Kept for backward compatibility
  final UserRole role;
  final bool twoFactorEnabled;
  final String? twoFactorSecret;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.isAdmin = false,
    UserRole? role,
    this.twoFactorEnabled = false,
    this.twoFactorSecret,
    DateTime? createdAt,
  }) : role = role ?? (isAdmin ? UserRole.admin : UserRole.user),
       createdAt = createdAt ?? DateTime.now();

  bool get isManager => role == UserRole.manager;
  bool get isAdminRole => role == UserRole.admin;

  // Convert User to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'isAdmin': isAdmin,
      'role': role.name,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorSecret': twoFactorSecret,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      role: _roleFromString(map['role']),
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      twoFactorSecret: map['twoFactorSecret'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  static UserRole _roleFromString(String? roleStr) {
    if (roleStr == null) return UserRole.user;
    try {
      return UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.user,
      );
    } catch (e) {
      return UserRole.user;
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    bool? isAdmin,
    UserRole? role,
    bool? twoFactorEnabled,
    String? twoFactorSecret,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
