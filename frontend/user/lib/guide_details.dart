import 'package:flutter/material.dart';

class GuideDetailsPage extends StatelessWidget {
  const GuideDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
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
        centerTitle: true,
        title: const Text(
          "Guide Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F2EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Guide",
                      style: TextStyle(
                        color: Color(0xFF3B8F6A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "Complete Guide to German Registration (Anmeldung)",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    "Admin • Jan 20, 2026 • 5 min read",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "This is a comprehensive guide that will help you understand the process and requirements. The information provided here is up-to-date as of Jan 20, 2026.",
                    style: TextStyle(
                      fontSize: 17.5,
                      height: 2.5,
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    "Key Points",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _pointTile("Detailed step-by-step instructions"),
                  _pointTile("Important documents you'll need"),
                  _pointTile("Common pitfalls to avoid"),

                  const SizedBox(height: 18),
                  const Text(
                    "External Resources",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _resourceButton(image: Image.asset('assets/images/link.png',width: 20,height: 20,color: Colors.white,),
                    text: "Official Government Website",
                  ),
                  const SizedBox(height: 12),
                  _resourceButton(image: Image.asset('assets/images/link.png',width: 20,height: 20,color: Colors.white,),
                    text: "Community Forum Discussion",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pointTile(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _resourceButton({
  IconData? icon,
  Widget? image,
  required String text,
}) {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4F8F75),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 18),
          if (image != null) image,
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    ),
  );
}
}
