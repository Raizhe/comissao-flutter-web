import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
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
            onPressed: () {
              _signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navegar para a página de cadastro de clientes
                Navigator.pushNamed(context, '/client_form');
              },
              child: const Text('Cadastrar Cliente'),
            ),
            const SizedBox(height: 45,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pre_seller_form');
              },
              child: const Text('Cadastrar Pré-vendedor'),
            ),
            const SizedBox(height: 45,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/seller_form');
              },
              child: const Text('Cadastrar Vendedor'),
            ),
            const SizedBox(height: 45,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_form');
              },
              child: const Text('Cadastrar Usuário'),
            ),

          ],
        ),
      ),
    );
  }
}
