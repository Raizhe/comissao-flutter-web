import 'package:comissao_flutter_web/data/models/pre_seller_model.dart';
import 'package:comissao_flutter_web/data/repositories/pre_seller_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class PreSellerController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final commissionRateController = TextEditingController();
  final preSellerRepository = PreSellerRepository();

  Future<void> addPreSeller() async {
    try {
      String preSellerId = const Uuid().v4();
      PreSellerModel preSeller = PreSellerModel(
        preSellerId: preSellerId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        comissao: double.parse(commissionRateController.text.trim()),
        createdAt: DateTime.now(),
      );
      await preSellerRepository.addPreSeller(preSeller);
      Get.back(); // Voltar para a página anterior
      Get.snackbar('Sucesso', 'Pré-vendedor cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar pré-vendedor: $e');
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
