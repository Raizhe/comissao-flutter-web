import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
                      _buildSellerCommissionsCard(),
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
                                'Crescimento vendas',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              _buildSalesGrowthChart(),
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

  // Widget _buildWeeklyBarChart(List<Map<String, dynamic>> data) {
  //   return SizedBox(
  //     width: 400,
  //     height: 300,
  //     child: BarChart(
  //       BarChartData(
  //         alignment: BarChartAlignment.spaceAround,
  //         maxY: data
  //                 .map((e) => e['amount'] as double)
  //                 .reduce((a, b) => a > b ? a : b) +
  //             5,
  //         barGroups: data.map((entry) {
  //           return BarChartGroupData(
  //             x: entry['week'],
  //             barRods: [
  //               BarChartRodData(
  //                 toY: entry['amount'],
  //                 color: Colors.green,
  //                 width: 20,
  //               ),
  //             ],
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

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



  Future<Map<String, double>> _fetchSellerContributions() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('contracts').get();

    Map<String, double> sellerContributions = {};

    for (var doc in snapshot.docs) {
      String sellerId = doc['sellerId'];
      double amount = doc['amount']?.toDouble() ?? 0.0;

      sellerContributions[sellerId] =
          (sellerContributions[sellerId] ?? 0) + amount;
    }

    return sellerContributions;
  }

  Future<Map<String, double>> _fetchCommissions() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('contracts').get();

    Map<String, double> sellerCommissions = {};

    for (var doc in snapshot.docs) {
      String sellerId = doc['sellerId'];
      double amount = doc['amount']?.toDouble() ?? 0.0;
      String paymentMethod = doc['paymentMethod'];

      double commissionRate = 0.0;
      if (paymentMethod == 'Cartão') {
        commissionRate = (doc['installments'] ?? 0) >= 8 ? 0.25 : 0.20;
      } else if (paymentMethod == 'Boleto') {
        commissionRate = (doc['installments'] ?? 0) >= 8 ? 0.15 : 0.12;
      } else {
        commissionRate = 0.10; // Outros métodos
      }

      double commission = amount * commissionRate;

      sellerCommissions[sellerId] =
          (sellerCommissions[sellerId] ?? 0) + commission;
    }

    return sellerCommissions;
  }


  Future<List<Map<String, dynamic>>> _fetchWeeklySalesData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('contracts').get();

      Map<int, double> weeklySales = {}; // Total por semana

      for (var doc in snapshot.docs) {
        // Faz o cast seguro para Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime startDate = (data['startDate'] as Timestamp).toDate();
          double feeMensal =
              data.containsKey('feeMensal') && data['feeMensal'] != null
                  ? data['feeMensal'].toDouble()
                  : 0.0; // Define como 0.0 se o campo não existir ou for nulo

          // Distribui o feeMensal para cada semana do contrato até a semana atual
          for (int week = _getWeekOfYear(startDate);
              week <= _getWeekOfYear(DateTime.now());
              week++) {
            weeklySales[week] = (weeklySales[week] ?? 0) + feeMensal;
          }

          // Log para verificar os dados
          print('Document data: $data');
          if (data.containsKey('feeMensal')) {
            print('feeMensal: ${data['feeMensal']}');
          }
        }
      }

      // Converte o Map para uma lista ordenada por semana
      return weeklySales.entries
          .map((entry) => {'week': entry.key, 'amount': entry.value})
          .toList();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      rethrow; // Lança o erro novamente para ser tratado no FutureBuilder
    }
  }

  Widget _buildSellerPerformanceCard() {
    return FutureBuilder<Map<String, double>>(
      future: _fetchSellerContributions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar contribuições.');
        } else {
          final contributions = snapshot.data!;
          return FutureBuilder<Map<String, String>>(
            future: _fetchSellerNames(),
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (nameSnapshot.hasError) {
                return const Text('Erro ao carregar nomes.');
              } else {
                final sellerNames = nameSnapshot.data!;
                final sortedContributions = contributions.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contribuição por Vendedor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...sortedContributions.map((entry) {
                          String sellerName =
                              sellerNames[entry.key] ?? 'Desconhecido';
                          double contribution = entry.value;
                          return ListTile(
                            title: Text(sellerName),
                            subtitle: Text(
                              'Contribuição: R\$ ${contribution.toStringAsFixed(2)}',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildSellerCommissionsCard() {
    return FutureBuilder<Map<String, double>>(
      future: _fetchCommissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao carregar comissões.');
        } else {
          final commissions = snapshot.data!;
          return FutureBuilder<Map<String, String>>(
            future: _fetchSellerNames(),
            builder: (context, nameSnapshot) {
              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (nameSnapshot.hasError) {
                return const Text('Erro ao carregar nomes.');
              } else {
                final sellerNames = nameSnapshot.data!;
                final sortedCommissions = commissions.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comissões por Vendedor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...sortedCommissions.map((entry) {
                          String sellerName =
                              sellerNames[entry.key] ?? 'Desconhecido';
                          double commission = entry.value;
                          return ListTile(
                            title: Text(sellerName),
                            subtitle: Text(
                              'Comissão: R\$ ${commission.toStringAsFixed(2)}',
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }



  // Função para calcular a semana do ano
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  Widget _buildLineChart(List<Map<String, dynamic>> salesData) {
    double maxY = salesData
            .map((e) => e['amount'] as double)
            .reduce((a, b) => a > b ? a : b) +
        10;

    return SizedBox(
      width: 400,
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(salesData.length, (index) {
                double amount = salesData[index]['amount'];
                return FlSpot(index.toDouble(), amount);
              }),
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toInt()}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < salesData.length) {
                    String weekLabel = _getWeekLabel(salesData[index]['week']);
                    return Text(
                      weekLabel,
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  // Função para gerar o nome abreviado da semana (Ex: "Sem 42")
  String _getWeekLabel(int weekNumber) {
    return 'Sem ${weekNumber.toString()}';
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

  Widget _buildSalesGrowthChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchWeeklySalesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Text('Nenhum dado disponível.');
        } else {
          final weeklySalesData = snapshot.data!;
          return _buildLineChart(weeklySalesData);
        }
      },
    );
  }
}
