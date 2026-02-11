import 'package:flutter/material.dart';
import 'ui_common.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return basePage(
      context: context,
      title: "Help Center",
      child: Column(
        children: [
          helpTile("How to apply for jobs?"),
          helpTile("How to book accommodation?"),
          helpTile("How to save listings?"),
          helpTile("How to contact support?"),
        ],
      ),
    );
  }
}
