import 'package:flutter/material.dart';

class HaloTransition extends StatefulWidget {
  final Widget child;
  final Size size;
  final double width;
  final Duration duration;
  final Color startColor;
  final Color endColor;
  const HaloTransition(
      {Key? key,
      required this.size,
      required this.child,
      required this.width,
      required this.duration,
      required this.startColor,
      required this.endColor})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _HaloState();
}

class _HaloState extends State<HaloTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: widget.duration)
        ..repeat(reverse: true);
  late final Animation<Color?> _animation;
  @override
  void initState() {
    super.initState();
    _animation = ColorTween(begin: widget.startColor, end: widget.endColor)
        .animate(animationController);
  }

  @override
  Widget build(BuildContext context) => AnimatedHalo(
      child: widget.child,
      width: widget.width,
      size: widget.size,
      listenable: _animation);
}

class AnimatedHalo extends AnimatedWidget {
  final Widget child;
  final Size size;
  final double width;
  const AnimatedHalo(
      {Key? key,
      required this.width,
      required this.child,
      required this.size,
      required Animation<Color?> listenable})
      : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<Color?> animation = listenable as Animation<Color?>;
    return CustomPaint(
        foregroundPainter:
            HaloPainter(sigma: animation.value, strokeWidth: width, size: size),
        child: child);
  }
}

class HaloPainter extends CustomPainter {
  final Color? sigma;
  final Size size;
  final double strokeWidth;
  late final Paint _paint;
  late final Rect _rect;
  late final Path _path;

  HaloPainter(
      {required this.sigma, required this.strokeWidth, required this.size}) {
    _paint = Paint()
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..strokeWidth = strokeWidth;
    _rect = Rect.fromLTWH(0, 0, size.width, size.height);
    _path = Path()..addRect(_rect);
  }
  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = sigma ?? Colors.transparent;
    // debugPrint('${sigma}');
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(covariant HaloPainter oldDelegate) =>
      oldDelegate.sigma != sigma;
}
