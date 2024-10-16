
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final double? commissionRate;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.commissionRate,
  });

  // Método para converter Firestore para UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      commissionRate: data['commissionRate']?.toDouble(),
    );
  }

  // Método para converter UserModel para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'commissionRate': commissionRate,
    };
  }
}
