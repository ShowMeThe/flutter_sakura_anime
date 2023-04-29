import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

// ignore: must_be_immutable
class ColorContainer extends StatefulWidget {
  late String url;
  late String title;
  late Color baseColor;

  ColorContainer({this.url = "", this.baseColor = Colors.white, this.title = "" ,super.key});

  @override
  State<StatefulWidget> createState() {
    return _ColorContainerState();
  }
}

class _ColorContainerState extends State<ColorContainer>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation _animation;
  Color _placeColor = Colors.white;
  Color _placeTextColor = Colors.black;
  var isDispose = false;

  Future getPaletteColor(ui.Image image) async {
    var rectWidth = image.width / 3.0;
    var rectHeight = image.height / 3.0;
    var color = await PaletteGenerator.fromImage(image,
        region: Rect.fromCenter(
            center: Offset(image.width / 2.0, image.height / 2.0),
            width: rectWidth,
            height: rectHeight),
        maximumColorCount: 5);
    var lightColor = color.lightVibrantColor ?? color.lightMutedColor;
    if (lightColor != null) {
      _animation = ColorTween(begin: widget.baseColor, end: lightColor.color)
          .animate(_fadeController);
      if(!isDispose){
        _fadeController.forward();
      }
    }
    var blackTextColor = color.darkVibrantColor ?? color.darkMutedColor;
    if(blackTextColor!= null){
      _placeTextColor = blackTextColor.color;
    }
  }

  void initAnimationControllerIfLate() {
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _addImageLoader(widget.url);
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
    isDispose = false;
    _placeColor = widget.baseColor;
    initAnimationControllerIfLate();
  }

  @override
  void dispose() {
    isDispose = true;
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _placeColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: _placeTextColor,
              fontSize: 10.0,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}
