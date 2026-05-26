import 'package:flutter/material.dart';
import 'package:litera2/auth_service.dart';
import 'package:litera2/l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../widgets/custom_elements.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= RESET PASSWORD =================
  void _showResetDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.resetPassword),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: l10n.enterEmailHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.emailEmpty)),
                  );
                  return;
                }
                final result = await AuthService().resetPassword(email);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (result == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.verificationSent)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'Litera',
                    style: TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.appSlogan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Material(
                color: isDark ? AppColors.backgroundDark : const Color(0xFFF2F1ED),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 35,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBack,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // GOOGLE LOGIN
                      buildGoogleButton(
                        onTap: () async {
                          String result = await AuthService().signInWithGoogle();
                          if (!context.mounted) return;
                          if (result == "success") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.loginSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (result != "Login dibatalkan") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${l10n.loginError}: $result"),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      buildDivider(l10n.orEmail),
                      const SizedBox(height: 20),
                      // EMAIL
                      buildInputField(
                        label: l10n.email,
                        hint: "email@litera.com",
                        controller: _emailController,
                      ),
                      // PASSWORD
                      buildInputField(
                        label: l10n.password,
                        hint: "••••••••",
                        isPassword: true,
                        controller: _passwordController,
                        isObscured: _isObscured,
                        onToggleVisibility: () {
                          setState(() => _isObscured = !_isObscured);
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: buildClickableText(
                          text: l10n.forgotPassword,
                          onTap: () => _showResetDialog(l10n),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.errorGeneral)),
                            );
                            return;
                          }
                          String result = await AuthService().login(email, password);
                          if (!context.mounted) return;
                          if (result == "success") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.loginSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          l10n.login,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${l10n.noAccount} "),
                          buildClickableText(
                            text: l10n.registerNow,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
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
          ],
        ),
      ),
    );
  }
}
