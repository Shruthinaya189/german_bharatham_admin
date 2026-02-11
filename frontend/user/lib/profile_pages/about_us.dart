import 'package:flutter/material.dart';
import 'ui_common.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return basePage(
      context: context,
      title: "About Us",
      child: const Text(
        "German Bharatham helps students and professionals find jobs, "
        "accommodation, and guidance in Germany.",
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
