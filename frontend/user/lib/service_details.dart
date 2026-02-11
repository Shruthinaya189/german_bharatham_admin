import 'package:flutter/material.dart';

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key});

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
          "Service Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP SERVICE CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1581578731548-c64695cc6952",
                      height: 95,
                      width: 95,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Relocation Experts",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Image.asset('assets/images/share.png',height: 18,width: 18,),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/location.png',
                              height: 14,
                              width: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Munich, Bavaria",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/star.png',
                              height: 14,
                              width: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "4.5",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "We are looking for a talented software developer to join our growing team. Experience with React, Node.js, and cloud technologies preferred.",
              style: TextStyle(
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            /// SERVICES OFFERED
            const Text(
              "Services Offered",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: const [
                ServiceChip(title: "Accommodation search assistance"),
                ServiceChip(title: "Moving & settling support"),
                ServiceChip(title: "Temporary housing arrangement"),
              ],
            ),

            const SizedBox(height: 20),

            /// LOCATION MAP
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/map.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/images/call.png',height: 18,width: 18,),
                    label: const Text("Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F7F67),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/images/whatsapp.png',height: 18,width: 18,),
                    label: const Text("Whatsapp"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F7F67),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceChip extends StatelessWidget {
  final String title;

  const ServiceChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
