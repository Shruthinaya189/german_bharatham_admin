import 'package:flutter/material.dart';
import 'ui_common.dart';

class SavedListingsPage extends StatelessWidget {
  const SavedListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return basePage(
      context: context,
      title: "Saved Listings",
      child: const Column(
        children: [
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

// Use shared `basePage` from `ui_common.dart`.

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
