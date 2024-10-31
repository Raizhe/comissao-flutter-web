import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/operator_model.dart';

class OperatorRepository {
  final CollectionReference operatorCollection =
  FirebaseFirestore.instance.collection('operators');

  Future<void> addOperator(OperatorModel operator) async {
    await operatorCollection.doc(operator.operatorId).set(operator.toMap());
  }

  Future<List<OperatorModel>> getAllOperators() async {
    QuerySnapshot snapshot = await operatorCollection.get();
    return snapshot.docs
        .map((doc) => OperatorModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateOperator(String operatorId, Map<String, dynamic> data) async {
    await operatorCollection.doc(operatorId).update(data);
  }

  Future<void> deleteOperator(String operatorId) async {
    await operatorCollection.doc(operatorId).delete();
  }
}
