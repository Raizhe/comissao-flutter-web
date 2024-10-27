import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorModel {
  String operatorId;
  String name;
  String email;
  double commission;
  Timestamp createdAt;

  OperatorModel({
    required this.operatorId,
    required this.name,
    required this.email,
    required this.commission,
    required this.createdAt,
  });

  // Função para converter dados Firestore para objeto OperatorModel
  factory OperatorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return OperatorModel(
      operatorId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      commission: double.tryParse(data['commission'].toString()) ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Função para converter objeto OperatorModel em mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'commission': commission,
      'createdAt': createdAt,
    };
  }
}
