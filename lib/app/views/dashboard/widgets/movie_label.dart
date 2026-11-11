import 'package:flutter/material.dart';

class MovieLabel extends StatelessWidget {
  const MovieLabel({Key? key, required this.movieLabel, this.onTap}) : super(key: key);
  final String movieLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              movieLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
