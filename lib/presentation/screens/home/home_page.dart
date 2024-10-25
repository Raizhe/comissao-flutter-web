import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../widgets/side_bar_widget.dart';

class HomePage extends StatelessWidget {
  final UserRepository userRepository = UserRepository();

  HomePage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offNamed('/login');
  }

  Future<String> _fetchUserName(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return snapshot.data()?['name'] ?? 'Usuário';
    } catch (e) {
      print('Erro ao buscar nome do usuário: $e');
      return 'Usuário';
    }
  }

  Future<Map<String, int>> _fetchAllMetrics() async {
    int salesCount = await _getCount('contracts');
    int leadsCount = await _getCount('leads');
    int clientsCount = await _getCount('clients');
    int meetingsCount = await _getCount('meets');

    return {
      'sales': salesCount,
      'leads': leadsCount,
      'clients': clientsCount,
      'meetings': meetingsCount,
    };
  }

  Future<Map<String, String>> _fetchSellerNames() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('sellers').get();
    return {
      for (var doc in snapshot.docs) doc.id: doc['name'] ?? 'Desconhecido',
    };
  }

  Future<Map<String, int>> _fetchSellerPerformance() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('contracts').get();
    Map<String, int> sellerPerformance = {};

    for (var doc in snapshot.docs) {
      String sellerId = doc['sellerId'];
      sellerPerformance[sellerId] = (sellerPerformance[sellerId] ?? 0) + 1;
    }
    return sellerPerformance;
  }

  Future<int> _getCount(String collection) async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(collection).get();
      return snapshot.size;
    } catch (e) {
      print('Erro ao buscar contagem: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchUserName(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Carregando...');
            } else if (snapshot.hasError) {
              return const Text('Erro ao carregar nome');
            } else {
              return Text('Bem-vindo, ${snapshot.data}');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      drawer: FutureBuilder<String?>(
        future: userRepository.getUserRole(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return SidebarWidget(role: snapshot.data!);
          } else {
            return const Center(
                child: Text('Erro ao carregar o papel do usuário.'));
          }
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: FutureBuilder<Map<String, int>>(
            future: _fetchAllMetrics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar métricas.'));
              } else {
                final data = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Drop Lead Dashboard',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      _buildResponsiveGrid(data),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Desempenho dos Vendedores',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<Map<String, int>>(
                                future: _fetchSellerPerformance(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                        'Erro ao carregar desempenho.');
                                  } else {
                                    final sellerData = snapshot.data!;
                                    return FutureBuilder<Map<String, String>>(
                                      future: _fetchSellerNames(),
                                      builder: (context, nameSnapshot) {
                                        if (nameSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (nameSnapshot.hasError) {
                                          return const Text(
                                              'Erro ao carregar nomes.');
                                        } else {
                                          final sellerNames =
                                          nameSnapshot.data!;
                                          return _buildPieChart(
                                              sellerData, sellerNames);
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 30),
                          Column(
                            children: [
                              const Text(
                                'Comparação Vendas vs Leads',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              _buildBarChart(data),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
      Map<String, int> sellerData, Map<String, String> sellerNames) {
    final colors = Colors.primaries;

    // Filtrar apenas vendedores com valores maiores que 0.
    final filteredData = sellerData.entries
        .where((entry) => entry.value > 0 && sellerNames.containsKey(entry.key))
        .toList();

    // Verificar se há dados para mostrar. Se não houver, mostrar um fallback.
    if (filteredData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado disponível para os vendedores'),
      );
    }

    return SizedBox(
      width: 300,
      height: 300,
      child: PieChart(
        PieChartData(
          sections: filteredData.map((entry) {
            final sellerName = sellerNames[entry.key] ?? 'Desconhecido';
            final colorIndex = filteredData.indexOf(entry) % colors.length;

            return PieChartSectionData(
              value: entry.value.toDouble(),
              color: colors[colorIndex],
              title: sellerName,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Cor do texto para maior visibilidade
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    return SizedBox(
      width: 400,
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() + 5,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                    toY: data['sales']!.toDouble(), color: Colors.orange),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                    toY: data['leads']!.toDouble(), color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(Map<String, int> data) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildMetricCard(
            'Vendas', data['sales']!, Colors.orange, '/contracts_page'),
        _buildMetricCard('Leads', data['leads']!, Colors.blue, '/leads_page'),
        _buildMetricCard(
            'Clientes', data['clients']!, Colors.purple, '/clients_page'),
        _buildMetricCard(
            'Reuniões', data['meetings']!, Colors.green, '/meet_page'),
      ],
    );
  }

  Widget _buildMetricCard(String title, int value, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: MouseRegion(
        onEnter: (event) => print('Mouse entered: $title'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150,
          height: 150,
          child: Card(
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
