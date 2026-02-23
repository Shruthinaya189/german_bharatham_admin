import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideDetailsPage extends StatelessWidget {
  final dynamic guide;
  
  const GuideDetailsPage({
    super.key,
    required this.guide,
  });

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
                    child: Text(
                      guide["category"] ?? "Guide",
                      style: const TextStyle(
                        color: Color(0xFF3B8F6A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    guide["title"] ?? "Guide Title",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "${guide["author"] ?? "Admin"} • ${guide["date"] ?? "Jan 20, 2026"} • 5 min read",
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    guide["description"] ?? "This is a comprehensive guide that will help you understand the process and requirements.",
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
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

                  ..._buildKeyPoints(guide["keyPoints"] ?? ""),

                  const SizedBox(height: 18),
                  const Text(
                    "External Resources",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _resourceButton(
                    context: context,
                    url: guide["officialWebsites"] ?? "",
                    image: Image.asset(
                      'assets/images/link.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                    text: "Official Government Website",
                  ),
                  const SizedBox(height: 12),
                  _resourceButton(
                    context: context,
                    url: guide["communityDiscussions"] ?? "",
                    image: Image.asset(
                      'assets/images/link.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
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

  List<Widget> _buildKeyPoints(String keyPointsText) {
    if (keyPointsText.isEmpty) {
      return [_pointTile("Information not available")];
    }
    
    List<String> points = keyPointsText.split(',');
    return points.map((point) => _pointTile(point.trim())).toList();
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
  required BuildContext context,
  IconData? icon,
  Widget? image,
  required String text,
  required String url,
}) {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton(
      onPressed: () async {
        if (url.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link not available')),
          );
          return;
        }

        try {
          // Add https:// if no protocol is specified
          String urlToLaunch = url;
          if (!urlToLaunch.startsWith('http://') && !urlToLaunch.startsWith('https://')) {
            urlToLaunch = 'https://$urlToLaunch';
          }
          
          final Uri uri = Uri.parse(urlToLaunch);
          print("Attempting to launch: $urlToLaunch");
          
          // Try to launch the URL
          bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!launched) {
            print("Could not launch $urlToLaunch");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open: $text')),
              );
            }
          }
        } catch (e) {
          print("Error launching URL: $e");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
      },
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
