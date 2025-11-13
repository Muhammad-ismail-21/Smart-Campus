// lib/widgets/auth_bottom_sheet.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hub/constants.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for Email/Password auth + Guest login
class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = true; // Start with Create Account as default
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleAuthOperation(
    Future<void> Function() operation, {
    String? errorMessage,
  }) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await operation();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, profileRoute, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? errorMessage ?? 'Authentication failed');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = FirebaseAuth.instance;
    await _handleAuthOperation(() => _isSignUp
        ? auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text)
        : auth.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text));
  }

  Future<void> _signInAnonymously() async {
    await _handleAuthOperation(FirebaseAuth.instance.signInAnonymously,
        errorMessage: 'Anonymous sign-in failed');
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom), // Handles keyboard
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _isSignUp ? 'Create account' : 'Sign in',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
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
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
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
                            if (v == null || v.isEmpty) {
                              return 'Enter your password';
                            }
                            if (v.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        if (_isSignUp) {
                                          setState(() => _isSignUp = false);
                                        } else {
                                          _submit();
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _isSignUp
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: _isSignUp
                                      ? Colors.transparent
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                child: const Text('Sign In'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        if (!_isSignUp) {
                                          setState(() => _isSignUp = true);
                                        } else {
                                          _submit();
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: !_isSignUp
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: !_isSignUp
                                      ? Colors.transparent
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                child: const Text('Create Account'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}