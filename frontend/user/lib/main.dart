import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';
import 'saved_manager.dart';
import 'user_profiles_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'German Bharatham',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  Widget build(BuildContext context) {
    debugPrint('WelcomeScreen built');
    const horizontalPadding = 24.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image with fallback for web + subtle overlay for contrast
          Positioned.fill(
            child: Image.asset(
              'assets/images/german1.jpeg',
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stack) {
                // If the primary background can't be decoded in browser, use a fallback image
                // Fallback to the same PNG background (browser handles PNG reliably)
                return Image.asset(
                  'assets/images/german1.jpeg',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                );
              },
            ),
          ),

          // Bottom gradient overlay to create a soft white fade (matches mock)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.fromRGBO(255, 255, 255, 0.85),
                    Colors.white,
                  ],
                  stops: [0.45, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Content at the bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small location marker circle (white disc with slight shadow)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.12),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child:ClipOval(
  child: Image.asset(
    'assets/images/german_map.png',
    width: 32,
    height: 32,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(
        Icons.location_on,
        color: Color(0xFF2E7D32),
        size: 20,
      );
    },
  ),
),
                    ),

                    const SizedBox(height: 14),

                    // Title
                    const Text(
                      'Helping Indians settle in Germany',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Accommodation • Food • Jobs • Services',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19, color: Colors.grey.shade700),
                    ),

                    const SizedBox(height: 28),

                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const InfoPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// New informational page shown after Get Started
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});
  static const Color primaryGreen = Color(0xFF4E7F6D);

  Widget _buildCard(Widget leading, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F2), // light green background like the mock
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _leadingImage(String assetPath) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.image, color: primaryGreen, size: 26)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
            'assets/images/arrow.png',
          width: 24,
          height: 24,
        ),
      ),
    ),
        centerTitle: true,
        title: const Text('Everything you need in one place', textAlign: TextAlign.center,style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            const SizedBox(height: 17),
            _buildCard(_leadingImage('assets/images/rent.jpg'), 'Find accommodation & rentals', 'Verified shared rooms, apartments, and temporary stays'),
            _buildCard(_leadingImage('assets/images/service.jpg'), 'Discover Indian food, jobs & services', 'Groceries, restaurants, job leads, and essential services'),
            _buildCard(_leadingImage('assets/images/trust.jpg'), 'Get trusted community support', 'Guides, resources, and help from the Indian community'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Authentication page (Get Started / Login / Sign up)
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _obscure = true;
  bool _remember = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> loginUser() async {
  setState(() {
    _loginError = null; // clear old error
  });

  try {
    final response = await http.post(
      Uri.parse("http://10.166.137.12:5000/api/user/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      await UserSession.instance.save(
        userId: user['_id'].toString(),
        token: data['token'].toString(),
        name: user['name'].toString(),
        email: user['email'].toString(),
        phone: user['phone']?.toString(),
        photoBase64: user['photo']?.toString(),
      );
      SavedManager.instance.switchUser(user['_id'].toString());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationPermissionPage(),
          ),
        );
      }
    } else {
      setState(() {
        _loginError = "Username or Password is wrong. Try again.";
      });
    }
  } catch (e) {
    setState(() {
      _loginError = "Server error. Please try again.";
    });
  }
}
  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF4E7F6D);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // small map pin and heading
              const SizedBox(height: 6),
              SizedBox(
                width: 36,
                height: 36,
                child: Image.asset(
                  'assets/images/german_map.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Get Started now',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),),
              const SizedBox(height: 8),
              Text('Create an account or log in to explore the app',style: TextStyle(fontSize: 22,color: Colors.grey,),),
              const SizedBox(height: 18),

              // segmented control (Login / Sign up)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Login', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (_) => SignupPage()),);},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Sign up', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text('Email or Phone number',style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),

              const SizedBox(height: 12),
              const Text('Password', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  suffixIcon: IconButton(
                    // Use an asset image (assets/images/eye.png). If the image is missing or
                    // cannot be decoded, fall back to the original visibility icon.
                    icon: Image.asset(
                      'assets/images/eye.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                      const Text('Remember me',style: TextStyle(fontSize: 14),),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF4E7F6D)))),
                ],
              ),

              const SizedBox(height: 12),
              if (_loginError != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      _loginError!,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
    ),
  ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Login', style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 18),
              Row(
  children: [
    const Expanded(child: Divider()),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        'Or',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    ),
    const Expanded(child: Divider()),
  ],
),
              const SizedBox(height: 12),
              Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                _socialCircle('assets/images/google.png'),
                _socialCircle('assets/images/communication.png'),
                _socialCircle('assets/images/social.png'),
              ],
            ),
            const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialCircle(String imagePath) {
  return CircleAvatar(
    radius: 22,
    backgroundColor: Colors.grey.shade200,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    ),
  );
}
}

