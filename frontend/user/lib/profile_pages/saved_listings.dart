import 'package:flutter/material.dart';

class SavedListingsPage extends StatelessWidget {
  const SavedListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _basePage(
      context: context,
      title: "Saved Listings",
      child: Column(
        children: const [
          _savedItem("Studio Apartment", "Munich"),
          _savedItem("Software Developer Job", "Berlin"),
          _savedItem("Indian Restaurant", "Hamburg"),
        ],
      ),
    );
  }
}

class _savedItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _savedItem(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

Widget _basePage({required String title, required Widget child}) {
  return Scaffold(
    backgroundColor: const Color(0xFFF7F8FA),
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
