import 'package:cloud_firestore/cloud_firestore.dart';

class MeetModel {
  String meetId;
  String leadId; // ID do lead vinculado à reunião
  DateTime dataAgendamento;
  DateTime? dataMeet; // Data da reunião, consistente com Firestore
  String status; // Sim, Não, Remarcada

  MeetModel({
    required this.meetId,
    required this.leadId,
    required this.dataAgendamento,
    this.dataMeet,
    required this.status,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'meetId': meetId,
      'leadId': leadId,
      'dataAgendamento': dataAgendamento,
      'dataMeet': dataMeet, // Nome consistente com o Firestore
      'status': status,
    };
  }

  // Converter JSON para MeetModel
  factory MeetModel.fromJson(Map<String, dynamic> json) {
    return MeetModel(
      meetId: json['meetId'],
      leadId: json['leadId'],
      dataAgendamento: (json['dataAgendamento'] as Timestamp).toDate(),
      dataMeet: json['dataMeet'] != null
          ? (json['dataMeet'] as Timestamp).toDate()
          : null,
      status: json['status'],
    );
  }
}
