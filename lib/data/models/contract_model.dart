import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String contractId;
  final String clientCNPJ;
  final String clientName;
  final String sellerId;
  final String? operadorId; // Opcional
  final String preSellerId;
  final String type;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate; // Opcional
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final int installments;
  final String renewalType;
  final String salesOrigin;
  final String address;
  final String representanteLegal;
  final String cpfRepresentante;
  final String emailFinanceiro;
  final String telefone;
  final String observacoes;
  final double feeMensal;
  final String costumerSuccess;

  ContractModel({
    required this.contractId,
    required this.clientCNPJ,
    required this.clientName,
    required this.sellerId,
    this.operadorId, // Opcional
    required this.preSellerId,
    required this.type,
    required this.amount,
    required this.startDate,
    this.endDate, // Opcional
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    required this.installments,
    required this.renewalType,
    required this.salesOrigin,
    required this.address,
    required this.representanteLegal,
    required this.cpfRepresentante,
    required this.emailFinanceiro,
    required this.telefone,
    required this.observacoes,
    required this.feeMensal,
    required this.costumerSuccess,
  });

  /// Converte um documento Firestore para um objeto `ContractModel`
  factory ContractModel.fromFirestore(Map<String, dynamic> data) {
    return ContractModel(
      contractId: data['contractId'] ?? '',
      clientCNPJ: data['clientCNPJ'] ?? '',
      clientName: data['clientName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      operadorId: data['operadorId'],
      preSellerId: data['preSellerId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(), // Tratando valor nulo
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? '',
      installments: (data['installments'] ?? 0).toInt(), // Tratando valor nulo
      renewalType: data['renewalType'] ?? '',
      salesOrigin: data['salesOrigin'] ?? '',
      address: data['address'] ?? '',
      representanteLegal: data['representanteLegal'] ?? '',
      cpfRepresentante: data['cpfRepresentante'] ?? '',
      emailFinanceiro: data['emailFinanceiro'] ?? '',
      telefone: data['telefone'] ?? '',
      observacoes: data['observacoes'] ?? '',
      feeMensal: (data['feeMensal'] ?? 0).toDouble(), // Tratando valor nulo
      costumerSuccess: data['costumerSuccess'] ?? '', // Tratando valor nulo
    );
  }


  /// Converte o objeto `ContractModel` para um mapa compatível com Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'contractId': contractId,
      'clientCNPJ': clientCNPJ,
      'clientName': clientName,
      'sellerId': sellerId,
      'operadorId': operadorId,
      'preSellerId': preSellerId,
      'type': type,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod,
      'installments': installments,
      'renewalType': renewalType,
      'salesOrigin': salesOrigin,
      'address': address,
      'representanteLegal': representanteLegal,
      'cpfRepresentante': cpfRepresentante,
      'emailFinanceiro': emailFinanceiro,
      'telefone': telefone,
      'observacoes': observacoes,
      'feeMensal': feeMensal,
      'costumerSuccess': costumerSuccess,
    };
  }
}
