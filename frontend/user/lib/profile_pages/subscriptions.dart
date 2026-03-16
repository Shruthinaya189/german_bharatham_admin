import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_config.dart';
import '../user_session.dart';
import 'ui_common.dart';
import '../user_profiles_page.dart';

class SubscriptionsPage extends StatefulWidget {
  /// If true, automatically navigate to `UserProfilesPage` when a subscription
  /// (free trial or paid) is activated. This should be true when the page is
  /// opened from the location-permission flow, and false when opened from
  /// profile/settings so the user stays on the page.
  const SubscriptionsPage({super.key, this.autoNavigateOnActivation = false});

  final bool autoNavigateOnActivation;

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  late Razorpay _razorpay;
  String? _pendingPlanId;

  @override
  void dispose() {
    try {
      _razorpay.clear();
    } catch (_) {}
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final token = UserSession.instance.token;
    if (token == null) return;

    try {
      final resp = await http.post(
        Uri.parse(ApiConfig.subscriptionVerifyEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "razorpay_payment_id": response.paymentId,
          "razorpay_order_id": response.orderId,
          "razorpay_signature": response.signature,
          "planId": _pendingPlanId
        }),
      );

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment verified — subscription activated")));
        await _loadPlans();
        if (!mounted) return;
        final activated = await _waitForActivation();
        if (activated && mounted && widget.autoNavigateOnActivation) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserProfilesPage()));
        }
      } else {
        final body = jsonDecode(resp.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body["message"] ?? "Verification failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      _pendingPlanId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment failed or cancelled")));
    _pendingPlanId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("External wallet: ${response.walletName}")));
  }

  Map<String, dynamic> _decode(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    // Wrap non-map responses so callers can still access `data`.
    return {"data": decoded};
  }

  Future<void> _loadPlans() async {

    try {

      final token = UserSession.instance.token;

      if (token == null) {
        setState(() {
          _error = "Not logged in";
          _loading = false;
        });
        return;
      }

      final plansResponse = await http.get(
        Uri.parse(ApiConfig.subscriptionPlansEndpoint),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      final statusResponse = await http.get(
        Uri.parse(ApiConfig.subscriptionStatusEndpoint),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      final plansJson = _decode(plansResponse.body);
      final statusJson = _decode(statusResponse.body);

      // Extract plans from possible shapes: {plans: [...]}, {data: [...]}, or []
      dynamic rawPlans = plansJson["plans"] ?? plansJson["data"] ?? plansJson;
      List<Map<String, dynamic>> plans = [];

      if (rawPlans is List) {
        plans = [];
        for (final item in rawPlans) {
          if (item is Map) {
            final m = <String, dynamic>{};
            item.forEach((k, v) => m[k.toString()] = v);
            plans.add(m);
          }
        }
      }

      setState(() {
        _plans = plans;
        _subscriptionStatus = Map<String, dynamic>.from(statusJson);
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

    final user = _subscriptionStatus?["user"];

    if (user is Map && user["subscriptionStatus"] != null) {
      return user["subscriptionStatus"] == "active";
    }

    return false;
  }

  String? get _activePlanId {

    final user = _subscriptionStatus?["user"];

    if (user is Map) {
      // Backend uses `subscriptionPlan` to store the active plan id.
      return user["subscriptionPlan"]?.toString() ?? user["activePlanId"]?.toString();
    }

    return null;
  }

  Future<void> _subscribe(String planId) async {

    try {

      final token = UserSession.instance.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not logged in")),
        );
        return;
      }

      // Use new client-driven flow: create an order and open native Razorpay checkout
      final response = await http.post(
        Uri.parse(ApiConfig.subscriptionCreateOrderEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"planId": planId}),
      );

      final body = _decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(body["message"] ?? "Subscription failed");
      }

      // Handle free/trial plans (backend may still return free:true)
      if (body["free"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["message"] ?? "Free plan activated")),
        );
        await _loadPlans();
        if (!mounted) return;
        final activated = await _waitForActivation();
        if (activated && mounted && widget.autoNavigateOnActivation) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserProfilesPage()));
        }
        return;
      }

      final orderId = body["orderId"] ?? body["id"];
      final amount = body["amount"];
      final currency = body["currency"];
      final keyId = body["keyId"];

      if (orderId == null || keyId == null) {
        throw Exception("Failed to create order");
      }

      // Save pending plan so success handler can send it to backend
      _pendingPlanId = planId;

      final options = {
        'key': keyId,
        'order_id': orderId,
        'name': 'German Bharatham',
        'description': planId,
        'prefill': {
          'contact': UserSession.instance.phone ?? '',
          'email': UserSession.instance.email ?? ''
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        _pendingPlanId = null;
        rethrow;
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

    }

  }

  Future<void> _unsubscribe(String planId) async {

    try {

      final token = UserSession.instance.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not logged in")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.subscriptionCancelEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "planId": planId
        }),
      );

      final body = _decode(response.body);

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription cancelled")),
        );

        await _loadPlans();

      } else {

        throw Exception(body["message"] ?? "Cancel failed");

      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

    }

  }

  /// Poll the subscription status endpoint until the user becomes trial/active or timeout.
  Future<bool> _waitForActivation({int maxAttempts = 8, Duration interval = const Duration(seconds: 2)}) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        await _loadPlans();
        final user = _subscriptionStatus?['user'];
        if (user is Map) {
          final status = user['subscriptionStatus']?.toString();
          final freeTrialCompleted = user['freeTrialCompleted'] == true;
          if (status == 'active' || status == 'trial' || freeTrialCompleted) return true;
        }
      } catch (_) {}
      await Future.delayed(interval);
    }
    return false;
  }

  Widget _planCard(Map<String, dynamic> plan) {

    final id = (plan['_id'] ?? plan['id'] ?? '').toString();
    final name = (plan['name'] ?? plan['label'] ?? 'Plan').toString();
    final price = plan['price'] ?? plan['priceInr'] ?? 0;
    final duration = plan['duration'] ?? plan['durationDays'] ?? 30;

    final user = _subscriptionStatus?["user"];
    final status = (user is Map) ? user["subscriptionStatus"]?.toString() : null;
    final freeTrialCompleted = (user is Map && user["freeTrialCompleted"] == true);

    // Treat both 'active' and 'trial' as current for the purposes of the UI so
    // an already-activated free trial shows as current (and the button
    // becomes Unsubscribe or disabled) instead of offering Subscribe again.
    final isCurrent = _activePlanId == id && (status == 'active' || status == 'trial');
    final isFreePlan = id == 'free' || id == 'free'.toString();

    final isFreeUsed = isFreePlan && freeTrialCompleted;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Price : ₹$price'),
          const SizedBox(height: 6),
          Text('Duration : $duration days'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: isFreeUsed
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Free trial used', style: TextStyle(color: Colors.grey)),
                  )
                : ElevatedButton(
                    onPressed: isCurrent ? () => _unsubscribe(id) : () => _subscribe(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent ? Colors.amber : primaryGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      isCurrent ? 'Unsubscribe' : 'Subscribe',
                      style: TextStyle(color: isCurrent ? Colors.black : Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return basePage(
        context: context,
        title: 'Subscription Plans',
        child: Center(child: Text(_error!)),
      );
    }

    final user = _subscriptionStatus?['user'];
    final freeTrialCompleted = user is Map && user['freeTrialCompleted'] == true;

    final displayPlans = _plans.where((p) {
      final pid = (p['_id'] ?? p['id'] ?? '').toString();
      if (freeTrialCompleted && pid == 'free') return false;
      return true;
    }).toList();

    return basePage(
      context: context,
      title: 'Subscription Plans',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 12.0;
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: displayPlans
                .map((p) => SizedBox(width: cardWidth, child: _planCard(p)))
                .toList(),
          );
        },
      ),
    );

  }

}