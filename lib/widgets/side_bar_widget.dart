import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color secondaryColor = Color(0xFF090742);

class SidebarWidget extends StatelessWidget {
  final String role;

  const SidebarWidget({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: secondaryColor,
            ),
            child: Text(
              'Drop Lead',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Menu "Cadastrar" com opções expandidas
          ExpansionTile(
            leading: const Icon(Icons.add),
            title: const Text('Cadastrar'),
            children: [
              _buildDrawerItem(
                icon: Icons.person_add,
                text: 'Leads',
                route: '/lead_form',
              ),
              if (role == 'admin' || role == 'manager') ...[
                _buildDrawerItem(
                  icon: Icons.person,
                  text: 'Usuários',
                  route: '/user_form',
                ),
                _buildDrawerItem(
                  icon: Icons.assignment,
                  text: 'Contratos',
                  route: '/contract_form',
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  text: 'Clientes',
                  route: '/client_form',
                ),
                _buildDrawerItem(
                  icon: Icons.show_chart,
                  text: 'Vendedores',
                  route: '/seller_form',
                ),
                _buildDrawerItem(
                  icon: Icons.engineering,
                  text: 'Operadores',
                  route: '/operator_form',
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent,
                  text: 'CS',
                  route: '/customer_success_form',
                ),
                // Adicionando opção de cadastrar metas para o admin
                if (role == 'admin')
                  _buildDrawerItem(
                    icon: Icons.flag,
                    text: 'Cadastrar Metas',
                    route: '/goal_form',
                  ),
              ],
              if (role == 'seller' || role == 'pre_seller') ...[
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  text: 'Clientes',
                  route: '/client_form',
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart,
                  text: 'Rate de Vendas',
                  route: '/rate_sales',
                ),
              ],
            ],
          ),

          // Itens de navegação independentes
          _buildDrawerItem(
            icon: Icons.list,
            text: 'Clientes',
            route: '/clients_page',
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            text: 'Leads',
            route: '/leads_page',
          ),
          _buildDrawerItem(
            icon: Icons.event_note,
            text: 'Reuniões',
            route: '/meet_page',
          ),
          if (role == 'manager' || role == 'admin') ...[
            _buildDrawerItem(
              icon: Icons.description,
              text: 'Contratos',
              route: '/contracts_page',
            ),
          ],
        ],
      ),
    );
  }

  // Método para criar itens do drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: secondaryColor),
      title: Text(text),
      onTap: () {
        Get.toNamed(route);
      },
    );
  }
}
