import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'models/service_model.dart';
import 'saved_service_manager.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service item;
  final VoidCallback? onRefresh;

  const ServiceDetailsPage({super.key, required this.item, this.onRefresh});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = SavedServiceManager.instance.isSaved(widget.item.id);
  }

  void _toggleSave() async {
    final nowSaved = await SavedServiceManager.instance.toggle(widget.item);
    setState(() => isSaved = nowSaved);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nowSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF4E7F6D)),
      );
    }
    widget.onRefresh?.call();
  }

  void _shareItem() {
    final String shareText = '''
${widget.item.title}
${widget.item.provider ?? ''}

${widget.item.description ?? 'Check out this service!'}

ðŸ“ ${widget.item.address ?? widget.item.city}
${widget.item.phone != null ? 'ðŸ“ž ${widget.item.phone}' : ''}
${widget.item.priceRange != null ? 'ðŸ’° ${widget.item.priceRange}' : ''}
''';
    Share.share(shareText);
  }

  Future<void> _makePhoneCall() async {
    if (widget.item.phone == null || widget.item.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number not available'), backgroundColor: Colors.red));
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: widget.item.phone);
    if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
  }

  Future<void> _openWebsite() async {
    if (widget.item.website != null && widget.item.website!.isNotEmpty) {
      final Uri websiteUri = Uri.parse(widget.item.website!);
      if (await canLaunchUrl(websiteUri)) await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Image.asset('assets/images/left-arrow.png', height: 22, width: 22, color: Colors.black)),
        title: const Text("Service Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _toggleSave, icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? const Color(0xFF4E7F6D) : Colors.black)),
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
                            height: 80, width: 80,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade200),
                            child: widget.item.image != null && widget.item.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(widget.item.image!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.business, color: Colors.grey, size: 40)),
                                  )
                                : const Icon(Icons.business, color: Colors.grey, size: 40),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                if (widget.item.provider != null) Text(widget.item.provider!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(widget.item.city, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(widget.item.serviceType), backgroundColor: const Color(0xFFE8F5E9), labelStyle: const TextStyle(color: Color(0xFF4E7F6D), fontWeight: FontWeight.w600)),
                          if (widget.item.verified) const Chip(label: Text('Verified'), backgroundColor: Color(0xFFE3F2FD), labelStyle: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
                          if (widget.item.priceRange != null) Chip(label: Text(widget.item.priceRange!), backgroundColor: const Color(0xFFFFF3E0), labelStyle: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600)),
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
                        const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(widget.item.description!, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (widget.item.address != null) _infoRow(icon: Icons.location_on_outlined, title: "Address", value: widget.item.address!),
                      _infoRow(icon: Icons.location_city, title: "City", value: widget.item.city),
                      if (widget.item.phone != null) _infoRow(icon: Icons.phone_outlined, title: "Phone", value: widget.item.phone!),
                      if (widget.item.email != null) _infoRow(icon: Icons.email_outlined, title: "Email", value: widget.item.email!, valueColor: Colors.blue),
                      if (widget.item.website != null) InkWell(onTap: _openWebsite, child: _infoRow(icon: Icons.language, title: "Website", value: widget.item.website!, valueColor: Colors.blue)),
                    ],
                  ),
                ),
                if (widget.item.certifications.isNotEmpty || widget.item.languages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.certifications.isNotEmpty) ...[
                          const Text("Certifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 8, children: widget.item.certifications.map((c) => _Chip(c)).toList()),
                        ],
                        if (widget.item.languages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text("Languages", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 8, children: widget.item.languages.map((l) => _Chip(l)).toList()),
                        ],
                      ],
                    ),
                  ),
                ],
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
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4F7F67)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      ),
                    ),
                  ),
                if (widget.item.phone != null) const SizedBox(width: 12),
                Expanded(
                  flex: widget.item.phone != null ? 2 : 1,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.item.email != null
                          ? () async {
                              final Uri emailUri = Uri(scheme: 'mailto', path: widget.item.email);
                              if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: const Color(0xFF4F7F67),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text("Contact", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _infoRow({required IconData icon, required String title, required String value, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4E7F6D)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 14, color: valueColor ?? Colors.grey)),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(22)),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
