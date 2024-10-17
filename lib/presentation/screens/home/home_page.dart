import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';

class HomePage extends StatelessWidget {
  final UserRepository userRepository = UserRepository();

  HomePage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offNamed('/login'); // Navegar para a tela de login usando GetX
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
      drawer: FutureBuilder<String?>(
        future: userRepository.getUserRole(user!.uid), // Obtém o papel do usuário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            String? role = snapshot.data;
            return Drawer(
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

                  // Itens comuns a todos os papéis
                  _buildDrawerItem(
                    icon: Icons.person_add,
                    text: 'Cadastrar Lead',
                    route: '/lead_form',
                  ),
                  _buildDrawerItem(
                    icon: Icons.meeting_room,
                    text: 'Cadastrar Meet',
                    route: '/meet_form',
                  ),

                  // Itens exclusivos para admin e manager
                  if (role == 'admin' || role == 'manager') ...[
                    _buildDrawerItem(
                      icon: Icons.person,
                      text: 'Cadastrar Usuário',
                      route: '/user_form',
                    ),
                    _buildDrawerItem(
                      icon: Icons.assignment,
                      text: 'Cadastrar Contrato',
                      route: '/contract_form',
                    ),
                    _buildDrawerItem(
                      icon: Icons.monetization_on,
                      text: 'Gerenciar Comissões',
                      route: '/commission_form',
                    ),
                  ],

                  // Itens exclusivos para seller e pre-seller
                  if (role == 'seller' || role == 'pre_seller') ...[
                    _buildDrawerItem(
                      icon: Icons.business,
                      text: 'Cadastrar Cliente',
                      route: '/client_form',
                    ),
                    _buildDrawerItem(
                      icon: Icons.bar_chart,
                      text: 'Ver Rate de Vendas',
                      route: '/rate_sales',
                    ),
                  ],

                  // Item visível para todos os papéis
                  _buildDrawerItem(
                    icon: Icons.list,
                    text: 'Visualizar Clientes',
                    route: '/client_list',
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
      body: FutureBuilder<String?>(
        future: userRepository.getUserRole(user!.uid), // Obtém o papel do usuário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            String? role = snapshot.data;
            return _buildDashboard(role!); // Renderiza a dashboard com base no papel
          } else {
            return const Center(child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
    );
  }

  // Método para criar itens no drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Get.toNamed(route);
      },
    );
  }

  // Método para renderizar a dashboard personalizada
  Widget _buildDashboard(String role) {
    switch (role) {
      case 'admin':
        return _adminDashboard();
      case 'manager':
        return _managerDashboard();
      case 'seller':
        return _sellerDashboard();
      case 'pre_seller':
        return _preSellerDashboard();
      default:
        return const Center(child: Text('Bem-vindo!'));
    }
  }

  // Dashboard para admin
  Widget _adminDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Dashboard - Admin', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildNavigationButton('/user_list', 'Visualizar Usuários'),
        ],
      ),
    );
  }

  // Dashboard para manager
  Widget _managerDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Dashboard - Manager', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildNavigationButton('/contract_list', 'Visualizar Contratos'),
        ],
      ),
    );
  }

  // Dashboard para seller
  Widget _sellerDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Dashboard - Seller', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildNavigationButton('/lead_list', 'Visualizar Leads'),
        ],
      ),
    );
  }

  // Dashboard para pre-seller
  Widget _preSellerDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Dashboard - Pre-Seller', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          _buildNavigationButton('/meet_list', 'Visualizar Meets'),
        ],
      ),
    );
  }

  // Botão de navegação auxiliar
  Widget _buildNavigationButton(String route, String label) {
    return ElevatedButton(
      onPressed: () {
        Get.toNamed(route);
      },
      child: Text(label),
    );
  }
}
