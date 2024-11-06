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
  int? codigoProduto;
  String? nomeProduto;
  String? valorUnitario;
  int? quantidade;
  int? ncm;
  int? natureza;
  int? codigoVenda;
  int? dataVenda;
  int? dataRetroativa;
  DateTime? dataVencimentoPagamento; // Novo campo para data de vencimento
  List<String> contracts;
  DateTime registeredAt;
  String situation;
  bool reminderAcknowledged; // Novo campo para controle de lembretes

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
    this.codigoProduto,
    this.nomeProduto,
    this.valorUnitario,
    this.quantidade,
    this.ncm,
    this.natureza,
    this.codigoVenda,
    this.dataVenda,
    this.dataRetroativa,
    this.dataVencimentoPagamento, // Inicializando o novo campo
    required this.contracts,
    required this.registeredAt,
    required this.situation,
    this.reminderAcknowledged = false, // Inicializa como falso por padrão
  });

  // Construtor vazio para evitar erros nulos
  factory ClientModel.empty() {
    return ClientModel(
      clientId: '',
      nome: '',
      cpfcnpj: '',
      contracts: [],
      registeredAt: DateTime.now(),
      situation: 'Indefinido',
      reminderAcknowledged: false,
    );
  }

  // Conversão para JSON
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'nome': nome,
      'cpfcnpj': cpfcnpj,
      'inscricaoEstadual': inscricaoEstadual,
      'email': email,
      'telefone': telefone,
      'rua': rua,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'pais': pais,
      'codigoProduto': codigoProduto,
      'nomeProduto': nomeProduto,
      'valorUnitario': valorUnitario,
      'quantidade': quantidade,
      'ncm': ncm,
      'natureza': natureza,
      'codigoVenda': codigoVenda,
      'dataVenda': dataVenda,
      'dataRetroativa': dataRetroativa,
      'dataVencimentoPagamento': dataVencimentoPagamento != null
          ? Timestamp.fromDate(dataVencimentoPagamento!)
          : null, // Salvando a data de vencimento como Timestamp
      'contracts': contracts,
      'registeredAt': registeredAt,
      'situation': situation,
      'reminderAcknowledged': reminderAcknowledged, // Adicionando campo ao JSON
    };
  }

  // Conversão de JSON para ClientModel
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['clientId'] ?? '',
      nome: json['nome'] ?? '',
      cpfcnpj: json['cpfcnpj'] ?? '',
      inscricaoEstadual: json['inscricaoEstadual'],
      email: json['email'],
      telefone: json['telefone'],
      rua: json['rua'],
      numero: json['numero'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      pais: json['pais'],
      codigoProduto: json['codigoProduto'],
      nomeProduto: json['nomeProduto'],
      valorUnitario: json['valorUnitario'],
      quantidade: json['quantidade'],
      ncm: json['ncm'],
      natureza: json['natureza'],
      codigoVenda: json['codigoVenda'],
      dataVenda: json['dataVenda'],
      dataRetroativa: json['dataRetroativa'],
      dataVencimentoPagamento: json['dataVencimentoPagamento'] != null
          ? (json['dataVencimentoPagamento'] as Timestamp).toDate()
          : null, // Convertendo Timestamp para DateTime
      contracts: List<String>.from(json['contracts'] ?? []),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      situation: json['situation'] ?? 'Indefinido',
      reminderAcknowledged: json['reminderAcknowledged'] ?? false, // Define como falso se estiver ausente
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
