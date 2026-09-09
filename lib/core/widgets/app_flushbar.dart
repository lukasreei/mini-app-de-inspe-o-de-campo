import 'package:another_flushbar/another_flushbar.dart';
import 'package:flutter/material.dart';

enum AppFlushbarType { success, error, warning, info }

Future<void> showAppFlushbar(
  BuildContext context, {
  required String message,
  AppFlushbarType type = AppFlushbarType.info,
}) {
  final config = _config(type);

  return Flushbar<void>(
    title: config.title,
    message: message,
    icon: Icon(config.icon, color: Colors.black87),
    backgroundColor: config.backgroundColor,
    borderColor: config.borderColor,
    borderWidth: 1,
    borderRadius: BorderRadius.circular(14),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.FLOATING,
    duration: const Duration(seconds: 4),
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    animationDuration: const Duration(milliseconds: 350),
    titleColor: Colors.black,
    messageColor: Colors.black87,
    boxShadows: const [
      BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  ).show(context);
}

class _FlushbarConfig {
  const _FlushbarConfig({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
}

_FlushbarConfig _config(AppFlushbarType type) {
  switch (type) {
    case AppFlushbarType.success:
      return _FlushbarConfig(
        title: 'Sucesso',
        icon: Icons.check_circle_outline,
        backgroundColor: Colors.green.shade50,
        borderColor: Colors.green.shade200,
      );

    case AppFlushbarType.error:
      return _FlushbarConfig(
        title: 'Algo deu errado',
        icon: Icons.error_outline,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
      );

    case AppFlushbarType.warning:
      return _FlushbarConfig(
        title: 'Atenção',
        icon: Icons.warning_amber_rounded,
        backgroundColor: Colors.amber.shade50,
        borderColor: Colors.amber.shade200,
      );

    case AppFlushbarType.info:
      return _FlushbarConfig(
        title: 'Informação',
        icon: Icons.info_outline,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
      );
  }
}
