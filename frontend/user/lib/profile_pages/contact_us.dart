import 'package:flutter/material.dart';
import 'ui_common.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return basePage(
      context: context,
      title: "Contact Us",
      child: Column(
        children: [
          infoCard("Email", "support@germanbharatham.com"),
          infoCard("Phone", "+49 123 456 789"),
          infoCard("Office", "Berlin, Germany"),
        ],
      ),
    );
  }
}
