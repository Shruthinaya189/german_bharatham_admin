import 'package:flutter/material.dart';
import 'ui_common.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
Widget build(BuildContext context) {
  return basePage(
    context: context,
    title: "Terms & Conditions",
    child: const Text(
      "By using this app, you agree to our terms.",
    ),
  );
}

}
