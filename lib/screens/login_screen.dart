import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _showEmailForm = false;
  bool _hidePassword = true;
  bool _isEmailLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginWithGoogle() async {
    try {
      final user = await auth.signWithGoogleAccount();
      if (user != null) {
        developer.log("User Logged In: ${user.displayName} | ${user.email}");

        // Ensure the signed-in user has a displayName. If Google account
        // doesn't provide a name (rare) derive it from email and persist it.
        try {
          final email = user.email;
          if ((user.displayName == null || user.displayName!.isEmpty) && email != null) {
            final derived = email.split('@').first;
            await user.updateDisplayName(derived);
            if (FirebaseAuth.instance.currentUser != null) {
              await FirebaseAuth.instance.currentUser?.updateDisplayName(derived);
              await FirebaseAuth.instance.currentUser?.reload();
            } else {
              await user.reload();
            }
          }
        } catch (e) {
          developer.log('Failed to set displayName after Google sign-in: $e');
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Google Sign-In error: $e');
      if (mounted) {
        // Show detailed error message with error code (e.g., 12500)
        String errorMsg = e.toString();
        if (errorMsg.contains('12500')) {
          errorMsg = 'Configuration Error (12500): Please ensure Firebase has your app\'s SHA fingerprints registered.';
        } else if (errorMsg.contains('cancelled')) {
          errorMsg = 'Sign-In cancelled. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _loginWithEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isEmailLoading = true);
        final firebaseAuth = FirebaseAuth.instance;
        final userCred = await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCred.user != null) {
          developer.log("User Logged In: ${userCred.user?.displayName} | ${userCred.user?.email}");

          // If the user has no displayName (signed up previously without a name),
          // derive a friendly name from their email and persist it so the
          // HomeScreen greeting can show it.
          final current = userCred.user;
          if (current != null) {
            final email = current.email;
            if ((current.displayName == null || current.displayName!.isEmpty) && email != null) {
              final derived = email.split('@').first;
              try {
                await current.updateDisplayName(derived);
                // Also update the shared currentUser instance and reload
                if (FirebaseAuth.instance.currentUser != null) {
                  await FirebaseAuth.instance.currentUser?.updateDisplayName(derived);
                  await FirebaseAuth.instance.currentUser?.reload();
                } else {
                  await current.reload();
                }
              } catch (_) {}
            }
          }

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } on FirebaseAuthException catch (e) {
        developer.log("Login error: ${e.message}");
        if (mounted) {
          String errorMessage = 'Login failed';
          
          if (e.code == 'user-not-found') {
            errorMessage = 'No account found with this email. Please sign up first.';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'Invalid email format.';
          } else if (e.code == 'user-disabled') {
            errorMessage = 'This account has been disabled.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many login attempts. Please try again later.';
          } else {
            errorMessage = e.message ?? 'Login failed';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isEmailLoading = false);
        }
      }
    }
  }

  void _forgotPassword() {
    final controller = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'your@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid email')),
                );
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent')),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Failed to send reset email')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Remove default appBar for a cleaner modern look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.self_improvement, size: 36, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text('Welcome to MindEase', textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Personalized meditation & yoga to build a calm habit', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      const SizedBox(height: 20),

                      // Social buttons
                      _buildGoogleButton(),
                      const SizedBox(height: 12),

                      // OR divider
                      Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('or')), Expanded(child: Divider())]),
                      const SizedBox(height: 12),

                      // Toggle email form
                      OutlinedButton(
                        onPressed: () => setState(() => _showEmailForm = !_showEmailForm),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14.0)),
                        child: Text(_showEmailForm ? 'Hide email form' : 'Continue with Email'),
                      ),
                      const SizedBox(height: 12),

                      // Animated email form
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showEmailForm ? Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                enabled: !_isEmailLoading,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !_isEmailLoading,
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _hidePassword = !_hidePassword,
                                      );
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildGradientButton(
                                label: _isEmailLoading ? 'Logging in...' : 'Login',
                                onTap: _isEmailLoading ? () {} : _loginWithEmail,
                              ),
                            ],
                          ),
                        ) : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 8),
                      TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text('Create account')),
                      TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
                      const SizedBox(height: 8),
                      Text('By continuing you agree to our Terms & Privacy', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return InkWell(
      onTap: _loginWithGoogle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Text('G', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
            SizedBox(width: 12),
            Text('Continue with Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha(77), blurRadius: 8, offset: const Offset(0,4))],
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
