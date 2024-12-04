import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthlyCarouselWidget extends StatefulWidget {
  final Map<String, int> monthlyData;
  final String selectedMonth;
  final Function(int) onPageChanged;

  MonthlyCarouselWidget({
    required this.monthlyData,
    required this.selectedMonth,
    required this.onPageChanged,
  });

  @override
  _MonthlyCarouselWidgetState createState() => _MonthlyCarouselWidgetState();
}

class _MonthlyCarouselWidgetState extends State<MonthlyCarouselWidget> {
  final CarouselSliderController _carouselController = CarouselSliderController();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cardList = [
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Contratos Ativos',
        value: widget.monthlyData['activeContracts'] ?? 0,
        comparisonValue: (widget.monthlyData['activeContracts'] ?? 0) - 10,
        color: Colors.green,
        route: '/contracts_page',
      ),
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Contratos Inativos',
        value: widget.monthlyData['inactiveContracts'] ?? 0,
        comparisonValue: (widget.monthlyData['inactiveContracts'] ?? 0) - 5,
        color: Colors.red,
        route: '/contracts_page',
      ),
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Clientes Ativos',
        value: widget.monthlyData['activeClients'] ?? 0,
        comparisonValue: (widget.monthlyData['activeClients'] ?? 0) - 3,
        color: Colors.green,
        route: '/clients_page',
      ),
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Clientes Inativos',
        value: widget.monthlyData['inactiveClients'] ?? 0,
        comparisonValue: (widget.monthlyData['inactiveClients'] ?? 0) - 2,
        color: Colors.orange,
        route: '/clients_page',
      ),
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Clientes Cancelados',
        value: widget.monthlyData['canceledClients'] ?? 0,
        comparisonValue: (widget.monthlyData['canceledClients'] ?? 0) - 1,
        color: Colors.red,
        route: '/clients_page',
      ),
      _buildMetricCard(
        month: widget.selectedMonth,
        subtitle: 'Clientes Downsell',
        value: widget.monthlyData['downsellClients'] ?? 0,
        comparisonValue: (widget.monthlyData['downsellClients'] ?? 0) - 1,
        color: Colors.yellow,
        route: '/clients_page',
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: cardList.length,
          itemBuilder: (context, index, realIdx) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: cardList[index],
            );
          },
          options: CarouselOptions(
            height: 240.0,
            autoPlay: true,
            enlargeCenterPage: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            autoPlayCurve: Curves.easeInOut,
            pauseAutoPlayOnTouch: true,
            enableInfiniteScroll: true,
            viewportFraction: 0.3,
            onPageChanged: (index, reason) {
              widget.onPageChanged(index);
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          carouselController: _carouselController, // Certifique-se de que o controlador está vindo do carousel_slider.
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cardList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _carouselController.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    _currentIndex = entry.key;
                  });
                },
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String month,
    required String subtitle,
    required int value,
    required int comparisonValue,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$comparisonValue em $month',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
