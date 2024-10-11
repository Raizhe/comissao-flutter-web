import 'package:comissao_flutter_web/presentation/screens/clients/client_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/contract_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/pre_seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/user_form_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Projeto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        //'/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/client_form': (context) => const ClientFormPage(),
        '/pre_seller_form': (context) => const PreSellerFormPage(),
        '/seller_form': (context) => const SellerFormPage(),
        '/user_form': (context) => const UserFormPage(),
        '/contract_form': (context) => const ContractFormPage(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar o estado de autenticação do usuário
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o usuário está autenticado , ir para a HomePage
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        }
        // Exibir indicador de carregamento enquanto verifica a autenticação
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
