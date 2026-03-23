import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo widget for OPAD project
/// Displays airplane and radar logo
class LogoWidget extends StatelessWidget {
  final double? size;
  final Color? color;
  final bool showText;

  const LogoWidget({super.key, this.size, this.color, this.showText = false});

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 120.0;
    final logoColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SVG Logo
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: SvgPicture.asset(
            'assets/logo.svg',
            colorFilter: logoColor != Theme.of(context).colorScheme.primary
                ? ColorFilter.mode(logoColor, BlendMode.srcIn)
                : null,
          ),
        ),
        // Text below logo (optional)
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'О П А Д',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: logoColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated logo widget with rotating radar sweep
class AnimatedLogoWidget extends StatefulWidget {
  final double? size;
  final Color? color;
  final bool showText;

  const AnimatedLogoWidget({
    super.key,
    this.size,
    this.color,
    this.showText = false,
  });

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = widget.size ?? 120.0;
    final logoColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Static SVG base
              SvgPicture.asset(
                'assets/logo.svg',
                colorFilter: logoColor != Theme.of(context).colorScheme.primary
                    ? ColorFilter.mode(logoColor, BlendMode.srcIn)
                    : null,
              ),
              // Animated radar sweep overlay
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: CustomPaint(
                      painter: RadarSweepPainter(
                        progress: _controller.value,
                        color: logoColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(height: 8),
          Text(
            'О П А Д',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: logoColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for animated radar sweep
class RadarSweepPainter extends CustomPainter {
  final double progress;
  final Color color;

  RadarSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Calculate sweep angle (0 to 360 degrees)
    final sweepAngle = progress * 360;

    // Create sweep path
    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx, center.dy - radius)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.14159 / 180), // Start from top
        sweepAngle * (3.14159 / 180), // Sweep angle
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();

    // Draw sweep with gradient
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(sweepPath, sweepPaint);
  }

  @override
  bool shouldRepaint(RadarSweepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
