// WEB versiyona uyarlanmis hali - register_page_web.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_page_web.dart';

class RegisterPageWeb extends StatefulWidget {
  const RegisterPageWeb({super.key});

  @override
  State<RegisterPageWeb> createState() => _RegisterPageWebState();
}

class _RegisterPageWebState extends State<RegisterPageWeb> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;

  void _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': _nameController.text.trim(),
              'surname': _surnameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'birthDate': _birthDate?.toIso8601String(),
            });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPageWeb()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _showEmailExistsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Failed: \${e.message}')),
          );
        }
      }
    }
  }

  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Email Already in Use",
            textAlign: TextAlign.center,
          ),
          content: const Text("Please try another email address."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('web/assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "MYLOG",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 10),
                    _buildTextField(_surnameController, 'Surname'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      _phoneController,
                      'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordField(_passwordController, 'Password'),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      _confirmPasswordController,
                      'Confirm Password',
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickBirthDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _birthDate == null
                              ? 'Select Birth Date'
                              : '\${_birthDate!.day}/\${_birthDate!.month}/\${_birthDate!.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B3F72),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuthPageWeb(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B3F72),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter \$label';
        }
        if (label == 'Email') {
          final emailRegex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address.';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter \$label' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
