import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';


class BallClipRotatePulse extends StatefulWidget {

  final Color color;

  const BallClipRotatePulse({required this.color, super.key});

  @override
  State<StatefulWidget> createState() => _BallClipRotatePulseState();
}

class _BallClipRotatePulseState extends State<BallClipRotatePulse>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotateController;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.repeat(min: 0.5,max:1.0,reverse: true);
    _controller.addListener(() {
      setState(() {});
    });

    _rotateController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _rotateController.repeat(min: 0.0,max:1.0,reverse: false);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BallClipRotatePulsePainter(_controller.value, _rotateController.value,widget.color),
    );
  }
}

class BallClipRotatePulsePainter extends CustomPainter {
  double _rotateProgress;
  double _progress;
  Color _color;
  final Paint _paint = Paint();
  final _pi = 3.1415;

  BallClipRotatePulsePainter(this._progress,this._rotateProgress, this._color) {
    _paint.color = _color;
    _paint.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width;
    var height = size.height;
    if(width == 0 || height == 0) return;

    var x = width / 2.0;
    var y = height / 2.0;

    var radius = min(width, height) / 25.0;
    canvas.save();
    var scale = _progress * 2;
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0.0, 0.0), radius, _paint);
    canvas.restore();

    var degree = _rotateProgress * 2 * _pi;
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    canvas.rotate(degree);

    _paint.strokeWidth = 1.5;
    _paint.style = PaintingStyle.stroke;
    var circleSpacing = radius * 4;
    var rect = Rect.fromCenter(
        center: const Offset(0.0, 0.0), width: circleSpacing, height: circleSpacing);
    canvas.drawArc(rect, 0.0, _pi / 2, false, _paint);
    canvas.drawArc(rect, pi, 0.5 * pi, false, _paint);

  }

  @override
  bool shouldRepaint(covariant BallClipRotatePulsePainter oldDelegate) {
    return oldDelegate._progress != _progress || oldDelegate._color != _color;
  }
}
