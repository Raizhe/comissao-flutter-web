import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../contract/contract_form_page.dart'; // Importe o repositório para buscar o papel

class HomePage extends StatelessWidget {
  final UserRepository userRepository = UserRepository();

  HomePage({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login'); // Usando GetX para navegação após o logout
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: userRepository.getUserRole(user!.uid),
        // Busca o papel do usuário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            String? role = snapshot.data;
            print('Role recebido: $role');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Você está logado como: $role'),
                  const SizedBox(height: 20),
                  // Mostrar diferentes funcionalidades com base no papel do usuário
                  if (role == 'admin') ...[
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/user_form'); // Navegação usando GetX
                      },
                      child: const Text('Cadastrar Usuário'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/client_form');
                      },
                      child: const Text('Cadastrar Cliente'),
                    ),
                    // Mais permissões de admin aqui...
                  ],
                  if (role == 'seller' || role == 'pre_seller') ...[

                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => ContractFormPage()); // Navegar para a página de formulário de contrato
                      },
                      child: const Text('Cadastrar Contrato'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/client_form');
                      },
                      child: const Text('Cadastrar Cliente'),
                    ),
                  ],
                  if (role == 'manager') ...[
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/commission_form');
                      },
                      child: const Text('Gerenciar Comissões'),
                    ),
                  ],
                ],
              ),
            );
          } else {
            return const Center(
                child: Text('Erro ao carregar o papel do usuário. Verifique os dados no Firestore.'));
          }
        },
      ),
    );
  }
}
