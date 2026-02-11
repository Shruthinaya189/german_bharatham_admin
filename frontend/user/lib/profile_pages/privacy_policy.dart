import 'package:flutter/material.dart';
import 'ui_common.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
  return basePage(
    context: context,
    title: "Privacy Policy",
    child: const Text(
      "Your privacy is important to us.",
    ),
  );}
}
