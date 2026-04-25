import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.session != null) {
        context.go('/home');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.unexpectedError)),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  InputDecoration inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.graphiteLight),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                /// Logo
                const Text(
                  "VEDIQLOG ⦿",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.unlockHealth,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: AppColors.graphiteLight,
                  ),
                ),

                const SizedBox(height: 40),

                /// Header
                Text(
                  t.welcomeBack,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.signInVault,
                  style: const TextStyle(color: AppColors.graphiteLight),
                ),

                const SizedBox(height: 30),

                /// Email
                TextField(
                  controller: emailController,
                  decoration: inputDecoration(
                    t.emailAddress,
                    Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                /// Password
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: inputDecoration(
                    t.password,
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.graphiteLight,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      t.forgotPassword,
                      style: const TextStyle(color: AppColors.gold),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.graphite,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.login,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Phone Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/phone-login'),
                    icon: const Icon(Icons.phone),
                    label: const Text("Sign in with Phone"),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                /// Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.noAccount),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(
                        t.signUp,
                        style: const TextStyle(color: AppColors.gold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  t.secureEncrypted,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: AppColors.graphiteLight,
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
