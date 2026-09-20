import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// SURAKSHIT MOTION SYSTEM
/// Staggered entrances · press micro-interactions · shimmer
/// skeletons · animated counters · aurora · custom transitions
/// ═══════════════════════════════════════════════════════════════

/// Fade + slide-up entrance; [index] staggers siblings automatically.
class StaggerIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const StaggerIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 560),
  });

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final start = (widget.index * 0.07).clamp(0.0, 0.72).toDouble();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.045), end: Offset.zero)
            .animate(_animation),
        child: widget.child,
      ),
    );
  }
}

/// Springy press-down scale + light haptic — the signature tap feel.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Numbers that count up smoothly when they change.
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$v', style: style),
    );
  }
}

/// Shimmering skeleton block for premium loading states.
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius radius;

  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: widget.radius,
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              colors: [
                AppColors.surface,
                Colors.white.withOpacity(0.055),
                AppColors.surface,
              ],
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double t;
  const _SlidingGradientTransform(this.t);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
  }
}

/// Full-card shimmer list used while data loads.
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonList({super.key, this.count = 4, this.itemHeight = 120});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Skeleton(
              width: double.infinity,
              height: itemHeight,
              radius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Living aurora gradient card — slowly drifting blue→violet→magenta.
class AuroraCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool animate;

  const AuroraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.boxShadow,
    this.animate = true,
  });

  @override
  State<AuroraCard> createState() => _AuroraCardState();
}

class _AuroraCardState extends State<AuroraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 7));
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) return _build(null);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = math.sin(_controller.value * 2 * math.pi) * 0.35;
        return _build(GradientRotation(angle));
      },
    );
  }

  Widget _build(GradientRotation? rotation) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.9, -0.9),
          end: const Alignment(0.9, 0.9),
          colors: const [
            Color(0xFF1A6BF5),
            Color(0xFF7C3AED),
            Color(0xFFC21DD4),
          ],
          transform: rotation,
        ),
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: widget.child,
    );
  }
}

/// Buttery fade + slide page transition for pushed screens.
class SlideFadeRoute<T> extends PageRouteBuilder<T> {
  SlideFadeRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final curved =
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                    .animate(curved),
                child: child,
              ),
            );
          },
        );
}
