import 'package:cloud_firestore/cloud_firestore.dart';

class SellerModel {
  String sellerId;
  String name;
  String email;
  double commissionRate;
  Timestamp createdAt;
  List<String> contracts;
  List<String> clients;

  SellerModel({
    required this.sellerId,
    required this.name,
    required this.email,
    required this.commissionRate,
    required this.createdAt,
    required this.contracts,
    required this.clients,
  });

  // Converter dados Firestore para objeto SellerModel
  factory SellerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SellerModel(
      sellerId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      commissionRate: data['commissionRate']?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      contracts: List<String>.from(data['contracts'] ?? []),
      clients: List<String>.from(data['clients'] ?? []),
    );
  }

  // Converter objeto SellerModel para mapa de dados para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'commissionRate': commissionRate,
      'createdAt': createdAt,
      'contracts': contracts,
      'clients': clients,
    };
  }
}
