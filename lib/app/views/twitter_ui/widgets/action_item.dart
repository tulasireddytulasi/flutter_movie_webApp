import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/extensions.dart';

class ActionItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const ActionItem({
    Key? key,
    required this.icon,
    required this.count,
    required this.color,
    this.isActive = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: color),
            const SizedBox(width: 2.0),
            Text(
              count.toCompactCurrencyFormat(),
              style: TextStyle(
                color: color,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}