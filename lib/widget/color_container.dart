import 'dart:math';
import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sakura_anime/util/LruCache.dart';
import 'package:palette_generator/palette_generator.dart';


// ignore: must_be_immutable
class ColorContainer extends StatefulWidget {
  late String url;
  late String title;
  late Color baseColor;
  ColorContainer({this.url = "",
    this.baseColor = Colors.white,
    this.title = "",
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

  Future getPaletteColor(ui.Image image) async {
    var rectWidth = min(image.width / 3.0, 100.0);
    var rectHeight = min(image.height / 3.0, 100.0);
    var color = await PaletteGenerator.fromImage(image,
        region: Rect.fromCenter(
            center: Offset(image.width / 2.0, image.height / 2.0),
            width: rectWidth,
            height: rectHeight),
        maximumColorCount: 5);
    var maskColor = color.lightVibrantColor ??
        color.lightMutedColor ??
        color.darkVibrantColor ??
        color.darkMutedColor;
    if (maskColor != null) {
      staticCache.put(widget.url,maskColor.color);
      var isBlack = checkIsBlack(maskColor.color);
      Color blackTextColor;
      if (isBlack) {
        blackTextColor =  Colors.white;
      } else {
        blackTextColor =  Colors.black;
      }
      _placeTextColor = blackTextColor;

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
