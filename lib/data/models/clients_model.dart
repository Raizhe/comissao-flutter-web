import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  String clientId;
  String clientName;
  String companyName; // Razão Social
  String? clientEmail;
  String? phone;
  String? cellPhone;
  String? website;
  String? address;
  String? stateInscription;
  String? municipalInscription;
  String? projectModel;
  String? preSellerId;
  String? sellerId;
  List<String> contracts;
  DateTime registeredAt;
  String situation; // Situação (Ativo, Em Prospecção, Inativo)
  String? group; // Grupo de Clientes (novo campo)
  String? cnpj;
  String? cpf;

  ClientModel({
    required this.clientId,
    required this.clientName,
    required this.companyName,
    this.clientEmail,
    this.phone,
    this.cellPhone,
    this.website,
    this.address,
    this.stateInscription,
    this.municipalInscription,
    this.projectModel,
    this.preSellerId,
    this.sellerId,
    required this.contracts,
    required this.registeredAt,
    required this.situation,
    this.group,
    this.cnpj,
    this.cpf,
  });

  // Converter um ClientModel para JSON (para enviar ao Firestore)
  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'companyName': companyName,
      'clientEmail': clientEmail,
      'phone': phone,
      'cellPhone': cellPhone,
      'website': website,
      'address': address,
      'stateInscription': stateInscription,
      'municipalInscription': municipalInscription,
      'projectModel': projectModel,
      'preSellerId': preSellerId,
      'sellerId': sellerId,
      'contracts': contracts,
      'registeredAt': registeredAt,
      'situation': situation,
      'group': group,
      'cnpj': cnpj,
      'cpf': cpf,
    };
  }

  // Converter JSON para um ClientModel (para ler do Firestore)
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      companyName: json['companyName'] ?? '',
      clientEmail: json['clientEmail'],
      phone: json['phone'],
      cellPhone: json['cellPhone'],
      website: json['website'],
      address: json['address'],
      stateInscription: json['stateInscription'],
      municipalInscription: json['municipalInscription'],
      projectModel: json['projectModel'],
      preSellerId: json['preSellerId'],
      sellerId: json['sellerId'],
      contracts: List<String>.from(json['contracts'] ?? []),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      situation: json['situation'] ?? 'Indefinido',
      group: json['group'],
      cnpj: json['cnpj'],
      cpf: json['cpf'],
    );
  }
}
