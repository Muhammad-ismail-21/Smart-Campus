import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hub/constants.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _usnController = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error; // top-level error line

  @override
  void dispose() {
    _usnController.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  final usn = _usnController.text.trim().toLowerCase();
  final email = '$usn@kletech.ac.in';
  final password = _password.text;

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final auth = FirebaseAuth.instance;
    if (_isSignUp) {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
    } else {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, dashboardRoute, (route) => false);
    }
  } on FirebaseAuthException catch (e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'That email address looks invalid.';
        break;
      case 'user-not-found':
        message = 'No account found for that email. Please create one.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials. Please check your email and password.';
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
    setState(() => _error = 'An unexpected error occurred. Please try again.');
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  // Guest login stays allowed
  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, dashboardRoute, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Anonymous sign-in failed.');
    } catch (_) {
      setState(() => _error = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  width: 42, height: 5, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _isSignUp ? 'Create account' : 'Sign in',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // top error line
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [ // Top error bar for general/Firebase errors
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usnController,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'USN',
                          hintText: 'e.g., 01fe21bcs001',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your USN' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your password';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isSignUp ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loading ? null : () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(_isSignUp
                            ? 'Have an account? Sign in'
                            : 'New here? Create account'),
                      ),
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _signInAnonymously,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Continue as guest'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
