// lib/data/models/contract_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String contractId;
  final String clientId;
  final String clientName;
  final String sellerId;
  final String preSellerId;
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
  final String preSalesOrigin;
  // final String contractCS;
  // final String projectManager;

  ContractModel({
    required this.contractId,
    required this.clientId,
    required this.clientName,
    required this.sellerId,
    required this.preSellerId,
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
    required this.preSalesOrigin,
    // required this.contractCS,
    // required this.projectManager,
  });

  // Método para converter de Firestore para ContractModel
  factory ContractModel.fromFirestore(Map<String, dynamic> data) {
    return ContractModel(
      contractId: data['contractId'],
      clientId: data['clientId'],
      clientName: data['clientName'],
      sellerId: data['sellerId'],
      preSellerId: data['preSellerId'],
      type: data['type'],
      amount: data['amount'].toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'],
      installments: data['installments'],
      renewalType: data['renewalType'],
      salesOrigin: data['salesOrigin'],
      preSalesOrigin: data['preSalesOrigin'],
      // contractCS: data['contractCS'],
      // projectManager: data['projectManager'],
    );
  }

  // Método para converter ContractModel para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'contractId': contractId,
      'clientId': clientId,
      'clientName': clientName,
      'sellerId': sellerId,
      'preSellerId': preSellerId,
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
      'preSalesOrigin': preSalesOrigin,
      // 'contractCS': contractCS,
      // 'projectManager': projectManager,
    };
  }
}
