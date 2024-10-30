import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSuccessModel {
  String customerSuccessId;
  String name;
  String email;
  Timestamp createdAt;

  CustomerSuccessModel({
    required this.customerSuccessId,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // Função para converter dados do Firestore para objeto CustomerSuccessModel
  factory CustomerSuccessModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CustomerSuccessModel(
      customerSuccessId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Função para converter objeto CustomerSuccessModel em mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
