// lib/screens/auth_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hub/constants.dart';

// === Step 1: Helper function to validate the email domain ===
bool _isKleEmail(String email) {
  return email.trim().toLowerCase().endsWith('@kletech.ac.in');
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isSignUp => _tabController.index == 1;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // === Step 3: Extra client-side guard before calling Firebase ===
    // This prevents unnecessary API calls for invalid domains.
    final email = _emailController.text.trim();
    if (!_isKleEmail(email)) {
      setState(() => _error = 'Only @kletech.ac.in emails are allowed.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (_isSignUp) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, profileRoute, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      // === Step 4: Handle specific Firebase errors with user-friendly messages ===
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-not-found':
          message = 'No account found for that email. Please create one.';
          break;
        // This newer code is often returned for both wrong password and non-existent user.
        case 'invalid-credential':
          message = 'Invalid email or password. Please try again.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email. Please sign in.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = e.message ?? 'Authentication failed. Please try again.';
      }
      setState(() => _error = message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'SIGN IN'),
            Tab(text: 'CREATE ACCOUNT'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              if (_error != null)
                // === Step 5: Display top-level errors neatly ===
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'College Email',
                  hintText: 'yourname@kletech.ac.in',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                // === Step 2: Add inline validation for email format and domain ===
                validator: (v) {
                  final value = v ?? '';
                  if (value.trim().isEmpty) return 'Please enter your email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  if (!_isKleEmail(value)) return 'Only @kletech.ac.in emails are allowed';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                // Password validation remains the same
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}