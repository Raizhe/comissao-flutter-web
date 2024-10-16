import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
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
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offNamed('/login');  // Usando o GetX para navegação
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu de Navegação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Cadastrar Usuário'),
              onTap: () {
                Get.toNamed('/user_form');  // Navegar para Cadastrar Usuário
              },
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Cadastrar Cliente'),
              onTap: () {
                Get.toNamed('/client_form');  // Navegar para Cadastrar Cliente
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Cadastrar Contrato'),
              onTap: () {
                Get.toNamed('/contract_form');  // Navegar para Cadastrar Contrato
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Você está logado como: admin',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
