import 'dart:math';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sakura_anime/util/lru_cache.dart';
import 'package:palette_generator/palette_generator.dart';


// ignore: must_be_immutable
class ColorContainer extends StatefulWidget {
  late String url;
  late String title;
  late Color baseColor;
  double textSize;
  ColorContainer({this.url = "",
    this.baseColor = Colors.white,
    this.title = "",
    this.textSize = 10.0,
    super.key});

  @override
  State<StatefulWidget> createState() {
    return _ColorContainerState();
  }
}

class _ColorContainerState extends State<ColorContainer>
    with TickerProviderStateMixin {
  AnimationController? _fadeController;
  late Animation _animation;
  Color _placeColor = Colors.white;
  Color _placeTextColor = Colors.white;
  var isDispose = false;

  static final staticCache = LruCache<String,Color>(300);
  static final staticTextCache = LruCache<String,Color>(300);

  Future getPaletteColor(ui.Image image) async {
    var rectWidth = min(image.width / 3.0, 100.0);
    var rectHeight = min(image.height / 3.0, 100.0);
    var color = await PaletteGenerator.fromImage(image,
        region: Rect.fromCenter(
            center: Offset(image.width / 2.0, image.height / 2.0),
            width: rectWidth,
            height: rectHeight),
        maximumColorCount: 10);
    var maskColor = color.dominantColor;
    if (maskColor != null) {
      staticCache.put(widget.url,maskColor.color);
      Color placeTextColor = getReadableAccentTextColor(maskColor.color);
      // if (isBlack) {
      //   var lightTextColor = color.lightVibrantColor ?? color.lightMutedColor ?? color.vibrantColor;
      //   placeTextColor =  lightTextColor == null ?  Colors.white : lightTextColor.color;
      // } else {
      //   var darkTextColor = color.darkVibrantColor ?? color.darkMutedColor ?? color.mutedColor;
      //   placeTextColor =  darkTextColor == null ? Colors.black : darkTextColor.color;
      // }
      _placeTextColor = placeTextColor;
      staticTextCache.put(widget.url, placeTextColor);
      var controller = _fadeController;
      if(controller != null){
        _animation = ColorTween(begin: widget.baseColor, end: maskColor.color)
            .animate(controller);
        if (!isDispose) {
          controller.forward();
        }
      }
    }
  }

  Color getReadableAccentTextColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final isDark = hsl.lightness < 0.5;
    final newLightness = isDark
        ? (hsl.lightness + 0.4).clamp(0.0, 1.0)
        : (hsl.lightness - 0.4).clamp(0.0, 1.0);
    final newColor = hsl.withLightness(newLightness).toColor();
    return newColor;
  }


  void initAnimationControllerIfLate() {
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _addImageLoader(widget.url);
    var controller = _fadeController;
    if(controller != null){
      controller.addListener(() {
        setState(() {
          _placeColor = _animation.value;
        });
      });
    }
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
    var color = staticCache.get(widget.url);
    if(color != null){
      _placeColor = color;
    }else{
      _placeColor = widget.baseColor;
      initAnimationControllerIfLate();
    }
    var textColor = staticTextCache.get(widget.url);
    if(textColor != null){
      _placeTextColor = textColor;
    }
  }

  @override
  void dispose() {
    isDispose = true;
    var controller = _fadeController;
    if(controller != null){
      controller.dispose();
      _fadeController = null;
    }
    super.dispose();
  }

  bool checkIsBlack(Color color) {
    var red = color.r;
    var green = color.g;
    var blue = color.b;
    return red * 0.299 + green * 0.587 + blue * 0.114 < 192;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _placeColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: AutoSizeText(
            widget.title,
            minFontSize: 5,
            maxFontSize: widget.textSize,
            style: TextStyle(
              color: _placeTextColor,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}
