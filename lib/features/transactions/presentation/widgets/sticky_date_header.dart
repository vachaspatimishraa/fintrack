import 'package:flutter/material.dart';

class StickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  StickyDateHeaderDelegate({required this.title});

  @override
  double get minExtent => 40.0;

  @override
  double get maxExtent => 40.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyDateHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
