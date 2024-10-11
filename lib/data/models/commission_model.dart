// lib/data/models/commission_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionModel {
  final String commissionId;
  final String userId;
  final String contractId;
  final String? preSaleId;
  final double amount;
  final double commissionRate;
  final DateTime calculatedAt;
  final String paymentStatus;

  CommissionModel({
    required this.commissionId,
    required this.userId,
    required this.contractId,
    this.preSaleId,
    required this.amount,
    required this.commissionRate,
    required this.calculatedAt,
    required this.paymentStatus,
  });

  // Método para converter de Firestore para CommissionModel
  factory CommissionModel.fromFirestore(Map<String, dynamic> data) {
    return CommissionModel(
      commissionId: data['commissionId'],
      userId: data['userId'],
      contractId: data['contractId'],
      preSaleId: data['preSaleId'],
      amount: data['amount'].toDouble(),
      commissionRate: data['commissionRate'].toDouble(),
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
      paymentStatus: data['paymentStatus'],
    );
  }

  // Método para converter CommissionModel para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'commissionId': commissionId,
      'userId': userId,
      'contractId': contractId,
      'preSaleId': preSaleId,
      'amount': amount,
      'commissionRate': commissionRate,
      'calculatedAt': calculatedAt,
      'paymentStatus': paymentStatus,
    };
  }
}
