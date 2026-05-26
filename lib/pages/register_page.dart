import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:litera2/l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../widgets/custom_elements.dart';
import '../auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isAgreed = false;
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ================= VALIDATION =================
  String? _validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.errorGeneral;
    if (value.length < 3) return l10n.errorGeneral;
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.emailEmpty;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return l10n.loginError;
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.errorGeneral;
    if (value.length < 8) return l10n.errorGeneral;
    return null;
  }

  String? _validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.errorGeneral;
    if (value != _passwordController.text) return l10n.errorGeneral;
    return null;
  }

  // ================= DIALOG =================
  void _showTermsDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.termsAndConditions),
        content: Text(l10n.termsDetail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  // ================= REGISTER =================
  Future<void> _handleRegister(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.termsAgreementError)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.registrationSuccess)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Text(
            l10n.createAccount,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l10n.joinMessage,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Material(
              color: isDark ? AppColors.backgroundDark : const Color(0xFFF2F1ED),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        buildInputField(
                          label: l10n.fullName,
                          hint: "John Doe",
                          controller: _nameController,
                          validator: (v) => _validateName(v, l10n),
                        ),
                        buildInputField(
                          label: l10n.email,
                          hint: "email@litera.com",
                          controller: _emailController,
                          validator: (v) => _validateEmail(v, l10n),
                        ),
                        buildInputField(
                          label: l10n.password,
                          hint: "Min. 8 characters",
                          isPassword: true,
                          isObscured: _isPasswordObscured,
                          controller: _passwordController,
                          validator: (v) => _validatePassword(v, l10n),
                          onToggleVisibility: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        buildInputField(
                          label: l10n.confirmPassword,
                          hint: l10n.confirmPassword,
                          isPassword: true,
                          isObscured: _isConfirmObscured,
                          controller: _confirmPasswordController,
                          validator: (v) => _validateConfirmPassword(v, l10n),
                          onToggleVisibility: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                        ),

                        // Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isAgreed = v ?? false),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: "${l10n.iAgreeTo} ",
                                  children: [
                                    TextSpan(
                                      text: l10n.termsAndConditions,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () => _showTermsDialog(l10n),
                                    ),
                                  ],
                                ),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleRegister(l10n),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  l10n.registerNow,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        buildDivider(l10n.or),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${l10n.alreadyHaveAccount} "),
                            buildClickableText(
                              text: l10n.login,
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
