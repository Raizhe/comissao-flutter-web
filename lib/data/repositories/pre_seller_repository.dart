import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pre_seller_model.dart';

class PreSellerRepository {
  final CollectionReference _preSellersCollection =
  FirebaseFirestore.instance.collection('pre_sellers');

  Future<void> addPreSeller(PreSellerModel preSeller) {
    return _preSellersCollection
        .doc(preSeller.preSellerId)
        .set(preSeller.toMap());
  }

  Future<PreSellerModel> getPreSellerById(String id) async {
    DocumentSnapshot doc = await _preSellersCollection.doc(id).get();
    return PreSellerModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
