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

// Use shared `basePage` from `ui_common.dart`.
