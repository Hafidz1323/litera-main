import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// 1. Input Field
Widget buildInputField({
  required String label,
  required String hint,
  bool isPassword = false,
  bool isObscured = true,
  VoidCallback? onToggleVisibility,
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? isObscured : false,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: isDark ? AppColors.cardDark : const Color(0xFFEBE8E2),
            errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  });
}

// 2. Tombol Google
Widget buildGoogleButton({required VoidCallback onTap}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/google.png', width: 24, height: 24, errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 24)),
          const SizedBox(width: 12),
          Text(
            'Google',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  });
}

// 3. Garis Pemisah / Divider
Widget buildDivider(String text) {
  return Row(
    children: [
      const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ),
      const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
    ],
  );
}

// 4. Klikable Text
Widget buildClickableText({required String text, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  );
}
