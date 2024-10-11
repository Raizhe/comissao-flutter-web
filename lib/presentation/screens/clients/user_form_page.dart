// lib/presentation/screens/users/user_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({Key? key}) : super(key: key);

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  final _commissionRateController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  Future<void> _addUser() async {
    try {
      String uid = FirebaseFirestore.instance.collection('users').doc().id; // Gerar UID automaticamente
      UserModel newUser = UserModel(
        uid: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _roleController.text.trim(),
        createdAt: DateTime.now(),
        commissionRate: double.tryParse(_commissionRateController.text.trim()) ?? 0.0,
      );

      await _userRepository.addUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      // Voltar para a página inicial após o cadastro
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Papel (seller, pre_seller, admin)'),
            ),
            TextField(
              controller: _commissionRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Comissão'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
