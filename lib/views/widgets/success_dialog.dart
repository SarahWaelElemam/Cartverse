import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SuccessDialog extends StatelessWidget {
  final String titleKey;
  final String messageKey;
  final List<String>? messageArgs;

  const SuccessDialog({
    Key? key,
    required this.titleKey,
    required this.messageKey,
    this.messageArgs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 60, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            titleKey.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            messageKey.tr(args: messageArgs ?? []),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFb88e2f),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}