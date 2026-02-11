import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        /// ✅ CUSTOM LEFT ARROW
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            'assets/images/left-arrow.png',
            width: 22,
            height: 22,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationTile(
            title: "New Job Alert",
            message: "A new job has been posted near your location",
            time: "2m ago",
            unread: true,
          ),
          _NotificationTile(
            title: "Price Drop",
            message: "Apartment price has been reduced",
            time: "1h ago",
            unread: true,
          ),
          _NotificationTile(
            title: "Support",
            message: "You have a new message from support",
            time: "Yesterday",
            unread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool unread;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
  });

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ✅ MESSAGE ICON (ASSET)
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF2EF),
            child: Image.asset(
              'assets/images/msg.png',
              width: 20,
              height: 20,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        unread ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// TIME + UNREAD DOT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              if (unread)
                Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
