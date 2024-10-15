import 'package:comissao_flutter_web/presentation/screens/clients/client_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/contract/contract_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/pre_seller/pre_seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/seller/seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/user/user_form_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation/screens/login/login_page.dart';
import 'presentation/screens/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Projeto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Define a rota inicial como '/'
      getPages: [
        GetPage(name: '/', page: () => const AuthenticationWrapper()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/client_form', page: () =>  ClientFormPage()),
        GetPage(name: '/pre_seller_form', page: () => const PreSellerFormPage()),
        GetPage(name: '/seller_form', page: () => SellerFormPage()),
        GetPage(name: '/user_form', page: () => UserFormPage()),
        GetPage(name: '/contract_form', page: () => ContractFormPage()),
      ],
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          // Verifica se o usuário está autenticado
          if (user == null) {
            return const LoginPage();
          } else {
            return HomePage();
          }
        }
        // Exibe um carregamento enquanto o estado de autenticação está sendo verificado
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
