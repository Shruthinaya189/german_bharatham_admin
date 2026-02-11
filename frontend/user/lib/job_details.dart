import 'package:flutter/material.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            height: 22,
            width: 22,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Job Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Company + share
              Row(
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 44,
                    width: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Software Developer",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Google",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/share.png',
                    height: 24,
                    width: 24,
                  )
                ],
              ),

              const SizedBox(height: 12),

              /// Location + salary + time
              Row(
                children: [
                  Image.asset('assets/images/location.png', height: 16),
                  const SizedBox(width: 6),
                  const Text(
                    "Munich, Bavaria",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Text(
                    "€55,000 - €70,000/year",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                "We are looking for a talented software developer to join our growing team. Experience with React, Node.js, and cloud technologies preferred.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              const Text(
                "Requirements",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Chip("3+ years experience"),
                  _Chip("React/Node.js"),
                  _Chip("German B1 level"),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                "Benefits",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Chip("Remote work options"),
                  _Chip("Health insurance"),
                  _Chip("30 days vacation"),
                  _Chip("Learning budget"),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E8E73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
