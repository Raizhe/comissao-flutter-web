import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  double metaClosers;
  double metaMRR;
  double metaJob;
  Timestamp createdAt;

  GoalModel({
    required this.metaClosers,
    required this.metaMRR,
    required this.metaJob,
    required this.createdAt,
  });

  // Converter dados Firestore para objeto GoalModel
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      metaClosers: data['metaClosers']?.toDouble() ?? 0.0,
      metaMRR: data['metaMRR']?.toDouble() ?? 0.0,
      metaJob: data['metaJob']?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converter objeto GoalModel para Map (Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'metaClosers': metaClosers,
      'metaMRR': metaMRR,
      'metaJob': metaJob,
      'createdAt': createdAt,
    };
  }
}