import 'package:comissao_flutter_web/presentation/screens/clients/clients_details_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/clients_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/clients/clients_page.dart';
import 'package:comissao_flutter_web/presentation/screens/contract/contract_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/contract/contracts_details_page.dart';
import 'package:comissao_flutter_web/presentation/screens/contract/contracts_page.dart';
import 'package:comissao_flutter_web/presentation/screens/costumerSuccess/customer_success_form.dart';
import 'package:comissao_flutter_web/presentation/screens/leads/leads_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/leads/leads_page.dart';
import 'package:comissao_flutter_web/presentation/screens/meet/meet_page.dart';
import 'package:comissao_flutter_web/presentation/screens/pre_seller/pre_seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/seller/seller_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/user/user_form_page.dart';
import 'package:comissao_flutter_web/presentation/screens/operator/operator_form_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'data/models/clients_model.dart';
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
      title: 'Drop Lead',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthenticationWrapper()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/client_form', page: () => ClientFormPage()),
        GetPage(
            name: '/pre_seller_form', page: () => const PreSellerFormPage()),
        GetPage(name: '/seller_form', page: () => SellerFormPage()),
        GetPage(name: '/user_form', page: () => UserFormPage()),
        GetPage(name: '/contract_form', page: () => const ContractFormPage()),
        GetPage(name: '/lead_form', page: () => const LeadFormPage()),
        GetPage(name: '/leads_page', page: () => const LeadsPage()),
        GetPage(name: '/contracts_page', page: () => const ContractsPage()),
        GetPage(name: '/clients_page', page: () => const ClientsPage()),
        GetPage(name: '/meet_page', page: () => const MeetPage()),
        GetPage(name: '/operator_form', page: () => OperatorFormPage()),
        GetPage(name: '/customer_success_form', page: () => CustomerSuccessFormPage()),
        GetPage(
          name: '/client_details',
          page: () => ClientDetailsPage(
            client: Get.arguments as ClientModel,
          ),
        ),
        GetPage(
          name: '/contracts_details',
          page: () => ContractDetailsPage(
            contract: Get.arguments,
            sellerName: '',
          ),
        ),
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
          if (user == null) {
            return LoginPage();
          } else {
            return HomePage();
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
