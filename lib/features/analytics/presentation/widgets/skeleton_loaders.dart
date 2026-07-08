import 'package:flutter/material.dart';

/// Skeleton loader for chart
class SkeletonChart extends StatefulWidget {
  final double height;

  const SkeletonChart({
    super.key,
    this.height = 200,
  });

  @override
  State<SkeletonChart> createState() => _SkeletonChartState();
}

class _SkeletonChartState extends State<SkeletonChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomPaint(
                painter: _SkeletonPainter(
                  animation: _animationController,
                  baseColor: colorScheme.surfaceContainer,
                  highlightColor: colorScheme.surface,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;

  _SkeletonPainter({
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.lerp(baseColor, highlightColor, animation.value) ??
          baseColor;

    // Draw animated bars
    for (int i = 0; i < 5; i++) {
      final barX = (size.width / 6) * (i + 1);
      final barHeight = size.height * (0.3 + (i % 3) * 0.25);
      canvas.drawRect(
        Rect.fromLTWH(barX - 12, size.height - barHeight, 24, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter oldDelegate) => true;
}

/// Skeleton loader for cards
class SkeletonCard extends StatefulWidget {
  final double height;

  const SkeletonCard({
    super.key,
    this.height = 100,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(
              width: double.infinity,
              height: 16,
              animation: _animationController,
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainer,
            ),
            const SizedBox(height: 12),
            _SkeletonLine(
              width: 200,
              height: 20,
              animation: _animationController,
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainer,
            ),
            const SizedBox(height: 12),
            _SkeletonLine(
              width: 150,
              height: 16,
              animation: _animationController,
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(baseColor, highlightColor, animation.value) ??
                baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

/// Skeleton loading grid for statistics
class SkeletonStatisticsGrid extends StatefulWidget {
  const SkeletonStatisticsGrid({super.key});

  @override
  State<SkeletonStatisticsGrid> createState() =>
      _SkeletonStatisticsGridState();
}

class _SkeletonStatisticsGridState extends State<SkeletonStatisticsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(
              width: 100,
              height: 16,
              animation: _animationController,
              baseColor: colorScheme.surfaceContainerHighest,
              highlightColor: colorScheme.surfaceContainer,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: List.generate(
                6,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonLine(
                          width: 60,
                          height: 12,
                          animation: _animationController,
                          baseColor: colorScheme.surfaceContainer,
                          highlightColor: colorScheme.surface,
                        ),
                        _SkeletonLine(
                          width: 80,
                          height: 14,
                          animation: _animationController,
                          baseColor: colorScheme.surfaceContainer,
                          highlightColor: colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
