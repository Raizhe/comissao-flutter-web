import 'package:cloud_firestore/cloud_firestore.dart';

class MRRModel {
  final String month;
  final double totalAmount;
  final int contractCount;
  final String sellerId;
  final double totalCommissions;

  MRRModel({
    required this.month,
    required this.totalAmount,
    required this.contractCount,
    required this.sellerId,
    required this.totalCommissions,
  });

  // Converter os dados de um documento Firestore para um MRRModel
  factory MRRModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MRRModel(
      month: data['month'] ?? '',
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      contractCount: data['contractCount'] ?? 0,
      sellerId: data['sellerId'] ?? '',
      totalCommissions: data['totalCommissions']?.toDouble() ?? 0.0,
    );
  }

  // Converter um MRRModel para um mapa de dados, que será enviado para o Firestore
  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'totalAmount': totalAmount,
      'contractCount': contractCount,
      'sellerId': sellerId,
      'totalCommissions': totalCommissions,
    };
  }
}
