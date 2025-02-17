import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pre_seller_model.dart';

class PreSellerRepository {
  final CollectionReference preSellersRef =
  FirebaseFirestore.instance.collection('pre_sellers');

  // Adicionar um novo pré-vendedor
  Future<void> addPreSeller(PreSellerModel preSeller) async {
    try {
      await preSellersRef.doc(preSeller.preSellerId).set(preSeller.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar pré-vendedor: $e');
    }
  }

  // Atualizar um pré-vendedor existente
  Future<void> updatePreSeller(PreSellerModel preSeller) async {
    try {
      await preSellersRef.doc(preSeller.preSellerId).update(preSeller.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar pré-vendedor: $e');
    }
  }

  // Obter um pré-vendedor pelo ID
  Future<PreSellerModel?> getPreSeller(String preSellerId) async {
    try {
      final doc = await preSellersRef.doc(preSellerId).get();
      if (doc.exists) {
        return PreSellerModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar pré-vendedor: $e');
    }
  }

  // Deletar um pré-vendedor
  Future<void> deletePreSeller(String preSellerId) async {
    try {
      await preSellersRef.doc(preSellerId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar pré-vendedor: $e');
    }
  }

  // Buscar todos os pré-vendedores
  Future<List<PreSellerModel>> getAllPreSellers() async {
    try {
      final snapshot = await preSellersRef.get();
      return snapshot.docs.map((doc) {
        return PreSellerModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar pré-vendedores: $e');
    }
  }
}
