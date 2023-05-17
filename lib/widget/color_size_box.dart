import 'package:flutter/material.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'dart:ui' as ui;
import 'package:palette_generator/palette_generator.dart';

typedef ColorCallback = void Function(bool isBlack);

// ignore: must_be_immutable
class ColorSizeBox extends StatefulWidget {
  String url;
  Widget? child;
  ShapeBorder? shape;
  double width;
  double height;
  ColorCallback? callback;

  ColorSizeBox(
      {super.key,
      this.child,
      this.url = "",
      this.shape,
      this.callback,
      this.width = double.infinity,
      this.height = double.infinity});

  @override
  State<StatefulWidget> createState() {
    return ColorSizeBoxState();
  }
}

class ColorSizeBoxState extends State<ColorSizeBox>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation _animation;
  Color baseColor = ColorRes.mainColor;
  Color _placeColor = ColorRes.mainColor;
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
    var lightColor = color.lightVibrantColor ??
        color.lightMutedColor ??
        color.darkMutedColor ??
        color.darkVibrantColor;

    if (lightColor != null) {
      if (widget.callback != null) {
        widget.callback!(checkIsBlack(lightColor.color));
      }
    }
    if (lightColor != null) {
      _animation = ColorTween(begin: baseColor, end: lightColor.color)
          .animate(_fadeController);
      if (!isDispose) {
        _fadeController.forward();
      }
    }
  }

  bool checkIsBlack(Color color) {
    var red = color.red;
    var green = color.green;
    var blue = color.blue;
    return red * 0.299 + green * 0.587 + blue * 0.114 < 192;
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
    image = Image(image: ExtendedNetworkImageProvider(url, cache: true));
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
    _placeColor = baseColor;
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
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: _placeColor,
        shape: widget.shape,
        child: widget.child,
      ),
    );
  }
}
