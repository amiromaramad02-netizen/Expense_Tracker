import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/auth_store.dart';
import 'profile_setup_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final success = await authStore.login(emailController.text, passwordController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(const SnackBar(content: Text('Logged in successfully')));

      // Save credentials if user opted in
      if (_rememberMe) {
        if (!mounted) return;
        await authStore.saveCredentials(emailController.text, passwordController.text);
      } else {
        // If credentials not saved, ask user if they'd like to save them
        final alreadySaved = await authStore.hasSavedCredentials(emailController.text);
        if (!alreadySaved && mounted) {
          final save = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Save info?'),
              content: const Text('Would you like to save your login info for quicker sign in?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
              ],
            ),
          );
          if (!mounted) return;
          if (save == true) {
            await authStore.saveCredentials(emailController.text, passwordController.text);
          }
        }
      }

      // Check if user has profile; if not, go to profile setup
      if (!authStore.hasProfile) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
          (_) => false,
        );
      } else {
        // Return to root; root's auth listener will switch to HomeShell
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      setState(() => _errorMessage = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF7C4DFF);
    final primaryLight = const Color(0xFFFAF6FF);

    return Scaffold(
      backgroundColor: primaryLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 48),
                  // Email field
                  Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    // Suggest saved accounts
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.mail_outline, color: primary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.people),
                        onPressed: () async {
                          final emails = await authStore.getSavedEmails();
                          if (!mounted || emails.isEmpty) return;
                          final chosen = await showDialog<String>(
                            context: context,
                            builder: (ctx) => SimpleDialog(
                              title: const Text('Saved accounts'),
                              children: emails.map((e) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(ctx, e),
                                child: Text(e),
                              )).toList(),
                            ),
                          );
                          if (!mounted) return;
                          if (chosen != null) emailController.text = chosen;
                          // Fill password if saved for this account
                          final saved = await authStore.getSavedPassword(chosen ?? '');
                          if (!mounted) return;
                          if (saved != null && saved.isNotEmpty) {
                            passwordController.text = saved;
                            setState(() => _rememberMe = true);
                            // Auto-attempt sign-in when we have saved credentials.
                            // Show a brief confirmation and then attempt sign-in so
                            // the UI clearly reflects the action.
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signing in as $chosen...')));
                            }
                            await _handleLogin();
                          }
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Remember me
                  Row(
                    children: [
                      Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                      const SizedBox(width: 8),
                      const Text('Remember me'),
                    ],
                  ),
                  // Password field
                  Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline, color: primary),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: primary),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(fontSize: 13, color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Signup link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignupPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primary),
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
    );
  }
}
