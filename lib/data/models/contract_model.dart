// lib/data/models/contract_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String contractId;
  final String clientCNPJ; // Substituindo clientId por clientCNPJ
  final String clientName;
  final String sellerId;
  final String type;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final int installments;
  final String renewalType;
  final String salesOrigin;

  ContractModel({
    required this.contractId,
    required this.clientCNPJ,
    required this.clientName,
    required this.sellerId,
    required this.type,
    required this.amount,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    required this.installments,
    required this.renewalType,
    required this.salesOrigin,
  });

  // Método para converter de Firestore para ContractModel
  factory ContractModel.fromFirestore(Map<String, dynamic> data) {
    return ContractModel(
      contractId: data['contractId'] ?? '',
      clientCNPJ: data['clientCNPJ'] ?? '',
      clientName: data['clientName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? '',
      installments: (data['installments'] as num).toInt(),
      renewalType: data['renewalType'] ?? '',
      salesOrigin: data['salesOrigin'] ?? '',
    );
  }

  // Método para converter ContractModel para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'contractId': contractId,
      'clientCNPJ': clientCNPJ,
      'clientName': clientName,
      'sellerId': sellerId,
      'type': type,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod,
      'installments': installments,
      'renewalType': renewalType,
      'salesOrigin': salesOrigin,
    };
  }
}
