import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_success_model.dart';

class CustomerSuccessRepository {
  final CollectionReference customerSuccessCollection =
  FirebaseFirestore.instance.collection('customer_success');

  // Função para adicionar um Customer Success
  Future<void> addCustomerSuccess(CustomerSuccessModel customerSuccess) async {
    await customerSuccessCollection
        .doc(customerSuccess.customerSuccessId)
        .set(customerSuccess.toMap());
  }

  // Função para buscar todos os Customer Success
  Future<List<CustomerSuccessModel>> getAllCustomerSuccess() async {
    QuerySnapshot snapshot = await customerSuccessCollection.get();
    return snapshot.docs
        .map((doc) => CustomerSuccessModel.fromFirestore(doc))
        .toList();
  }

  // Função para atualizar um Customer Success
  Future<void> updateCustomerSuccess(
      String customerSuccessId, Map<String, dynamic> data) async {
    await customerSuccessCollection.doc(customerSuccessId).update(data);
  }

  // Função para deletar um Customer Success
  Future<void> deleteCustomerSuccess(String customerSuccessId) async {
    await customerSuccessCollection.doc(customerSuccessId).delete();
  }
}
