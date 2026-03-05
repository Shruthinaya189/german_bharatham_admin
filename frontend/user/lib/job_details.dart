import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'models/job_model.dart';
import 'saved_job_manager.dart';

class JobDetailsPage extends StatefulWidget {
  final Job item;
  final VoidCallback? onRefresh;

  const JobDetailsPage({
    super.key,
    required this.item,
    this.onRefresh,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = SavedJobManager.instance.isSaved(widget.item.id);
  }

  void _toggleSave() async {
    final nowSaved = await SavedJobManager.instance.toggle(widget.item);
    setState(() => isSaved = nowSaved);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nowSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF4E7F6D),
        ),
      );
    }
    widget.onRefresh?.call();
  }

  void _shareItem() {
    final String shareText = '''
${widget.item.title}
${widget.item.company}

${widget.item.description ?? 'Check out this job!'}

ðŸ“ ${widget.item.location}
ðŸ’¼ ${widget.item.jobType}
${widget.item.salary != null ? 'ðŸ’° ${widget.item.salary}' : ''}
${widget.item.phone != null ? 'ðŸ“ž ${widget.item.phone}' : ''}
''';
    Share.share(shareText);
  }

  Future<void> _makePhoneCall() async {
    if (widget.item.phone == null || widget.item.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available'), backgroundColor: Colors.red),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: widget.item.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _applyNow() async {
    if (widget.item.applyUrl != null && widget.item.applyUrl!.isNotEmpty) {
      final Uri applyUri = Uri.parse(widget.item.applyUrl!);
      if (await canLaunchUrl(applyUri)) {
        await launchUrl(applyUri, mode: LaunchMode.externalApplication);
      }
    } else if (widget.item.email != null) {
      final Uri emailUri = Uri(scheme: 'mailto', path: widget.item.email);
      if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application link not available'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('assets/images/left-arrow.png', height: 22, width: 22, color: Colors.black),
        ),
        title: const Text("Job Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleSave,
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? const Color(0xFF4E7F6D) : Colors.black),
          ),
          IconButton(onPressed: _shareItem, icon: const Icon(Icons.share, color: Colors.black)),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 50, width: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200),
                            child: const Icon(Icons.business, color: Colors.grey, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.item.company, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(widget.item.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(widget.item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(widget.item.jobType),
                            backgroundColor: const Color(0xFFE8F5E9),
                            labelStyle: const TextStyle(color: Color(0xFF4E7F6D), fontWeight: FontWeight.w600),
                          ),
                          if (widget.item.remote)
                            const Chip(
                              label: Text('Remote'),
                              backgroundColor: Color(0xFFE3F2FD),
                              labelStyle: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600),
                            ),
                          if (widget.item.salary != null)
                            Chip(
                              label: Text(widget.item.salary!),
                              backgroundColor: const Color(0xFFFFF3E0),
                              labelStyle: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.item.description != null && widget.item.description!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("About the Job", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(widget.item.description!, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                      ],
                    ),
                  ),
                if (widget.item.requirements.isNotEmpty) ...[const SizedBox(height: 16), _buildSection("Requirements", widget.item.requirements)],
                if (widget.item.responsibilities.isNotEmpty) ...[const SizedBox(height: 16), _buildSection("Responsibilities", widget.item.responsibilities)],
                if (widget.item.benefits.isNotEmpty) ...[const SizedBox(height: 16), _buildSection("Benefits", widget.item.benefits)],
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Row(
              children: [
                if (widget.item.phone != null)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _makePhoneCall,
                        icon: const Icon(Icons.phone, color: Color(0xFF4F7F67)),
                        label: const Text("Call", style: TextStyle(fontSize: 16, color: Color(0xFF4F7F67), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4F7F67)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                  ),
                if (widget.item.phone != null) const SizedBox(width: 12),
                Expanded(
                  flex: widget.item.phone != null ? 2 : 1,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _applyNow,
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: const Color(0xFF4F7F67),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text("Apply Now", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('â€¢ ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
