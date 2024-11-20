import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String contractId;
  final String clientCNPJ;
  final String clientName;
  final String sellerId;
  final String? operadorId;
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
  final String address;
  final String representanteLegal;
  final String cpfRepresentante;
  final String emailFinanceiro;
  final String telefone;
  final String observacoes;
  final double feeMensal;
  final String costumerSuccess;
  late final double commission; // Adicionar campo de comissão calculada

  ContractModel({
    required this.contractId,
    required this.clientCNPJ,
    required this.clientName,
    required this.sellerId,
    this.operadorId,
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
    required this.address,
    required this.representanteLegal,
    required this.cpfRepresentante,
    required this.emailFinanceiro,
    required this.telefone,
    required this.observacoes,
    required this.feeMensal,
    required this.costumerSuccess,
    required this.commission, // Novo campo
  });

  // Método para converter o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'clientCNPJ': clientCNPJ,
      'clientName': clientName,
      'sellerId': sellerId,
      'operadorId': operadorId,
      'preSellerId': preSellerId,
      'type': type,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
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
      'commission': commission,
    };
  }

  factory ContractModel.empty() {
    return ContractModel(
      contractId: '',
      clientCNPJ: '',
      clientName: '',
      sellerId: '',
      operadorId: null,
      preSellerId: '',
      type: '',
      amount: 0.0,
      startDate: DateTime.now(),
      endDate: null,
      status: 'INDEFINIDO',
      createdAt: DateTime.now(),
      paymentMethod: '',
      installments: 0,
      renewalType: '',
      salesOrigin: '',
      address: '',
      representanteLegal: '',
      cpfRepresentante: '',
      emailFinanceiro: '',
      telefone: '',
      observacoes: '',
      feeMensal: 0.0,
      costumerSuccess: '',
      commission: 0.0,
    );
  }


  // Método para criar o objeto a partir de JSON
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      contractId: json['contractId'] ?? '',
      clientCNPJ: json['clientCNPJ'] ?? '',
      clientName: json['clientName'] ?? '',
      sellerId: json['sellerId'] ?? '',
      operadorId: json['operadorId'],
      preSellerId: json['preSellerId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      paymentMethod: json['paymentMethod'] ?? '',
      installments: (json['installments'] ?? 0).toInt(),
      renewalType: json['renewalType'] ?? '',
      salesOrigin: json['salesOrigin'] ?? '',
      address: json['address'] ?? '',
      representanteLegal: json['representanteLegal'] ?? '',
      cpfRepresentante: json['cpfRepresentante'] ?? '',
      emailFinanceiro: json['emailFinanceiro'] ?? '',
      telefone: json['telefone'] ?? '',
      observacoes: json['observacoes'] ?? '',
      feeMensal: (json['feeMensal'] ?? 0).toDouble(),
      costumerSuccess: json['costumerSuccess'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
    );
  }
  // Lógica para calcular comissão baseada na forma de pagamento e outras regras
  double calculateCommission() {
    double commissionRate;

    if (paymentMethod == 'Cartão') {
      commissionRate = installments >= 8 ? 0.25 : 0.2;
    } else if (paymentMethod == 'Boleto') {
      commissionRate = installments >= 8 ? 0.15 : 0.12;
    } else {
      commissionRate = 0.10; // Débito e outros métodos
    }

    return amount * commissionRate;
  }

  factory ContractModel.fromFirestore(Map<String, dynamic> data) {
    return ContractModel(
      contractId: data['contractId'] ?? '',
      clientCNPJ: data['clientCNPJ'] ?? '',
      clientName: data['clientName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      operadorId: data['operadorId'],
      preSellerId: data['preSellerId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paymentMethod: data['paymentMethod'] ?? '',
      installments: (data['installments'] ?? 0).toInt(),
      renewalType: data['renewalType'] ?? '',
      salesOrigin: data['salesOrigin'] ?? '',
      address: data['address'] ?? '',
      representanteLegal: data['representanteLegal'] ?? '',
      cpfRepresentante: data['cpfRepresentante'] ?? '',
      emailFinanceiro: data['emailFinanceiro'] ?? '',
      telefone: data['telefone'] ?? '',
      observacoes: data['observacoes'] ?? '',
      feeMensal: (data['feeMensal'] ?? 0).toDouble(),
      costumerSuccess: data['costumerSuccess'] ?? '',
      commission: (data['commission'] ?? 0).toDouble(),
    );
  }

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
      'commission': commission, // Incluindo a comissão no Firestore
    };
  }
}
