import 'package:flutter/material.dart';

class OfflineModeBanner extends StatelessWidget {
  final VoidCallback onSwitchMode;

  const OfflineModeBanner({
    super.key,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSwitchMode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border(
            bottom: BorderSide(
              color: Colors.orange.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 18,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Mode Offline — Ketuk untuk beralih ke mode online',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.orange.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
