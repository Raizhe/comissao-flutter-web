import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  String clientId;
  String clientName;
  String companyName; // Razão Social
  String clientEmail;
  String phone;
  String cellPhone;
  String website;
  String address;
  String stateInscription;
  String municipalInscription;
  String projectModel;
  String preSellerId;
  String sellerId;
  List<String> contracts;
  DateTime registeredAt;
  String situation; // Situação (Ativo, Em Prospecção, Inativo)
  String group; // Grupo de Clientes (novo campo)
  String cnpj;
  String cpf;

  ClientModel({
    required this.clientId,
    required this.clientName,
    required this.companyName,
    required this.clientEmail,
    required this.phone,
    required this.cellPhone,
    required this.website,
    required this.address,
    required this.stateInscription,
    required this.municipalInscription,
    required this.projectModel,
    required this.preSellerId,
    required this.sellerId,
    required this.contracts,
    required this.registeredAt,
    required this.situation,
    required this.group,
    required this.cnpj,
    required this.cpf,
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
      clientId: json['clientId'],
      clientName: json['clientName'],
      companyName: json['companyName'],
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
      contracts: List<String>.from(json['contracts']),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      situation: json['situation'],
      group: json['group'],
      cnpj: json['cnpj'],
      cpf: json['cpf'],
    );
  }
}
