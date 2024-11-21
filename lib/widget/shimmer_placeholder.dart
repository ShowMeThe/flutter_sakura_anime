import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sakura_anime/widget/ball_cliprotate_pulse.dart';

enum ShimmerTheme { light, dark }

class ShimmerPlaceholder extends StatefulWidget {
  final Color? progressColor;
  final Color? highlightColor;
  final Color? baseColor;
  final double radius;
  final double width;
  final double height;
  final ShimmerTheme? shimmerTheme;
  final int millisecondsDelay;

  const ShimmerPlaceholder(
      {Key? key,
      this.millisecondsDelay = 0,
      this.radius = 0,
      this.progressColor,
      this.shimmerTheme,
      this.highlightColor,
      this.baseColor,
      required this.width,
      required this.height})
      : assert((highlightColor != null && baseColor != null) ||
            shimmerTheme != null),
        super(key: key);

  /// use this to create a round loading widget
  factory ShimmerPlaceholder.round(
          {required double size,
          Color? highlightColor,
          int millisecondsDelay = 0,
          Color? baseColor,
          ShimmerTheme? shimmerTheme}) =>
      ShimmerPlaceholder(
        height: size,
        width: size,
        radius: size / 2,
        baseColor: baseColor,
        highlightColor: highlightColor,
        shimmerTheme: shimmerTheme,
        millisecondsDelay: millisecondsDelay,
      );

  @override
  State createState() => _ShimmerState();
}

class _ShimmerState extends State<ShimmerPlaceholder>
    with TickerProviderStateMixin {
  static final isHighLightStream =
      Stream<bool>.periodic(const Duration(seconds: 1), (x) => x % 2 == 0)
          .asBroadcastStream();
  bool isHighLight = true;
  late StreamSubscription sub;
  late final random = Random();
  int get delayTime {
   return  random.nextInt(1000);
  }
  int get delayRotateTime {
    return  random.nextInt(500);
  }

  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: 1000 + delayTime),
    vsync: this,
  )..repeat(min: 0.5, max: 1.0, reverse: true);
  late final _rotateController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 500 + delayRotateTime))
    ..repeat(min: 0.5, max: 1.0, reverse: true);

  Color get highLightColor {
    if (widget.shimmerTheme != null) {
      switch (widget.shimmerTheme) {
        case ShimmerTheme.light:
          return const Color(0xffF9F9FB);
        case ShimmerTheme.dark:
          return const Color(0xff3A3E3F);
        default:
          return const Color(0xff3A3E3F);
      }
    }
    return widget.highlightColor!;
  }

  Color get baseColor {
    if (widget.shimmerTheme != null) {
      switch (widget.shimmerTheme) {
        case ShimmerTheme.light:
          return const Color(0xffE6E8EB);
        case ShimmerTheme.dark:
          return const Color(0xff2A2C2E);
        default:
          return const Color(0xff2A2C2E);
      }
    }
    return widget.baseColor!;
  }

  Color get progressColor{
    if(widget.progressColor == null){
      var theme = Theme.of(context);
      var indicator = theme.colorScheme.primary;
      return indicator;
    }
    return widget.progressColor!;
  }

  @override
  void dispose() {
    sub.cancel();
    _rotateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void safeSetState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    sub = isHighLightStream.listen((_isHighLight) {
      if (widget.millisecondsDelay != 0) {
        Future.delayed(Duration(milliseconds: widget.millisecondsDelay), () {
          isHighLight = _isHighLight;
          safeSetState();
        });
      } else {
        isHighLight = _isHighLight;
        safeSetState();
      }
    });

    _controller.addListener(() {
      safeSetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 1000),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
            color: isHighLight ? highLightColor : baseColor,
            borderRadius: BorderRadius.circular(widget.radius)),
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: BallClipRotatePulsePainter(
              _controller.value, _rotateController.value, progressColor),
        ));
  }
}

class GradientPainter extends CustomPainter {
  final Offset offsetAnimation;
  final Color startColor;
  final Color middleColor;
  final Color endColor;

  GradientPainter(
      this.offsetAnimation, this.startColor, this.middleColor, this.endColor);

  final _paint = Paint();
  late final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [startColor, middleColor, endColor],
  );

  @override
  void paint(Canvas canvas, Size size) {
    _paint.strokeWidth = 12.0;
    _paint.style = PaintingStyle.stroke;
    _paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path()
      ..moveTo(0, 0)
      ..relativeLineTo(
          offsetAnimation.dx * size.width, offsetAnimation.dy * size.height);

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
