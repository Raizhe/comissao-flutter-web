import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  final String hintText;
  final Function(String) onSearch;
  final TextEditingController searchController = TextEditingController();

  NavbarWidget({
    Key? key,
    required this.hintText,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onSubmitted: (value) {
              onSearch(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: () {
            onSearch(searchController.text);
          },
          child: const Text('Buscar'),
        ),
      ],
    );
  }
}
