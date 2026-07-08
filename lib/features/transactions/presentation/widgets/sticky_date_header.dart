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
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyDateHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
