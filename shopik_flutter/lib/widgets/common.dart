import 'package:flutter/material.dart';

class AppColors {
  static const burgundy = Color(0xFF8B1D3B);
  static const page = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
  static const muted = Color(0xFF64748B);
  static const dark = Color(0xFF0F172A);
  static const emerald = Color(0xFF059669);
  static const amber = Color(0xFFD97706);
  static const sky = Color(0xFF0284C7);
  static const navy = Color(0xFF1E293B);
  static const rose = Color(0xFFE11D48);
}

String money(num? value, [String? currency]) {
  if (value == null) return '0 ${currency ?? "ر.ي"}';
  final isInt = value == value.roundToDouble();
  final formattedNumber = isInt
      ? _formatThousands(value.toInt().toString())
      : _formatThousands(value.toStringAsFixed(2));
  final cur = currency != null && currency.isNotEmpty ? currency : 'ر.ي';
  return '$formattedNumber $cur';
}

String _formatThousands(String numStr) {
  final parts = numStr.split('.');
  final integerPart = parts[0];
  final buffer = StringBuffer();
  final len = integerPart.length;
  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(integerPart[i]);
  }
  if (parts.length > 1) {
    buffer.write('.${parts[1]}');
  }
  return buffer.toString();
}

String absoluteUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final clean = path.startsWith('/') ? path : '/$path';
  return 'https://shopik.alattab.site$clean';
}

void showAppToast(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      backgroundColor: isError
          ? const Color(0xFFDC2626)
          : (isSuccess ? const Color(0xFF059669) : const Color(0xFF0F172A)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(14),
      duration: const Duration(seconds: 3),
    ),
  );
}
