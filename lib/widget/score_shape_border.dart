import 'package:flutter/material.dart';

class ScoreShapeBorder extends CustomPainter {

  final Color fillColor;
  final Path path = Path();
  final Paint mPaint = Paint();

  ScoreShapeBorder(this.fillColor);


  @override
  void paint(Canvas canvas, Size size) {
    mPaint.color = fillColor;
    var width = size.width;
    var height = size.height;
    var halfHeight = height / 2;
    var queWidth = width / 4;
    
    path.reset();
    path.moveTo(0, 0);
    path.lineTo(0, height);
    path.lineTo(queWidth,halfHeight);
    path.lineTo(width - queWidth, halfHeight);
    path.lineTo(width,0);
    path.close();
    canvas.drawPath(path, mPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
      var old = (oldDelegate as ScoreShapeBorder);
      return (oldDelegate).fillColor == fillColor;
  }

}