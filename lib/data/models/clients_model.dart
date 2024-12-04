import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  String clientId;
  String nome;
  String cpfcnpj;
  String? inscricaoEstadual;
  String? email;
  String? telefone;
  String? rua;
  String? numero;
  String? complemento;
  String? bairro;
  String? cidade;
  String? estado;
  String? cep;
  String? pais;
  int? codigoVenda;
  int? dataVenda;
  int? dataRetroativa;
  DateTime? dataVencimentoPagamento;
  List<String> contracts;
  DateTime registeredAt;
  String status;
  bool reminderAcknowledged;

  ClientModel({
    required this.clientId,
    required this.nome,
    required this.cpfcnpj,
    this.inscricaoEstadual,
    this.email,
    this.telefone,
    this.rua,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.pais,
    this.codigoVenda,
    this.dataVenda,
    this.dataRetroativa,
    this.dataVencimentoPagamento,
    required this.contracts,
    required this.registeredAt,
    required this.status,
    this.reminderAcknowledged = false,
  });

  // Construtor vazio para evitar erros nulos
  factory ClientModel.empty() {
    return ClientModel(
      clientId: '',
      nome: 'Sem Nome',
      cpfcnpj: 'N/A',
      contracts: [],
      registeredAt: DateTime.now(),
      status: 'Indefinido',
      reminderAcknowledged: false,
    );
  }

  // Conversão para JSON
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'nome': nome,
      'cpfcnpj': cpfcnpj,
      'inscricaoEstadual': inscricaoEstadual ?? '',
      'email': email ?? '',
      'telefone': telefone ?? '',
      'rua': rua ?? '',
      'numero': numero ?? '',
      'complemento': complemento ?? '',
      'bairro': bairro ?? '',
      'cidade': cidade ?? '',
      'estado': estado ?? '',
      'cep': cep ?? '',
      'pais': pais ?? '',
      'codigoVenda': codigoVenda ?? 0,
      'dataVenda': dataVenda ?? 0,
      'dataRetroativa': dataRetroativa ?? 0,
      'dataVencimentoPagamento': dataVencimentoPagamento != null
          ? Timestamp.fromDate(dataVencimentoPagamento!)
          : null,
      'contracts': contracts,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'status': status,
      'reminderAcknowledged': reminderAcknowledged,
    };
  }

  // Conversão de JSON para ClientModel
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['clientId'] ?? '',
      nome: json['nome'] ?? 'Sem Nome',
      cpfcnpj: json['cpfcnpj'] ?? 'N/A',
      inscricaoEstadual: json['inscricaoEstadual'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      rua: json['rua'] ?? '',
      numero: json['numero'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      cep: json['cep'] ?? '',
      pais: json['pais'] ?? '',
      dataVenda: json['dataVenda'] ?? 0,
      dataRetroativa: json['dataRetroativa'] ?? 0,
      dataVencimentoPagamento: json['dataVencimentoPagamento'] != null
          ? (json['dataVencimentoPagamento'] as Timestamp).toDate()
          : null,
      contracts: List<String>.from(json['contracts'] ?? []),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'Indefinido',
      reminderAcknowledged: json['reminderAcknowledged'] ?? false,
    );
  }

  // Método para gerar lembretes de pagamento
  List<DateTime> generatePaymentReminders() {
    if (dataVencimentoPagamento == null) return [];
    return [
      dataVencimentoPagamento!.subtract(const Duration(days: 5)),
      dataVencimentoPagamento!.subtract(const Duration(days: 2)),
      dataVencimentoPagamento!,
    ];
  }
}
