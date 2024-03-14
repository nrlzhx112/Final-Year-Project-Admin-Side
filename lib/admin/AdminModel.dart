import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  user,
  moderator,
}

class AdminModel {
  final String adminId;
  final String? username;
  final String email;
  final String? bio;
  final DateTime? birthdate;
  final bool isOnline;
  final UserRole role;

  AdminModel({
    required this.adminId,
    this.username,
    required this.email,
    this.bio,
    this.birthdate,
    required this.isOnline,
    required this.role,
  });

  // Factory constructor to create a UserModel from Firestore DocumentSnapshot
  factory AdminModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    return AdminModel(
      adminId: doc.id,
      username: data?['username'] as String?,
      email: data?['email'] as String,
      bio: data?['bio'] as String?,
      birthdate: data?['birthdate'] is Timestamp
          ? (data?['birthdate'] as Timestamp).toDate()
          : null,
      isOnline: data?['isOnline'] as bool? ?? false,
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${data?['role']}',
        orElse: () => UserRole.user,
      ),
    );
  }

  // Factory constructor to create a UserModel from a JSON map
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      adminId: json['adminId'] as String,
      username: json['username'] as String?,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'] as String)
          : null,
      isOnline: json['isOnline'] as bool,
      role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.user,
      ),
    );
  }

  // Convert UserModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'username': username,
      'email': email,
      'bio': bio,
      'birthdate': birthdate?.toIso8601String(),
      'isOnline': isOnline,
      'role': role.toString().split('.').last,
    };
  }
}