// ===== ADD SIGNUP PAGE HERE =====

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  // 🔹 Toggle (Login / Signup)
  bool _isLogin = false;

  // 🔹 Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🔹 Password visibility
  bool _obscure = true;
  String? _passwordError;

  // 🔹 Theme color
  final Color primaryGreen = const Color(0xFF4F7F67);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validatePassword(String password) {
  if (password.length < 6) {
    return "Password must be at least 6 characters long";
  }

  if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
    return "Password must contain at least one alphabet";
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return "Password must contain at least one number";
  }

  if (!RegExp(r'[!@#\$&*~%^()_\-+=]').hasMatch(password)) {
    return "Password must contain at least one special character";
  }

  return null;
}
  Future<void> registerUser() async {

  final password = _passwordController.text.trim();
  final error = validatePassword(password);

  if (error != null) {
    setState(() {
      _passwordError = error;
    });
    return;
  }

  setState(() {
    _passwordError = null;
  });

  try {
    final response = await http.post(
      Uri.parse("http://10.166.137.12:5000/api/user/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      await UserSession.instance.save(
        userId: user['_id'].toString(),
        token: data['token'].toString(),
        name: user['name'].toString(),
        email: user['email'].toString(),
        phone: user['phone']?.toString(),
        photoBase64: user['photo']?.toString(),
      );
      SavedManager.instance.switchUser(user['_id'].toString());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationPermissionPage(),
          ),
        );
      }
    } else {
      setState(() {
        _passwordError = "Signup failed. Try again.";
      });
    }
  } catch (e) {
    setState(() {
      _passwordError = "Server error. Try again.";
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // your existing UI
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              SizedBox(
                width: 36,
                height: 36,
                child: Image.asset(
                  'assets/images/german_map.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Get Started now',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Create an account or log in to explore the app',
                  style: TextStyle(fontSize: 22,color: Colors.grey.shade700)),
              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthPage(),
        ),
      );
},
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _isLogin ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Login', textAlign: TextAlign.center),
    ),
  ),
),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (_) => SignupPage()),);},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Sign up', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _fieldLabel('Full Name'),
              _inputField(_nameController),

              _fieldLabel('Email'),
              _inputField(_emailController, keyboard: TextInputType.emailAddress),

              _fieldLabel('Phone Number'),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text('🇮🇳 +91'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _inputField(_phoneController, keyboard: TextInputType.phone)),
                ],
              ),

              _fieldLabel('Set Password'),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    // Use an asset image (assets/images/eye.png). If the image is missing or
                    // cannot be decoded, fall back to the original visibility icon.
                    icon: Image.asset(
                      'assets/images/eye.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 22),
              if (_passwordError != null)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      _passwordError!,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
    ),
  ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Sign up',
                      style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _inputField(TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Screen - replace with your app content')),
    );
  }
}

// ===== LOCATION PERMISSION PAGE =====

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({super.key});

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                'assets/images/loc.jpeg',
                height: 260,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Allow location access to discover nearby accommodation, services, jobs, and community resources around you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserProfilesPage()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // 👈 reduced radius here
      ),
    ),
    child: const Text("Enable Location",style: TextStyle(color: Colors.white,),),
  ),
),
              const SizedBox(height: 14),
              TextButton(
               onPressed: () {
                Navigator.pushReplacement(
                 context,
                  MaterialPageRoute(builder: (_) => const UserProfilesPage()),
              );
            },
            child: const Text("Not now",style: TextStyle(color: Colors.grey,),),
            ),
            const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    await UserSession.instance.load();
    if (UserSession.instance.isLoggedIn) {
      SavedManager.instance.switchUser(UserSession.instance.userId!);
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserSession.instance.isLoggedIn
              ? const UserProfilesPage()
              : const WelcomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/german_map.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            const Text(
              'German Bharatham',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
