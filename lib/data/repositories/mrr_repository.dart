import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mrr_model.dart';

class MRRRepository {
  final CollectionReference _mrrCollection =
  FirebaseFirestore.instance.collection('mrr');

  // Adicionar um MRR ao Firestore
  Future<void> addMRR(MRRModel mrr) async {
    try {
      await _mrrCollection.add(mrr.toMap());
    } catch (e) {
      print('Erro ao adicionar MRR: $e');
    }
  }

  // Obter MRR pelo mês
  Future<MRRModel?> getMRRByMonth(String month) async {
    try {
      QuerySnapshot snapshot =
      await _mrrCollection.where('month', isEqualTo: month).get();
      if (snapshot.docs.isNotEmpty) {
        return MRRModel.fromDocument(snapshot.docs.first);
      }
    } catch (e) {
      print('Erro ao buscar MRR: $e');
    }
    return null;
  }
}
