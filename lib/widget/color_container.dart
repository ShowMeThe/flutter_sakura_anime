import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorContainer extends StatefulWidget {
  final String url;
  final Widget body;
  final Color baseColor;

  const ColorContainer(this.url, this.baseColor, this.body, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ColorContainerState();
  }
}

class _ColorContainerState extends State<ColorContainer>
    with TickerProviderStateMixin {
  late ImageProvider _imageProvider;
  late AnimationController _fadeController;
  late Animation _animation;
  Color _placeColor = Colors.transparent;

  Future getPaletteColor(ui.Image image) async {
    var rectWidth = image.width / 3.0;
    var rectHeight = image.height / 3.0;
    var color = await PaletteGenerator.fromImage(image,
        region: Rect.fromCenter(
            center: Offset(image.width / 2.0, image.height / 2.0),
            width: rectWidth,
            height: rectHeight),
        maximumColorCount: 5);
    var lightColor = color.lightVibrantColor ?? color.darkVibrantColor;
    if (lightColor != null) {
      _animation = ColorTween(begin: widget.baseColor, end: lightColor.color)
          .animate(_fadeController);
      _fadeController.forward();
    }
  }

  void initAnimationControllerIfLate() {
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _imageProvider = _addImageLoader(widget.url);
    _fadeController.addListener(() {
      setState(() {
        _placeColor = _animation.value;
      });
    });
  }

  ImageProvider<Object> _addImageLoader(String url) {
    Image image;
    image = Image.network(widget.url);
    image.image
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, synchronousCall) {
          var image = info.image;
          getPaletteColor(image);
        }, onChunk: (_) {}, onError: (_, stack) {}));
    return image.image;
  }

  @override
  void initState() {
    super.initState();
    _placeColor = widget.baseColor;
    initAnimationControllerIfLate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _placeColor,
      child: widget.body,
    );
  }
}
