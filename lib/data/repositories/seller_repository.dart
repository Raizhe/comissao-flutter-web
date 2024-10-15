import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_model.dart';

class SellerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar um novo vendedor ao Firestore
  Future<void> addSeller(SellerModel seller) async {
    try {
      await _firestore.collection('sellers').doc(seller.sellerId).set(seller.toFirestore());
    } catch (e) {
      throw Exception('Erro ao adicionar vendedor: $e');
    }
  }

  // Atualizar dados de um vendedor existente
  Future<void> updateSeller(SellerModel seller) async {
    try {
      await _firestore.collection('sellers').doc(seller.sellerId).update(seller.toFirestore());
    } catch (e) {
      throw Exception('Erro ao atualizar vendedor: $e');
    }
  }

  // Buscar dados de um vendedor pelo ID
  Future<SellerModel> getSeller(String sellerId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('sellers').doc(sellerId).get();
      return SellerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar vendedor: $e');
    }
  }

  // Deletar um vendedor
  Future<void> deleteSeller(String sellerId) async {
    try {
      await _firestore.collection('sellers').doc(sellerId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar vendedor: $e');
    }
  }

  // Listar todos os vendedores
  Future<List<SellerModel>> getAllSellers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('sellers').get();
      return querySnapshot.docs.map((doc) => SellerModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erro ao listar vendedores: $e');
    }
  }
}
