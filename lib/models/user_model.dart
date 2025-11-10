class UserModel {
  final int? id;
  final String name;
  final String firstName;
  final int age;
  final String phone;
  final String email;
  final String password;
  final UserRole role;
  final int? coachId; // For clients, ID of their assigned coach
  final String? profileImagePath; // Path to profile image
  final DateTime? lastModified;
  final DateTime? createdAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.name,
    required this.firstName,
    required this.age,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    this.coachId,
    this.profileImagePath,
    this.lastModified,
    this.createdAt,
    this.isActive = true,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'age': age,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
      'coachId': coachId,
      'profileImagePath': profileImagePath,
      'lastModified': (lastModified ?? DateTime.now()).toIso8601String(),
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      firstName: map['firstName'] as String,
      age: map['age'] as int,
      phone: map['phone'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == map['role'],
      ),
      coachId: map['coachId'] as int?,
      profileImagePath: map['profileImagePath'] as String?,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      isActive: map['isActive'] == null ? true : (map['isActive'] as int) == 1,
    );
  }

  // CopyWith method for updates
  UserModel copyWith({
    int? id,
    String? name,
    String? firstName,
    int? age,
    String? phone,
    String? email,
    String? password,
    UserRole? role,
    int? coachId,
    String? profileImagePath,
    DateTime? lastModified,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      coachId: coachId ?? this.coachId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      lastModified: lastModified ?? this.lastModified,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get fullName => '$firstName $name';
}

enum UserRole { admin, coach, client }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.coach:
        return 'Coach';
      case UserRole.client:
        return 'Client';
    }
  }
}