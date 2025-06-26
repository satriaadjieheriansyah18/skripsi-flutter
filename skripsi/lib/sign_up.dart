import 'package:flutter/material.dart';
import 'package:skripsi/login_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: SignUpPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  Future<void> registerUser() async {
    final String username = usernameController.text.trim();
    final String phonenumber = phonenumberController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password harus diisi!')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.178.180.83:8000/api/register'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone_number": phonenumber,
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Registrasi gagal! Coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Untirta',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          shadows: const [
                            Shadow(
                              offset: Offset(3, 3),
                              blurRadius: 5,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      const TextSpan(
                        text: '-Ku',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          shadows: [
                            Shadow(
                              offset: Offset(3, 3),
                              blurRadius: 5,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              buildInputField(Icons.person, "USERNAME", "username",
                  controller: usernameController),
              buildInputField(Icons.call, "PHONE_NUMBER", "phone_number",
                  controller: phonenumberController),

              buildInputField(Icons.person, "EMAIL", "example@gmail.com",
                  controller: emailController),

              // 🔑 Input Password
              buildInputField(Icons.vpn_key, "PASSWORD", "●●●●●●●●",
                  isPassword: true,
                  controller: passwordController,
                  isObscured: isPasswordVisible, toggleVisibility: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              }),

              buildInputField(Icons.vpn_key, "RETYPE PASSWORD", "●●●●●●●●",
                  isPassword: true,
                  controller: confirmPasswordController,
                  isObscured: isConfirmPasswordVisible, toggleVisibility: () {
                setState(() {
                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 30),

              // 🔘 Tombol Sign Up
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: registerUser,
                  child: const Text('Sign Up',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),

              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Do you Have Account? ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(IconData icon, String label, String hintText,
      {required TextEditingController controller,
      bool isPassword = false,
      bool isObscured = false,
      VoidCallback? toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isObscured : false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: toggleVisibility)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -70,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(142, 206, 255, 1.0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            top: 35,
            right: 25,
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black45),
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 25,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.blue),
              ),
            ),
          ),

          // 🔵 Dekorasi Lingkaran Bawah
          Positioned(
            bottom: -750,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(142, 206, 255, 1.0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
