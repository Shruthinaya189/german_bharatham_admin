import 'package:flutter/material.dart';
import 'ui_common.dart';

class ReportProblemPage extends StatelessWidget {
  const ReportProblemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return basePage(
      context: context,
      title: "Report a Problem",
      child: Column(
        children: [
          inputField("Subject"),
          inputField("Describe your problem"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: buttonStyle(),
              onPressed: () {},
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
