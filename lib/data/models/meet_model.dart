import 'package:cloud_firestore/cloud_firestore.dart';

class MeetModel {
  String name;
  String meetId;
  String leadId;
  DateTime dataAgendamento;
  DateTime? dataMeet;
  String status;

  MeetModel({
    required this.name,
    required this.meetId,
    required this.leadId,
    required this.dataAgendamento,
    this.dataMeet,
    required this.status,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'meetId': meetId,
      'leadId': leadId,
      'dataAgendamento': dataAgendamento,
      'dataMeet': dataMeet,
      'status': status,
    };
  }

  // Converter JSON para MeetModel
  factory MeetModel.fromJson(Map<String, dynamic> json) {
    return MeetModel(
      name: json['name'] ?? 'Nome não disponível',
      meetId: json['meetId'] ?? '',
      leadId: json['leadId'] ?? '',
      dataAgendamento: (json['dataAgendamento'] as Timestamp).toDate(),
      dataMeet: json['dataMeet'] != null
          ? (json['dataMeet'] as Timestamp).toDate()
          : null,
      status: json['status'] ?? 'Não',
    );
  }
}
