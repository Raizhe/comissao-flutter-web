import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comissao_flutter_web/data/models/customer_success_model.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/costumer_success_repository.dart';

class CustomerSuccessController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final TextEditingController createdAtController = TextEditingController(
    text: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
  );

  final CustomerSuccessRepository customerSuccessRepository =
  CustomerSuccessRepository();

  Future<void> addCustomerSuccess() async {
    try {
      String uid = FirebaseFirestore.instance.collection('customerSuccess').doc().id;
      CustomerSuccessModel newCustomerSuccess = CustomerSuccessModel(
        customerSuccessId: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        createdAt: Timestamp.now(),
      );

      await customerSuccessRepository.addCustomerSuccess(newCustomerSuccess);
      Get.back();
      Get.snackbar('Sucesso', 'Customer Success cadastrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao cadastrar Customer Success: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
