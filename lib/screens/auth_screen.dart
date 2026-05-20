import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for platform web detection
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _rememberMe = false; // Tracks the checkbox state

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Loads the email and password from local storage if "Remember Me" was checked
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email') ?? '';
    final savedPassword = prefs.getString('remembered_password') ?? '';

    if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Saves or clears the credentials depending on the checkbox state
  Future<void> _handleCredentialsSaving() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailController.text.trim());
      await prefs.setString('remembered_password', _passwordController.text.trim());
    } else {
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
    }
  }

  Future<void> _submit() async {
    try {
      if (_isLogin) {
        // Log in an existing user
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        // Save credentials locally if "Remember Me" is enabled
        await _handleCredentialsSaving();
        return; 
      } else {
        // Sign up a brand new user (Firebase will naturally log them in instantly)
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save credentials locally if "Remember Me" is enabled during signup
        await _handleCredentialsSaving();
        return;
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
      backgroundColor: Colors.grey[100], // Clean background color behind the web card frame
      body: Center(
        child: Container(
          // FIX: Clamps layout form inputs to 450px wide max on desktop web interfaces, scales to full on mobile
          constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
          padding: const EdgeInsets.all(25.0),
          margin: EdgeInsets.all(kIsWeb ? 20.0 : 0.0),
          decoration: BoxDecoration(
            color: kIsWeb ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(kIsWeb ? 20 : 0),
            boxShadow: kIsWeb 
                ? [const BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 2)] 
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Packs elements vertically tight in desktop viewboxes
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              
              // REMEMBER ME CHECKBOX ROW
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: Colors.blue,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Remember Info",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity, // Stretches button width to match input limits evenly
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_isLogin ? "Login" : "Sign Up", style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}