class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? username;
  final String? phoneNumber;
  final String? profilePhoto;
  final DateTime? usernameChangedAt;
  final DateTime? phoneChangedAt;
  final int? dosenId;
  final DateTime? dosenSelectedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username,
    this.phoneNumber,
    this.profilePhoto,
    this.usernameChangedAt,
    this.phoneChangedAt,
    this.dosenId,
    this.dosenSelectedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      profilePhoto: json['profile_photo'],
      usernameChangedAt: json['username_changed_at'] != null ? DateTime.parse(json['username_changed_at']) : null,
      phoneChangedAt: json['phone_changed_at'] != null ? DateTime.parse(json['phone_changed_at']) : null,
      dosenId: json['dosen_id'],
      dosenSelectedAt: json['dosen_selected_at'] != null ? DateTime.parse(json['dosen_selected_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'username': username,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
      'username_changed_at': usernameChangedAt?.toIso8601String(),
      'phone_changed_at': phoneChangedAt?.toIso8601String(),
      'dosen_id': dosenId,
      'dosen_selected_at': dosenSelectedAt?.toIso8601String(),
    };
  }
}