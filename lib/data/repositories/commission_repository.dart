// lib/data/repositories/commission_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commission_model.dart';

class CommissionRepository {
  final CollectionReference commissionsCollection = FirebaseFirestore.instance.collection('commissions');

  // Adicionar uma nova comissão ao Firestore
  Future<void> addCommission(CommissionModel commission) async {
    try {
      await commissionsCollection.doc(commission.commissionId).set(commission.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar comissão: $e');
    }
  }

  // Buscar uma comissão por ID
  Future<CommissionModel?> getCommissionById(String commissionId) async {
    try {
      DocumentSnapshot doc = await commissionsCollection.doc(commissionId).get();
      if (doc.exists) {
        return CommissionModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar comissão: $e');
    }
  }
}
