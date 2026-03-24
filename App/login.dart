import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
    "700915442646-kpfbmbaljjqj7n2n78c1ecucrt24r0iq.apps.googleusercontent.com",
  );

  // ================= REGISTER =================
  Future<void> register() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage("Email and Password cannot be empty");
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      navigateToDashboard();

    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Registration failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= LOGIN =================
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage("Email and Password cannot be empty");
      return;
    }

    try {
      setState(() => isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      navigateToDashboard();

    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Login failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= GOOGLE SIGN IN =================
  Future<void> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        showMessage("Sign in cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      navigateToDashboard();

    } catch (e) {
      showMessage("Google Sign-In failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Dashboard(),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B2A4A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              Lottie.network(
                "https://assets9.lottiefiles.com/packages/lf20_yr6zz3wv.json",
                height: 150,
              ),

              const SizedBox(height: 20),

              const Text(
                "EV Smart Charging",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // ✅ FIXED
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL FIELD
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white), // ✅
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // PASSWORD FIELD
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white), // ✅
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else ...[

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "OR",
                  style: TextStyle(color: Colors.white70), // ✅
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: const Icon(Icons.login,
                        color: Colors.white),
                    label: const Text(
                      "Sign in with Google",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Colors.white54),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
