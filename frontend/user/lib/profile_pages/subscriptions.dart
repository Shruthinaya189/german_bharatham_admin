import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/api_config.dart';
import '../user_session.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  static const Color primaryGreen = Color(0xFF4E7F6D);

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _status;
  List<Map<String, dynamic>> _plans = [];

  Map<String, dynamic> _tryDecodeJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{'data': decoded};
  }

  String _summarizeNonJson(String body) {
    final trimmed = body.trimLeft();
    final oneLine = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    if (oneLine.length <= 180) return oneLine;
    return '${oneLine.substring(0, 180)}…';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = UserSession.instance;
      final token = session.token;
      if (token == null) {
        setState(() {
          _error = 'Not logged in';
          _loading = false;
        });
        return;
      }

      final plansRes = await http.get(
        Uri.parse(ApiConfig.subscriptionPlansEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final statusRes = await http.get(
        Uri.parse(ApiConfig.subscriptionStatusEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> plansJson = <String, dynamic>{};
      Map<String, dynamic> statusJson = <String, dynamic>{};

      try {
        plansJson = _tryDecodeJson(plansRes.body);
      } catch (_) {
        // Non-JSON (often HTML error page from server/proxy)
      }
      try {
        statusJson = _tryDecodeJson(statusRes.body);
      } catch (_) {
        // Non-JSON (often HTML error page from server/proxy)
      }

      if (plansRes.statusCode != 200) {
        final msg = plansJson['message']?.toString();
        final hint = plansJson.isNotEmpty
            ? msg
            : 'Server returned non-JSON (HTTP ${plansRes.statusCode}): ${_summarizeNonJson(plansRes.body)}';
        throw Exception(hint);
      }
      if (statusRes.statusCode != 200) {
        final msg = statusJson['message']?.toString();
        final hint = statusJson.isNotEmpty
            ? msg
            : 'Server returned non-JSON (HTTP ${statusRes.statusCode}): ${_summarizeNonJson(statusRes.body)}';
        throw Exception(hint);
      }

      final plans = (plansJson['plans'] as List?)
              ?.whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList() ??
          <Map<String, dynamic>>[];

      setState(() {
        _plans = plans;
        _status = statusJson;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool get _isActive {
    final user = _status?['user'];
    if (user is Map && user['subscriptionStatus'] != null) {
      return user['subscriptionStatus'].toString() == 'active';
    }
    return false;
  }

  String _prettyStatus() {
    final user = _status?['user'];
    if (user is Map && user['subscriptionStatus'] != null) {
      return user['subscriptionStatus'].toString();
    }
    return 'none';
  }

  Future<void> _subscribe(String planId) async {
    final token = UserSession.instance.token;
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse(ApiConfig.subscriptionCheckoutSessionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'planId': planId}),
      );
      Map<String, dynamic> bodyJson = <String, dynamic>{};
      try {
        bodyJson = _tryDecodeJson(res.body);
      } catch (_) {
        // Non-JSON (often HTML error page)
      }

      if (res.statusCode != 200) {
        final msg = bodyJson['message']?.toString();
        final hint = bodyJson.isNotEmpty
            ? msg
            : 'Server returned non-JSON (HTTP ${res.statusCode}): ${_summarizeNonJson(res.body)}';
        throw Exception(hint);
      }

      final url = bodyJson['url']?.toString() ?? '';
      if (url.isEmpty) throw Exception('Missing checkout url');

      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment page')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Subscriptions'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E8EC)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/time.png',
                    width: 22,
                    height: 22,
                    color: primaryGreen,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your subscription',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${_prettyStatus()}${_isActive ? ' (active)' : ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _load,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            else ...[
              const Text(
                'Choose a plan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_plans.isEmpty)
                const Text(
                  'No plans configured. Ask admin to enable plans and set prices in Admin → Subscriptions.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                )
              else
                ..._plans.map((p) {
                  final id = (p['id'] ?? '').toString();
                  final label = (p['label'] ?? id).toString();
                  final price = p['price'];
                  final currency = (p['currency'] ?? 'INR').toString();
                  final subtitle = (price != null && price.toString().isNotEmpty)
                      ? '$label  •  $currency ${price.toString()}'
                      : label;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE6E8EC)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isActive ? null : () => _subscribe(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(_isActive ? 'Active' : 'Subscribe'),
                        )
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 12),
              const Text(
                'Note: after payment, subscription becomes active once the backend receives the Razorpay webhook.',
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
