import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController preferredCity = TextEditingController();
  final TextEditingController education = TextEditingController();
  final TextEditingController profession = TextEditingController();
  final TextEditingController germanLevel = TextEditingController();
  final TextEditingController passport = TextEditingController();

  static const Color primaryGreen = Color(0xFF4E7F6D);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name.text = prefs.getString('name') ?? '';
      phone.text = prefs.getString('phone') ?? '';
      email.text = prefs.getString('email') ?? '';
      dob.text = prefs.getString('dob') ?? '';
      gender.text = prefs.getString('gender') ?? '';
      location.text = prefs.getString('location') ?? '';
      preferredCity.text = prefs.getString('preferredCity') ?? '';
      education.text = prefs.getString('education') ?? '';
      profession.text = prefs.getString('profession') ?? '';
      germanLevel.text = prefs.getString('germanLevel') ?? '';
      passport.text = prefs.getString('passport') ?? '';
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name.text);
    await prefs.setString('phone', phone.text);
    await prefs.setString('email', email.text);
    await prefs.setString('dob', dob.text);
    await prefs.setString('gender', gender.text);
    await prefs.setString('location', location.text);
    await prefs.setString('preferredCity', preferredCity.text);
    await prefs.setString('education', education.text);
    await prefs.setString('profession', profession.text);
    await prefs.setString('germanLevel', germanLevel.text);
    await prefs.setString('passport', passport.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
  title: const Text("Personal Information"),
  centerTitle: true,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,

  leading: IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Image.asset(
      'assets/images/left-arrow.png',
      width: 22,
      height: 22,
    ),
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _input("Full Name", name),
                _input("Phone Number", phone),
                _input("Email", email),
                _input("Date of Birth", dob),
                _input("Gender", gender),
                _input("Current Location", location),
                _input("Preferred City in Germany", preferredCity),
                _input("Education", education),
                _input("Profession", profession),
                _input("German Language Level (A1, A2, B1, B2)", germanLevel),
                _input("Passport Number", passport),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Save Information"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Required field";
            }
            return null;
          },
        ),
      ],
    ),
  );
}
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
