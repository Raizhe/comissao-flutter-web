// lib/data/repositories/contract_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contract_model.dart';

class ContractRepository {
  final CollectionReference contractsCollection = FirebaseFirestore.instance.collection('contracts');

  // Adicionar um novo contrato ao Firestore
  Future<void> addContract(ContractModel contract) async {
    try {
      await contractsCollection.doc(contract.contractId).set(contract.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar contrato: $e');
    }
  }

  // Buscar um contrato por ID
  Future<ContractModel?> getContractById(String contractId) async {
    try {
      DocumentSnapshot doc = await contractsCollection.doc(contractId).get();
      if (doc.exists) {
        return ContractModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar contrato: $e');
    }
  }
}
