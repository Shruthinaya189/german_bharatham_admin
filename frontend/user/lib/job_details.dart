import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/job_model.dart';
import 'services/job_service.dart';
import 'services/api_config.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;
  
  const JobDetailsPage({super.key, required this.job});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Future<Job> _jobFuture;

  String _postedAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt.toLocal());

    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? 'Posted 1 day ago' : 'Posted ${diff.inDays} days ago';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? 'Posted 1 hour ago' : 'Posted ${diff.inHours} hours ago';
    }
    if (diff.inMinutes >= 1) {
      return diff.inMinutes == 1 ? 'Posted 1 min ago' : 'Posted ${diff.inMinutes} mins ago';
    }
    return 'Posted just now';
  }

  @override
  void initState() {
    super.initState();
    _jobFuture = JobService.fetchJobById(widget.job.id);
  }

  /// Launch URL using url_launcher
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No application URL available')),
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }

  /// Share job via WhatsApp, Email, or other apps
  void _shareJob(Job job) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share Job',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 18,
                    runSpacing: 14,
                    children: [
                  _shareOptionButton(
                    'WhatsApp',
                    Icons.chat,
                    () async {
                      final message = '${job.title}\n${job.company}\n${job.location}\n€${job.salary}\n${job.applyUrl}';
                      final encodedMessage = Uri.encodeComponent(message);
                      final whatsappUrl = 'https://wa.me/?text=$encodedMessage';
                      try {
                        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WhatsApp not installed')),
                        );
                      }
                    },
                  ),
                  _shareOptionButton(
                    'Email',
                    Icons.mail,
                    () async {
                      final subject = Uri.encodeComponent('${job.title} - ${job.company}');
                      final body = Uri.encodeComponent(
                        '${job.title}\n${job.company}\n${job.location}\n€${job.salary}\n\nApply here: ${job.applyUrl}'
                      );
                      final mailUrl = 'mailto:?subject=$subject&body=$body';
                      try {
                        await launchUrl(Uri.parse(mailUrl));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email not available')),
                        );
                      }
                    },
                  ),
                  _shareOptionButton(
                    'Copy Link',
                    Icons.link,
                    () async {
                      await Clipboard.setData(ClipboardData(text: job.applyUrl ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job link copied')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  _shareOptionButton(
                    'Message',
                    Icons.message,
                    () async {
                      final smsBody = Uri.encodeComponent(
                        '${job.title} at ${job.company}\nApply here: ${job.applyUrl}',
                      );
                      final smsUrl = Uri.parse('sms:?body=$smsBody');
                      await launchUrl(smsUrl);
                    },
                  ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Share Option Button
  Widget _shareOptionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF5E8E73),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Job>(
      future: _jobFuture,
      builder: (context, snapshot) {
        final job = snapshot.data ?? widget.job;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7FAFC),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E8E73)),
              ),
            ),
          );
        }

        // If API refresh fails, keep showing the tapped job payload as fallback.

    // Use requirements and benefits lists directly
    final requirementsList = job.requirements
        .where((r) => r.isNotEmpty)
        .toList();

    final benefitsList = job.benefits
        .where((b) => b.isNotEmpty)
        .toList();

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
      body: SingleChildScrollView(
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
              /// Company + Share
              Row(
                children: [
                  /// Company Logo Placeholder
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        job.company.isNotEmpty
                            ? job.company[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (_postedAgo(job.createdAt).isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _postedAgo(job.createdAt),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shareJob(job),
                    icon: Image.asset(
                      'assets/images/share.png',
                      height: 22,
                      width: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Location + Salary
              Row(
                children: [
                  Image.asset(
                    'assets/images/location.png',
                    height: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job.location,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '€${job.salary}',
                    style: const TextStyle(
                      color: Color(0xFF5E8E73),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Description
              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job.description ?? '',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              /// Requirements
              const Text(
                "Requirements",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: requirementsList.isNotEmpty
                    ? requirementsList
                        .map((req) => _Chip(req))
                        .toList()
                    : [const _Chip('See job description for details')],
              ),

              const SizedBox(height: 20),

              /// Benefits
              const Text(
                "Benefits",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: benefitsList.isNotEmpty
                    ? benefitsList
                        .map((benefit) => _Chip(benefit))
                        .toList()
                    : [const _Chip('See job description for details')],
              ),

              const SizedBox(height: 30),

              /// Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _launchUrl(job.applyUrl ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E8E73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(
                      fontSize: 18,
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
      },
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}
