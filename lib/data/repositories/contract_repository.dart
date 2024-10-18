import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract_model.dart';

class ContractRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar um novo contrato ao Firestore
  Future<void> addContract(ContractModel contract) async {
    try {
      await _firestore
          .collection('contracts')
          .doc(contract.contractId)
          .set(contract.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar contrato: $e');
    }
  }

  // Buscar todos os contratos do Firestore
  Future<List<ContractModel>> getAllContracts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('contracts').get();
      return snapshot.docs
          .map((doc) => ContractModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contratos: $e');
    }
  }

  // Deletar um contrato do Firestore
  Future<void> deleteContract(String contractId) async {
    try {
      await _firestore.collection('contracts').doc(contractId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar contrato: $e');
    }
  }

  // Atualizar um contrato existente no Firestore
  Future<void> updateContract(ContractModel contract) async {
    try {
      await _firestore
          .collection('contracts')
          .doc(contract.contractId)
          .update(contract.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar contrato: $e');
    }
  }
}
