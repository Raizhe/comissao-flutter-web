import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  String clientId;
  String clientName;
  String clientEmail;
  String phone;
  String address;
  String preSellerId;
  String sellerId;
  List<String> contracts;
  DateTime registeredAt;

  ClientModel({
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.phone,
    required this.address,
    required this.preSellerId,
    required this.sellerId,
    required this.contracts,
    required this.registeredAt,
  });

  // Converter um ClientModel para JSON (para enviar ao Firestore)
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'phone': phone,
      'address': address,
      'preSellerId': preSellerId,
      'sellerId': sellerId,
      'contracts': contracts,
      'registeredAt': registeredAt,
    };
  }

  // Converter JSON para um ClientModel (para ler do Firestore)
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      phone: json['phone'],
      address: json['address'],
      preSellerId: json['preSellerId'],
      sellerId: json['sellerId'],
      contracts: List<String>.from(json['contracts']),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
    );
  }
}
