import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SellerController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final commissionRateController = TextEditingController();
  final sellersRef = FirebaseFirestore.instance.collection('sellers');

  Future<void> addSeller() async {
    try {
      String sellerId = const Uuid().v4();
      await sellersRef.doc(sellerId).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'commissionRate': double.parse(commissionRateController.text.trim()),
        'createdAt': Timestamp.now(),
        'contracts': [],
        'clients': [],
      });
      Get.back(); // Voltar para a página anterior
      Get.snackbar('Sucesso', 'Vendedor cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar vendedor: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    commissionRateController.dispose();
    super.onClose();
  }
}
