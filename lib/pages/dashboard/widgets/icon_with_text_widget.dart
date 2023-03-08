import 'package:flutter/material.dart';
import 'package:moviewebapp/utils/colors.dart';

class IconWithText extends StatelessWidget {
  const IconWithText({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: WHITE,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: WHITE,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
